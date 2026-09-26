class_name GridManager
extends Node2D

const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")
const SolverEngine = preload("res://scripts/solver/solver_engine.gd")
const ArrowControllerClass = preload("res://scripts/core/arrow_controller.gd")

signal all_arrows_cleared()
signal arrow_escaped(arrow_id: String)
signal arrow_blocked(arrow_id: String)

var grid_size: Vector2i = Vector2i(6, 6)
var cell_size: float = 60.0
var board_origin: Vector2 = Vector2.ZERO
var board_size_px: Vector2 = Vector2.ZERO

var grid_occupancy: Dictionary = {} # Vector2i -> ArrowController
var remaining_arrows_count: int = 0
var is_input_locked: bool = false
var active_arrows_list: Array[ArrowController] = []

func _ready() -> void:
	queue_redraw()

func initialize_board(level_data: Dictionary, available_rect: Rect2) -> void:
	for child in get_children():
		child.queue_free()
	grid_occupancy.clear()
	active_arrows_list.clear()
	is_input_locked = false
	
	var rows: int = int(level_data["grid_size"]["rows"])
	var cols: int = int(level_data["grid_size"]["columns"])
	grid_size = Vector2i(cols, rows)
	
	# Scale board to available viewport
	var cell_w: float = available_rect.size.x / float(cols)
	var cell_h: float = available_rect.size.y / float(rows)
	cell_size = minf(cell_w, cell_h) * 0.94
	
	board_size_px = Vector2(float(cols) * cell_size, float(rows) * cell_size)
	board_origin = available_rect.position + (available_rect.size - board_size_px) * 0.5
	
	var arrows_data: Array = level_data.get("arrows", [])
	remaining_arrows_count = arrows_data.size()
	
	var color_idx = 0
	for arrow_info in arrows_data:
		var arrow_id: String = str(arrow_info.get("id", "arr_%d" % color_idx))
		var color_val: Color
		if arrow_info.has("color"):
			color_val = Color(str(arrow_info["color"]))
		else:
			color_val = GlobalConstants.ARROW_COLORS[color_idx % GlobalConstants.ARROW_COLORS.size()]
		color_idx += 1
		
		# Parse points
		var pts: Array[Vector2i] = []
		if arrow_info.has("points"):
			for p in arrow_info["points"]:
				if p is Array:
					pts.append(Vector2i(int(p[0]), int(p[1])))
				elif p is Vector2i:
					pts.append(p)
		else:
			# Fallback for single point
			var c = int(arrow_info.get("column", 0))
			var r = int(arrow_info.get("row", 0))
			var d_str = str(arrow_info.get("direction", "up"))
			var d = GlobalConstants.STRING_TO_DIRECTION.get(d_str, GlobalConstants.Direction.UP)
			var dir_v = GlobalConstants.DIRECTION_VECTORS[d]
			pts.append(Vector2i(c, r) - dir_v)
			pts.append(Vector2i(c, r))
			
		var arrow_node: ArrowController = ArrowControllerClass.new()
		add_child(arrow_node)
		
		arrow_node.setup_polyline(
			arrow_id,
			pts,
			color_val,
			cell_size,
			func(coord: Vector2i) -> Vector2:
				return get_cell_center_px(coord)
		)
		
		# Register multi-cell occupancy
		for p in pts:
			grid_occupancy[p] = arrow_node
			
		active_arrows_list.append(arrow_node)
		
	queue_redraw()

func get_cell_center_px(coord: Vector2i) -> Vector2:
	return board_origin + Vector2(
		(float(coord.x) + 0.5) * cell_size,
		(float(coord.y) + 0.5) * cell_size
	)

func _draw() -> void:
	if grid_size.x == 0 or grid_size.y == 0:
		return
		
	# Draw subtle dot grid / clean light grid
	var dot_color = Color(0.80, 0.88, 0.96, 0.55)
	for r in range(grid_size.y):
		for c in range(grid_size.x):
			var center = get_cell_center_px(Vector2i(c, r))
			draw_circle(center, 2.5, dot_color)

func _unhandled_input(event: InputEvent) -> void:
	if is_input_locked:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_process_tap(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_process_tap(event.position)

func _process_tap(screen_pos: Vector2) -> void:
	# Check if clicked on any arrow
	for a in active_arrows_list:
		if a.is_interactive and a.contains_point(screen_pos, cell_size * 0.4):
			_handle_arrow_clicked(a)
			return

func _handle_arrow_clicked(arrow: ArrowController) -> void:
	AudioManager.play_tap()
	
	if PathValidator.can_arrow_escape_polyline(arrow.grid_points, arrow.arrow_id, grid_occupancy, grid_size):
		_execute_escape(arrow)
	else:
		_execute_blocked(arrow)

func _execute_escape(arrow: ArrowController) -> void:
	# Clear occupancy for all cells of this arrow
	for p in arrow.grid_points:
		grid_occupancy.erase(p)
		
	active_arrows_list.erase(arrow)
	remaining_arrows_count -= 1
	
	GameManager.register_arrow_escaped()
	arrow_escaped.emit(arrow.arrow_id)
	
	arrow.play_escape_animation()
	
	if remaining_arrows_count <= 0:
		is_input_locked = true
		get_tree().create_timer(0.3).timeout.connect(func():
			all_arrows_cleared.emit()
			GameManager.notify_all_arrows_cleared()
		)

func _execute_blocked(arrow: ArrowController) -> void:
	arrow.play_blocked_animation()
	arrow_blocked.emit(arrow.arrow_id)
	GameManager.deduct_heart()

func show_hint() -> void:
	if is_input_locked or active_arrows_list.is_empty():
		return
		
	var arrows_snapshot: Array = []
	for a in active_arrows_list:
		var pts_raw: Array = []
		for p in a.grid_points:
			pts_raw.append([p.x, p.y])
		arrows_snapshot.append({
			"id": a.arrow_id,
			"points": pts_raw
		})
		
	var hint_id: String = SolverEngine.get_hint(grid_size, arrows_snapshot)
	if not hint_id.is_empty():
		for a in active_arrows_list:
			if a.arrow_id == hint_id:
				a.set_hint_highlight(true)
				return
				
	# Fallback: highlight any arrow whose path is currently clear
	for a in active_arrows_list:
		if PathValidator.can_arrow_escape_polyline(a.grid_points, a.arrow_id, grid_occupancy, grid_size):
			a.set_hint_highlight(true)
			return
