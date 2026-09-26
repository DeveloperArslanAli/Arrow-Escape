class_name ConfettiEffect
extends CPUParticles2D

func _ready() -> void:
	emitting = false
	one_shot = true
	explosiveness = 0.85
	lifetime = 2.2
	amount = 80
	direction = Vector2(0, -1)
	spread = 65.0
	initial_velocity_min = 280.0
	initial_velocity_max = 520.0
	gravity = Vector2(0, 480.0)
	scale_amount_min = 6.0
	scale_amount_max = 12.0
	
	# Color ramp with game theme palette
	var grad = Gradient.new()
	grad.add_point(0.0, Color("#5596E6")) # Blue
	grad.add_point(0.33, Color("#7BCFA6")) # Mint
	grad.add_point(0.66, Color("#F6D365")) # Yellow
	grad.add_point(1.0, Color("#F28B82")) # Coral
	color_ramp = grad

func burst(spawn_pos: Vector2) -> void:
	global_position = spawn_pos
	restart()
	emitting = true
