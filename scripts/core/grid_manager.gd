class_name GridManager
extends Node2D

const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")
const SolverEngine = preload("res://scripts/solver/solver_engine.gd")
const ArrowControllerClass = preload("res://scripts/core/arrow_controller.gd")

signal all_arrows_cleared()
signal arrow_escaped(arrow_id: String)
signal arrow_blocked(arrow_id: String)

var grid_size: Vector2i = Vector2i(4, 4)
var cell_size: float = 90.0
var board_origin: Vector2 = Vector2.ZERO
var board_size_px: Vector2 = Vector2.ZERO

var grid_occupancy: Dictionary = {} # Vector2i -> ArrowController
var remaining_arrows_count: int = 0
var is_input_locked: bool = false
var active_arrows_list: Array[ArrowController] = []

func _ready() -> void:
	queue_redraw()

func initialize_board(level_data: Dictionary, available_rect: Rect2) -> void:
	# Clear previous board state
	for child in get_children():
		child.queue_free()
	grid_occupancy.clear()
	active_arrows_list.clear()
	is_input_locked = false
	
	var rows: int = int(level_data["grid_size"]["rows"])
	var cols: int = int(level_data["grid_size"]["columns"])
	grid_size = Vector2i(cols, rows)
	
	# Calculate responsive cell size
	var cell_w: float = available_rect.size.x / float(cols)
	var cell_h: float = available_rect.size.y / float(rows)
	cell_size = minf(cell_w, cell_h) * 0.90
	
	board_size_px = Vector2(float(cols) * cell_size, float(rows) * cell_size)
	board_origin = available_rect.position + (available_rect.size - board_size_px) * 0.5
	
	# Spawn arrows
	var arrows_data: Array = level_data.get("arrows", [])
	remaining_arrows_count = arrows_data.size()
	
	for arrow_info in arrows_data:
		var col: int = int(arrow_info["column"])
		var row: int = int(arrow_info["row"])
		var coord: Vector2i = Vector2i(col, row)
		var arrow_id: String = str(arrow_info.get("id", "arrow_%d_%d" % [col, row]))
		var dir_str: String = str(arrow_info.get("direction", "up"))
		var dir: int = GlobalConstants.STRING_TO_DIRECTION.get(dir_str, GlobalConstants.Direction.UP)
		
		var arrow_node = ArrowControllerClass.new()
		arrow_node.position = get_cell_center_px(coord)
		arrow_node.setup(arrow_id, coord, dir, cell_size)
		add_child(arrow_node)
		
		grid_occupancy[coord] = arrow_node
		active_arrows_list.append(arrow_node)
		
	queue_redraw()

func get_cell_center_px(coord: Vector2i) -> Vector2:
	return board_origin + Vector2(
		(float(coord.x) + 0.5) * cell_size,
		(float(coord.y) + 0.5) * cell_size
	)

func get_coord_at_px(pos: Vector2) -> Vector2i:
	var local: Vector2 = pos - board_origin
	if local.x < 0 or local.y < 0 or local.x >= board_size_px.x or local.y >= board_size_px.y:
		return Vector2i(-1, -1)
	return Vector2i(int(local.x / cell_size), int(local.y / cell_size))

func _draw() -> void:
	if grid_size.x == 0 or grid_size.y == 0:
		return
		
	# Draw board background rounded rect
	var padding: float = 12.0
	var bg_rect = Rect2(board_origin - Vector2(padding, padding), board_size_px + Vector2(padding * 2.0, padding * 2.0))
	draw_rect(bg_rect, GlobalConstants.COLOR_BOARD, true, -1.0)
	
	# Draw subtle cell tiles
	for r in range(grid_size.y):
		for c in range(grid_size.x):
			var cell_rect = Rect2(
				board_origin + Vector2(float(c) * cell_size + 4.0, float(r) * cell_size + 4.0),
				Vector2(cell_size - 8.0, cell_size - 8.0)
			)
			draw_rect(cell_rect, Color(1.0, 1.0, 1.0, 0.55), true, -1.0)

func _unhandled_input(event: InputEvent) -> void:
	if is_input_locked:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_process_tap(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_process_tap(event.position)

func _process_tap(screen_pos: Vector2) -> void:
	var coord: Vector2i = get_coord_at_px(screen_pos)
	if coord.x < 0 or coord.y < 0:
		return
		
	if not grid_occupancy.has(coord) or grid_occupancy[coord] == null:
		return
		
	var arrow: ArrowController = grid_occupancy[coord]
	if not arrow.is_interactive:
		return
		
	AudioManager.play_tap()
	
	# Check path
	if PathValidator.can_arrow_escape(coord, arrow.direction, grid_occupancy, grid_size):
		_execute_escape(arrow, coord)
	else:
		_execute_blocked(arrow)

func _execute_escape(arrow: ArrowController, coord: Vector2i) -> void:
	# Atomic occupancy update to avoid race conditions
	grid_occupancy[coord] = null
	active_arrows_list.erase(arrow)
	remaining_arrows_count -= 1
	
	GameManager.increment_moves()
	GameManager.register_arrow_escaped()
	arrow_escaped.emit(arrow.arrow_id)
	
	arrow.play_escape_animation()
	
	if remaining_arrows_count <= 0:
		is_input_locked = true
		# Slight delay before victory fanfare
		get_tree().create_timer(0.3).timeout.connect(func():
			all_arrows_cleared.emit()
			GameManager.notify_all_arrows_cleared()
		)

func _execute_blocked(arrow: ArrowController) -> void:
	GameManager.register_arrow_blocked()
	arrow_blocked.emit(arrow.arrow_id)
	arrow.play_blocked_animation()

func show_hint() -> void:
	if is_input_locked or active_arrows_list.is_empty():
		return
		
	var arrows_snapshot: Array = []
	for a in active_arrows_list:
		arrows_snapshot.append({
			"id": a.arrow_id,
			"column": a.grid_coord.x,
			"row": a.grid_coord.y,
			"direction": GlobalConstants.DIRECTION_TO_STRING.get(a.direction, "up")
		})
		
	var hint_id: String = SolverEngine.get_hint(grid_size, arrows_snapshot)
	if hint_id.is_empty():
		# Fallback: highlight any removable arrow
		var removable: Array[Vector2i] = PathValidator.get_removable_arrows(grid_occupancy, grid_size)
		if not removable.is_empty():
			var fallback_arrow = grid_occupancy[removable[0]]
			if fallback_arrow != null:
				fallback_arrow.set_hint_highlight(true)
		return
		
	for a in active_arrows_list:
		if a.arrow_id == hint_id:
			a.set_hint_highlight(true)
			break
