extends Control

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

signal open_settings_requested()

@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var settings_button: Button = %SettingsButton
@onready var menu_button: Button = %MenuButton

@onready var panel: PanelContainer = $Center/Panel

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	visibility_changed.connect(_on_visibility_changed)
	hide()

func _on_visibility_changed() -> void:
	if visible and panel:
		panel.scale = Vector2(0.65, 0.65)
		panel.pivot_offset = panel.size * 0.5
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3)

func _on_resume_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.change_state(GlobalConstants.GameState.PLAYING)

func _on_restart_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.restart_current_level()

func _on_settings_pressed() -> void:
	AudioManager.play_tap()
	open_settings_requested.emit()

func _on_menu_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.change_state(GlobalConstants.GameState.MAIN_MENU)
