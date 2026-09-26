class_name TestClickInput
extends RefCounted

const SolverEngine = preload("res://scripts/solver/solver_engine.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")

static func run(caller_node: Node) -> bool:
	var tree = caller_node.get_tree()
	var main_scene = load("res://scenes/core/Main.tscn").instantiate()
	caller_node.add_child(main_scene)
	await tree.process_frame
	
	var background = main_scene.get_node("Background")
	if background.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		push_error("Background mouse_filter is not IGNORE (2)")
		main_scene.queue_free()
		return false
		
	GameManager.start_level(2)
	await tree.process_frame
	
	var game_board = main_scene.get_node("GameBoard")
	var grid_manager = game_board.get_node("GridManager")
	
	var initial_count = grid_manager.active_arrows_list.size()
	if initial_count < 2:
		push_error("Level 2 has fewer than 2 arrows")
		main_scene.queue_free()
		return false
		
	# 1. Test clicking a blocked arrow first (while initial obstacles are present)
	var blocked_arrow: ArrowController = null
	for a in grid_manager.active_arrows_list:
		if not PathValidator.can_arrow_escape_polyline(a.grid_points, a.arrow_id, grid_manager.grid_occupancy, grid_manager.grid_size):
			blocked_arrow = a
			break
			
	if blocked_arrow != null:
		var hearts_pre = GameManager.current_hearts
		var b_pt = blocked_arrow.grid_points[0]
		var b_pos = grid_manager.get_cell_center_px(b_pt)
		var evt_b = InputEventMouseButton.new()
		evt_b.button_index = MOUSE_BUTTON_LEFT
		evt_b.pressed = true
		evt_b.position = b_pos
		grid_manager._unhandled_input(evt_b)
		await tree.process_frame
		
		if grid_manager.active_arrows_list.size() != initial_count or GameManager.current_hearts != hearts_pre - 1:
			push_error("Blocked arrow click logic failed")
			main_scene.queue_free()
			return false
			
	# 2. Test clicking an unblocked arrow dynamically
	var unblocked_arrow: ArrowController = null
	for a in grid_manager.active_arrows_list:
		if PathValidator.can_arrow_escape_polyline(a.grid_points, a.arrow_id, grid_manager.grid_occupancy, grid_manager.grid_size):
			unblocked_arrow = a
			break
				
	if unblocked_arrow == null:
		push_error("No unblocked arrow found on Level 2")
		main_scene.queue_free()
		return false
		
	var count_before_escape = grid_manager.active_arrows_list.size()
	var click_pt = unblocked_arrow.grid_points[0]
	var click_pos = grid_manager.get_cell_center_px(click_pt)
	var evt_u = InputEventMouseButton.new()
	evt_u.button_index = MOUSE_BUTTON_LEFT
	evt_u.pressed = true
	evt_u.position = click_pos
	grid_manager._unhandled_input(evt_u)
	await tree.process_frame
	
	if grid_manager.active_arrows_list.size() != count_before_escape - 1:
		push_error("Unblocked arrow failed to escape on click")
		main_scene.queue_free()
		return false
		
	main_scene.queue_free()
	return true
