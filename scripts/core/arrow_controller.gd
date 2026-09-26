class_name ArrowController
extends Node2D

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

signal arrow_tapped(arrow: ArrowController)
signal escape_finished(arrow: ArrowController)

var arrow_id: String = ""
var grid_points: Array[Vector2i] = [] # Ordered path from tail to head
var local_points: PackedVector2Array = []
var original_local_points: PackedVector2Array = []
var head_direction: int = GlobalConstants.Direction.UP
var head_dir_vec: Vector2i = Vector2i(0, -1)
var line_width: float = 12.0
var is_interactive: bool = true
var is_highlighted: bool = false
var glow_intensity: float = 0.0
var arrow_color: Color = Color("#2B7DE9")
var cell_size: float = 60.0

# Extended path tracking for smooth polyline slither escape
var _extended_path: PackedVector2Array = []
var _cum_lens: Array[float] = []
var _total_length: float = 0.0
var _is_animating: bool = false

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
	line_width = clampf(cell_size * 0.32, 5.0, 18.0)
	
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
		
	original_local_points = local_points.duplicate()
	_build_extended_path(1400.0)
	queue_redraw()

func _build_extended_path(exit_dist: float) -> void:
	if original_local_points.size() < 2:
		return
		
	_extended_path = original_local_points.duplicate()
	var exit_dir: Vector2 = Vector2(head_dir_vec.x, head_dir_vec.y).normalized()
	var exit_tip: Vector2 = original_local_points[-1] + exit_dir * exit_dist
	_extended_path.append(exit_tip)
	
	_cum_lens.clear()
	_cum_lens.append(0.0)
	var cur: float = 0.0
	for i in range(_extended_path.size() - 1):
		cur += _extended_path[i].distance_to(_extended_path[i + 1])
		_cum_lens.append(cur)
		if i == original_local_points.size() - 2:
			_total_length = cur

func _draw() -> void:
	if local_points.size() < 2:
		return
		
	var head_pos: Vector2 = local_points[-1]
	var prev_pos: Vector2 = local_points[-2]
	var head_dir: Vector2 = (head_pos - prev_pos).normalized()
	if head_dir.length_squared() < 0.0001:
		head_dir = Vector2(head_dir_vec.x, head_dir_vec.y).normalized()
		
	var outline_color: Color = Color("#1E272E")
	var outline_extra: float = clampf(cell_size * 0.08, 1.8, 4.0)
	var outline_width: float = line_width + outline_extra
	
	# 1. Hint Glow (if active)
	if is_highlighted or glow_intensity > 0.0:
		var glow_w: float = line_width + 8.0 + glow_intensity * 6.0
		var glow_col: Color = Color(GlobalConstants.COLOR_ACCENT.r, GlobalConstants.COLOR_ACCENT.g, GlobalConstants.COLOR_ACCENT.b, 0.4 + glow_intensity * 0.4)
		draw_polyline(local_points, glow_col, glow_w, true)
		draw_circle(head_pos, glow_w * 0.75, glow_col)
		draw_circle(local_points[0], glow_w * 0.5, glow_col)
		
	# 2. Outer dark border outline (polyline + head + rounded tail cap)
	draw_polyline(local_points, outline_color, outline_width, true)
	_draw_arrowhead(head_pos, head_dir, outline_width, outline_color)
	draw_circle(local_points[0], outline_width * 0.5, outline_color)
	
	# 3. Main colored body (polyline + head + rounded tail cap)
	draw_polyline(local_points, arrow_color, line_width, true)
	_draw_arrowhead(head_pos, head_dir, line_width, arrow_color)
	draw_circle(local_points[0], line_width * 0.5, arrow_color)

func _draw_arrowhead(pos: Vector2, dir: Vector2, width: float, color: Color) -> void:
	var perp: Vector2 = Vector2(-dir.y, dir.x)
	var head_len: float = width * 1.5
	var head_span: float = width * 1.25
	
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

var _active_tween: Tween

## Smooth polyline slither escape animation along track
func play_escape_animation(exit_distance: float = 1200.0) -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	is_interactive = false
	_is_animating = true
	
	_build_extended_path(exit_distance)
	
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD)
	_active_tween.set_ease(Tween.EASE_IN)
	_active_tween.tween_method(_on_escape_step, 0.0, 1.0, 0.34)
	_active_tween.parallel().tween_property(self, "modulate:a", 0.0, 0.12).set_delay(0.22)
	_active_tween.finished.connect(func():
		escape_finished.emit(self)
		queue_free()
	)

