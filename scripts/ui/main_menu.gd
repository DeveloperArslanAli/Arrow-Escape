extends Control

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

signal open_settings_requested()

@onready var play_button: Button = %PlayButton
@onready var levels_button: Button = %LevelsButton
@onready var settings_button: Button = %SettingsButton
@onready var progress_label: Label = %ProgressLabel

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	levels_button.pressed.connect(_on_levels_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	visibility_changed.connect(_on_visibility_changed)
	_update_menu()

func _on_visibility_changed() -> void:
	if visible:
		_update_menu()

func _update_menu() -> void:
	var unlocked_lvl: int = SaveManager.get_highest_unlocked_level()
	progress_label.text = "Highest Level: %d" % unlocked_lvl
	play_button.text = "Play Level %d" % unlocked_lvl

func _on_play_pressed() -> void:
	AudioManager.play_tap()
	var current_lvl: int = SaveManager.get_highest_unlocked_level()
	GameManager.start_level(current_lvl)

func _on_levels_pressed() -> void:
	AudioManager.play_tap()
	GameManager.change_state(GlobalConstants.GameState.LEVEL_SELECT)

func _on_settings_pressed() -> void:
	AudioManager.play_tap()
	open_settings_requested.emit()
