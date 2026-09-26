extends Control

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	GameManager.level_failed.connect(_on_level_failed)
	hide()

func _on_level_failed(_level_id: int) -> void:
	show()

func _on_retry_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.restart_current_level()

func _on_menu_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.change_state(GlobalConstants.GameState.MAIN_MENU)
