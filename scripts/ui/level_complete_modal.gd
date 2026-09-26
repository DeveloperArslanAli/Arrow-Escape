extends Control

@onready var stars_label: Label = %StarsLabel
@onready var stats_label: Label = %StatsLabel
@onready var next_button: Button = %NextButton
@onready var replay_button: Button = %ReplayButton
@onready var menu_button: Button = %MenuButton

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
	show()

func _on_next_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.next_level()

func _on_replay_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.restart_current_level()

func _on_menu_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.change_state(GlobalConstants.GameState.MAIN_MENU)
