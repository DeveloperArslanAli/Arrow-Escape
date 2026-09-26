class_name TestArrowMotion
extends RefCounted

static func run(caller_node: Node) -> bool:
	var tree = caller_node.get_tree()
	
	# Create an L-shaped arrow: (1, 0) -> (2, 0) -> (2, 1) pointing DOWN
	var arrow = ArrowController.new()
	caller_node.add_child(arrow)
	
	var pts: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(2, 1)]
	arrow.setup_polyline(
		"test_arr",
		pts,
		Color.BLUE,
		60.0,
		func(c: Vector2i) -> Vector2:
			return Vector2(c.x * 60.0 + 30.0, c.y * 60.0 + 30.0)
	)
	
	if arrow.position != Vector2.ZERO:
		push_error("Arrow position must start at ZERO")
		arrow.queue_free()
		return false
		
	# Test blocked animation does not displace position
	arrow.play_blocked_animation()
	await tree.process_frame
	if arrow.position != Vector2.ZERO:
		push_error("Blocked animation shifted position off-center!")
		arrow.queue_free()
		return false
		
	# Wait for blocked animation to settle
	await tree.create_timer(0.25).timeout
	if arrow.position != Vector2.ZERO:
		push_error("Blocked animation did not return to ZERO!")
		arrow.queue_free()
		return false
		
	# Test escape animation
	arrow.play_escape_animation(500.0)
	await tree.process_frame
	if arrow.position != Vector2.ZERO:
		push_error("Escape animation shifted position off-center!")
		return false
		
	# Await escape animation to complete naturally
	await arrow.escape_finished
	return true
