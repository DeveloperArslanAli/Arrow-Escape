extends Control

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

@onready var panel: PanelContainer = $Center/Panel

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	GameManager.level_failed.connect(_on_level_failed)
	hide()

func _on_level_failed(_level_id: int) -> void:
	show()
	if panel:
		panel.scale = Vector2(0.65, 0.65)
		panel.pivot_offset = panel.size * 0.5
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.35)

func _on_retry_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.restart_current_level()

func _on_menu_pressed() -> void:
	AudioManager.play_tap()
	hide()
	GameManager.change_state(GlobalConstants.GameState.MAIN_MENU)