func _on_escape_step(progress: float) -> void:
	if _cum_lens.size() < 2:
		return
	var total_dist = _cum_lens[-1]
	var advance = progress * total_dist
	var s_tail = advance
	# Dynamic forward stretch for an energetic launch feel
	var stretch = 1.0 + sin(progress * PI) * 0.12
	var s_head = minf(_total_length * stretch + advance, total_dist)
	
	local_points = _get_sub_polyline(s_tail, s_head, _extended_path, _cum_lens)
	queue_redraw()

## Bonk & elastic spring along the arrow's own track when blocked
func play_blocked_animation() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	is_interactive = false
	_is_animating = true
	
	if _cum_lens.is_empty():
		_build_extended_path(200.0)
		
	var max_nudge: float = minf(12.0, cell_size * 0.18)
	_active_tween = create_tween()
	# 1. Bonk forward along track
	_active_tween.tween_method(_on_blocked_step, 0.0, max_nudge, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# 2. Elastic spring back along track
	_active_tween.tween_method(_on_blocked_step, max_nudge, 0.0, 0.16).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	# 3. Crisp red highlight flash
	modulate = Color(1.35, 0.35, 0.35, 1.0)
	_active_tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.22)
	_active_tween.finished.connect(func():
		_is_animating = false
		is_interactive = true
		local_points = original_local_points.duplicate()
		modulate = Color.WHITE
		queue_redraw()
	)

func _on_blocked_step(nudge: float) -> void:
	if _cum_lens.size() < 2:
		return
	var s_tail = nudge * 0.3 # slight body compression
	var s_head = _total_length + nudge # head bonks forward into obstacle
	local_points = _get_sub_polyline(s_tail, s_head, _extended_path, _cum_lens)
	queue_redraw()

func set_hint_highlight(enabled: bool) -> void:
	is_highlighted = enabled
	queue_redraw()
	if enabled:
		var tween = create_tween().set_loops(3)
		tween.tween_property(self, "glow_intensity", 1.0, 0.25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "glow_intensity", 0.0, 0.25).set_trans(Tween.TRANS_SINE)
		tween.finished.connect(func():
			is_highlighted = false
			glow_intensity = 0.0
			queue_redraw()
		)

## Arc-length sampling along polyline
func _sample_path(s: float, path: PackedVector2Array, cum_lens: Array[float]) -> Vector2:
	if s <= 0.0:
		return path[0]
	if s >= cum_lens[-1]:
		return path[-1]
	for i in range(cum_lens.size() - 1):
		if s <= cum_lens[i + 1]:
			var seg_start = cum_lens[i]
			var seg_len = cum_lens[i + 1] - seg_start
			if seg_len <= 0.0001:
				return path[i]
			var t = (s - seg_start) / seg_len
			return path[i].lerp(path[i + 1], t)
	return path[-1]

## Extracts the sub-polyline between distances s_start and s_end
func _get_sub_polyline(
	s_start: float,
	s_end: float,
	path: PackedVector2Array,
	cum_lens: Array[float]
) -> PackedVector2Array:
	var result = PackedVector2Array()
	if path.size() < 2 or cum_lens.size() < 2:
		return result
		
	var full_dist = cum_lens[-1]
	s_start = clampf(s_start, 0.0, full_dist)
	s_end = clampf(s_end, s_start + 1.0, full_dist)
	
	var p_start = _sample_path(s_start, path, cum_lens)
	result.append(p_start)
	
	for i in range(path.size()):
		var v_dist = cum_lens[i]
		if v_dist > s_start + 0.5 and v_dist < s_end - 0.5:
			result.append(path[i])
			
	var p_end = _sample_path(s_end, path, cum_lens)
	if p_end.distance_to(result[-1]) > 0.5:
		result.append(p_end)
	elif result.size() == 1:
		var exit_dir = Vector2(head_dir_vec.x, head_dir_vec.y).normalized()
		result.append(p_end + exit_dir * 2.0)
		
	return result
