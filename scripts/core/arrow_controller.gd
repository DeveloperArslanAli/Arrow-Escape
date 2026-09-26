class_name ArrowController
extends Node2D

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

signal arrow_tapped(arrow: ArrowController)
signal escape_finished(arrow: ArrowController)

var arrow_id: String = ""
var grid_coord: Vector2i = Vector2i.ZERO
var direction: int = GlobalConstants.Direction.UP
var arrow_size: float = 64.0
var is_interactive: bool = true
var is_highlighted: bool = false

var arrow_color: Color = GlobalConstants.COLOR_ARROW_PRIMARY
var accent_color: Color = GlobalConstants.COLOR_ACCENT

func _ready() -> void:
	queue_redraw()

func setup(id: String, coord: Vector2i, dir: int, cell_size: float) -> void:
	arrow_id = id
	grid_coord = coord
	direction = dir
	arrow_size = cell_size * 0.78
	rotation = GlobalConstants.DIRECTION_ROTATIONS.get(direction, 0.0)
	queue_redraw()

func _draw() -> void:
	var s: float = arrow_size
	var half_s: float = s * 0.5
	
	# Background glow if highlighted (Hint)
	if is_highlighted:
		draw_circle(Vector2.ZERO, half_s * 1.3, Color(accent_color.r, accent_color.g, accent_color.b, 0.45))
		draw_arc(Vector2.ZERO, half_s * 1.25, 0, TAU, 32, accent_color, 4.0, true)
	
	# Draw arrow body
	# Pointing UP by default, rotation handles other angles
	var head_len: float = s * 0.5
	var shaft_width: float = s * 0.32
	var half_shaft: float = shaft_width * 0.5
	var shaft_bottom: float = half_s
	var shaft_top: float = -half_s + head_len
	
	var head_tip: Vector2 = Vector2(0, -half_s)
	var head_left: Vector2 = Vector2(-half_s, shaft_top)
	var head_right: Vector2 = Vector2(half_s, shaft_top)
	
	# Arrow Polygon
	var points: PackedVector2Array = [
		head_tip,
		head_right,
		Vector2(half_shaft, shaft_top),
		Vector2(half_shaft, shaft_bottom),
		Vector2(-half_shaft, shaft_bottom),
		Vector2(-half_shaft, shaft_top),
		head_left
	]
	
	# Anti-aliased filled polygon
	draw_colored_polygon(points, arrow_color)
	# Subtle outline
	draw_polyline(points, GlobalConstants.COLOR_TEXT_DARK, 2.5, true)

func play_escape_animation(exit_distance: float = 700.0) -> void:
	is_interactive = false
	var dir_vec: Vector2i = GlobalConstants.DIRECTION_VECTORS[direction]
	var target_offset: Vector2 = Vector2(dir_vec.x, dir_vec.y) * exit_distance
	var target_pos: Vector2 = position + target_offset
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", target_pos, 0.28)
	tween.parallel().tween_property(self, "scale", Vector2(1.15, 1.15), 0.14)
	tween.tween_property(self, "modulate:a", 0.0, 0.12)
	tween.finished.connect(func():
		escape_finished.emit(self)
		queue_free()
	)

func play_blocked_animation() -> void:
	var dir_vec: Vector2i = GlobalConstants.DIRECTION_VECTORS[direction]
	var nudge_offset: Vector2 = Vector2(dir_vec.x, dir_vec.y) * 12.0
	var original_pos: Vector2 = position
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", original_pos + nudge_offset, 0.08)
	tween.tween_property(self, "position", original_pos, 0.14)

func set_hint_highlight(enabled: bool) -> void:
	is_highlighted = enabled
	queue_redraw()
	if enabled:
		var tween = create_tween().set_loops(3)
		tween.tween_property(self, "scale", Vector2(1.12, 1.12), 0.25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_SINE)
		tween.finished.connect(func():
			is_highlighted = false
			queue_redraw()
		)
