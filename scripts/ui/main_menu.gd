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
	var total_levels: int = LevelManager.get_total_levels_count()
	var unlocked_lvl: int = SaveManager.get_highest_unlocked_level()
	var current_play_lvl: int = mini(unlocked_lvl, total_levels)
	if unlocked_lvl > total_levels:
		progress_label.text = "All %d Levels Mastered! 🏆" % total_levels
		play_button.text = "Replay Level %d" % current_play_lvl
	else:
		progress_label.text = "Level %d of %d" % [current_play_lvl, total_levels]
		play_button.text = "Play Level %d" % current_play_lvl

func _on_play_pressed() -> void:
	AudioManager.play_tap()
	var total_levels: int = LevelManager.get_total_levels_count()
	var current_lvl: int = mini(SaveManager.get_highest_unlocked_level(), total_levels)
	GameManager.start_level(current_lvl)

func _on_levels_pressed() -> void:
	AudioManager.play_tap()
	GameManager.change_state(GlobalConstants.GameState.LEVEL_SELECT)

func _on_settings_pressed() -> void:
	AudioManager.play_tap()
	open_settings_requested.emit()
