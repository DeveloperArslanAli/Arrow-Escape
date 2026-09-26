extends Control

@onready var sound_check: CheckButton = %SoundCheck
@onready var music_check: CheckButton = %MusicCheck
@onready var haptics_check: CheckButton = %HapticsCheck
@onready var close_button: Button = %CloseButton

@onready var panel: PanelContainer = $Center/Panel

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	sound_check.toggled.connect(_on_sound_toggled)
	music_check.toggled.connect(_on_music_toggled)
	haptics_check.toggled.connect(_on_haptics_toggled)
	
	visibility_changed.connect(_on_visibility_changed)
	_sync_settings_ui()
	hide()

func _on_visibility_changed() -> void:
	if visible:
		_sync_settings_ui()
		if panel:
			panel.scale = Vector2(0.65, 0.65)
			panel.pivot_offset = panel.size * 0.5
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3)

func _sync_settings_ui() -> void:
	var s = SaveManager.save_data.get("settings", {})
	sound_check.button_pressed = s.get("sound_enabled", true)
	music_check.button_pressed = s.get("music_enabled", true)
	haptics_check.button_pressed = s.get("haptics_enabled", true)

func _on_sound_toggled(toggled: bool) -> void:
	SaveManager.save_data["settings"]["sound_enabled"] = toggled
	SaveManager.save_data_atomic()

func _on_music_toggled(toggled: bool) -> void:
	SaveManager.save_data["settings"]["music_enabled"] = toggled
	SaveManager.save_data_atomic()

func _on_haptics_toggled(toggled: bool) -> void:
	SaveManager.save_data["settings"]["haptics_enabled"] = toggled
	SaveManager.save_data_atomic()

func _on_close_pressed() -> void:
	AudioManager.play_tap()
	hide()
