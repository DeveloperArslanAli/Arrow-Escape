extends Node2D

const GridManagerClass = preload("res://scripts/core/grid_manager.gd")

@onready var grid_manager: GridManager = $GridManager

func _ready() -> void:
	GameManager.level_started.connect(_on_level_started)
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	if GameManager.current_state == GlobalConstants.GameState.PLAYING:
		_load_current_level()

func _on_level_started(_level_id: int) -> void:
	_load_current_level()

func _on_viewport_resized() -> void:
	if GameManager.current_state == GlobalConstants.GameState.PLAYING:
		_load_current_level()

func _load_current_level() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	# Center the board in the screen, leaving top/bottom margins for HUD
	var top_margin: float = 180.0
	var bottom_margin: float = 160.0
	var available_rect = Rect2(
		Vector2(20.0, top_margin),
		Vector2(vp_size.x - 40.0, vp_size.y - top_margin - bottom_margin)
	)
	grid_manager.initialize_board(GameManager.current_level_data, available_rect)

func trigger_hint() -> void:
	grid_manager.show_hint()
