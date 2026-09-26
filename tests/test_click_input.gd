class_name TestClickInput
extends RefCounted

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
	
	if grid_manager.active_arrows_list.size() != 4:
		push_error("Level 2 did not initialize with 4 arrows")
		main_scene.queue_free()
		return false
		
	# 1. Click Orange arrow (arr_4) at cell (0, 1) -> must escape
	var arr_4_pos = grid_manager.get_cell_center_px(Vector2i(0, 1))
	var evt1 = InputEventMouseButton.new()
	evt1.button_index = MOUSE_BUTTON_LEFT
	evt1.pressed = true
	evt1.position = arr_4_pos
	grid_manager._unhandled_input(evt1)
	await tree.process_frame
	
	if grid_manager.active_arrows_list.size() != 3:
		push_error("arr_4 failed to escape on click")
		main_scene.queue_free()
		return false
		
	# 2. Click Blue arrow (arr_1) at cell (2, 0) -> now unblocked, must escape
	var arr_1_pos = grid_manager.get_cell_center_px(Vector2i(2, 0))
	var evt2 = InputEventMouseButton.new()
	evt2.button_index = MOUSE_BUTTON_LEFT
	evt2.pressed = true
	evt2.position = arr_1_pos
	grid_manager._unhandled_input(evt2)
	await tree.process_frame
	
	if grid_manager.active_arrows_list.size() != 2:
		push_error("arr_1 failed to escape on click")
		main_scene.queue_free()
		return false
		
	# 3. Click Red arrow (arr_2) at cell (2, 2) -> blocked by green arrow, deduct 1 heart
	var hearts_pre = GameManager.current_hearts
	var arr_2_pos = grid_manager.get_cell_center_px(Vector2i(2, 2))
	var evt3 = InputEventMouseButton.new()
	evt3.button_index = MOUSE_BUTTON_LEFT
	evt3.pressed = true
	evt3.position = arr_2_pos
	grid_manager._unhandled_input(evt3)
	await tree.process_frame
	
	if grid_manager.active_arrows_list.size() != 2 or GameManager.current_hearts != hearts_pre - 1:
		push_error("arr_2 blocked logic failed")
		main_scene.queue_free()
		return false
		
	main_scene.queue_free()
	return true
