extends Control

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

@onready var stars_label: Label = %StarsLabel
@onready var stats_label: Label = %StatsLabel
@onready var next_button: Button = %NextButton
@onready var replay_button: Button = %ReplayButton
@onready var menu_button: Button = %MenuButton
@onready var panel_container: PanelContainer = $Center/Panel
@onready var confetti: CPUParticles2D = $ConfettiEffect

func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)
	replay_button.pressed.connect(_on_replay_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	GameManager.level_completed.connect(_on_level_completed)
	hide()

func _on_level_completed(_level_id: int, moves: int, stars: int) -> void:
	var stars_text = ""
	for i in range(stars):
		stars_text += "★ "
	for i in range(3 - stars):
		stars_text += "☆ "
	stars_label.text = stars_text.strip_edges()
	stats_label.text = "Cleared in %d moves!" % moves
	
	var next_id: int = _level_id + 1
	if LevelManager.has_level(next_id):
		next_button.text = "Next Level ▶"
	else:
		next_button.text = "Victory Menu 🏆"
		
	show()
	
	# Juicing: Spring scale animation for victory card
	panel_container.scale = Vector2(0.6, 0.6)
	panel_container.pivot_offset = panel_container.size * 0.5
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel_container, "scale", Vector2(1.0, 1.0), 0.35)
	
	# Juicing: Confetti burst
	if confetti:
		confetti.restart()
		confetti.emitting = true

func _on_next_pressed() -> void:
	AudioManager.play_tap()
	hide()
	var next_id: int = GameManager.current_level_id + 1
	if LevelManager.has_level(next_id):
		GameManager.next_level()
	else:
		GameManager.change_state(GlobalConstants.GameState.MAIN_MENU)

func _on_replay_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.restart_current_level()

func _on_menu_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.change_state(GlobalConstants.GameState.MAIN_MENU)
