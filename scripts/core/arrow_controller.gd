class_name ArrowController
extends Node2D

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

signal arrow_tapped(arrow: ArrowController)
signal escape_finished(arrow: ArrowController)

var arrow_id: String = ""
var grid_points: Array[Vector2i] = [] # Ordered path from tail to head
var local_points: PackedVector2Array = []
var head_direction: int = GlobalConstants.Direction.UP
var head_dir_vec: Vector2i = Vector2i(0, -1)
var line_width: float = 12.0
var is_interactive: bool = true
var is_highlighted: bool = false
var arrow_color: Color = Color("#2B7DE9")
var cell_size: float = 60.0

func setup_polyline(
	id: String,
	pts: Array[Vector2i],
	col: Color,
	c_size: float,
	coord_to_local_fn: Callable
) -> void:
	arrow_id = id
	grid_points = pts
	arrow_color = col
	cell_size = c_size
	line_width = clampf(cell_size * 0.28, 8.0, 16.0)
	
	if pts.size() >= 2:
		var head_pt = pts[-1]
		var prev_pt = pts[-2]
		head_dir_vec = head_pt - prev_pt
		head_direction = GlobalConstants.vector_to_direction(head_dir_vec)
		
	# Compute local pixel points relative to this node
	local_points.clear()
	for pt in pts:
		var px_pos: Vector2 = coord_to_local_fn.call(pt)
		local_points.append(px_pos)
		
	queue_redraw()

func _draw() -> void:
	if local_points.size() < 2:
		return
		
	var head_pos: Vector2 = local_points[-1]
	var prev_pos: Vector2 = local_points[-2]
	var head_dir: Vector2 = (head_pos - prev_pos).normalized()
	
	# 1. Hint Glow
	if is_highlighted:
		draw_polyline(local_points, GlobalConstants.COLOR_ACCENT, line_width + 10.0, true)
		draw_circle(head_pos, line_width * 1.5, GlobalConstants.COLOR_ACCENT)
		
	# 2. Outer dark border outline
	var outline_color: Color = Color("#1E272E")
	draw_polyline(local_points, outline_color, line_width + 4.0, true)
	_draw_arrowhead(head_pos, head_dir, line_width + 4.0, outline_color)
	
	# 3. Main colored body
	draw_polyline(local_points, arrow_color, line_width, true)
	_draw_arrowhead(head_pos, head_dir, line_width, arrow_color)
	
	# Draw rounded caps at tail
	draw_circle(local_points[0], line_width * 0.5, arrow_color)

func _draw_arrowhead(pos: Vector2, dir: Vector2, width: float, color: Color) -> void:
	var perp: Vector2 = Vector2(-dir.y, dir.x)
	var head_len: float = width * 1.6
	var head_span: float = width * 1.3
	
	var tip: Vector2 = pos + dir * (head_len * 0.5)
	var base_center: Vector2 = pos - dir * (head_len * 0.5)
	var left_pt: Vector2 = base_center + perp * head_span
	var right_pt: Vector2 = base_center - perp * head_span
	
	var triangle = PackedVector2Array([tip, left_pt, right_pt])
	draw_colored_polygon(triangle, color)

func contains_point(global_pos: Vector2, tolerance: float = 24.0) -> bool:
	var local_p: Vector2 = to_local(global_pos)
	for i in range(local_points.size() - 1):
		var p1 = local_points[i]
		var p2 = local_points[i + 1]
		var dist = _dist_to_segment(local_p, p1, p2)
		if dist <= (line_width * 0.5 + tolerance):
			return true
	# Also check arrowhead
	if local_points.size() > 0 and local_p.distance_to(local_points[-1]) <= tolerance * 1.5:
		return true
	return false

func _dist_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var ab_len_sq = ab.length_squared()
	if ab_len_sq == 0.0:
		return p.distance_to(a)
	var t = clampf((p - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	var projection = a + ab * t
	return p.distance_to(projection)

func play_escape_animation(exit_distance: float = 800.0) -> void:
	is_interactive = false
	var dir_f: Vector2 = Vector2(head_dir_vec.x, head_dir_vec.y) * exit_distance
	var target_pos: Vector2 = position + dir_f
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", target_pos, 0.32)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.28)
	tween.finished.connect(func():
		escape_finished.emit(self)
		queue_free()
	)

func play_blocked_animation() -> void:
	var original_pos: Vector2 = position
	var nudge_offset: Vector2 = Vector2(head_dir_vec.x, head_dir_vec.y) * 12.0
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", original_pos + nudge_offset, 0.08)
	tween.tween_property(self, "position", original_pos, 0.12)
	# Brief red flash
	modulate = Color(1.3, 0.4, 0.4, 1.0)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)

func set_hint_highlight(enabled: bool) -> void:
	is_highlighted = enabled
	queue_redraw()
	if enabled:
		var tween = create_tween().set_loops(3)
		tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_SINE)
		tween.finished.connect(func():
			is_highlighted = false
			queue_redraw()
		)
