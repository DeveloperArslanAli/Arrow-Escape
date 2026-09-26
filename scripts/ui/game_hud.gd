extends Control

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

signal hint_requested()
signal restart_requested()
signal pause_requested()

@onready var level_label: Label = %LevelLabel
@onready var timer_label: Label = %TimerLabel
@onready var hearts_label: Label = %HeartsLabel
@onready var restart_button: Button = %RestartButton
@onready var pause_button: Button = %PauseButton
@onready var hint_button: Button = %HintButton
@onready var tool_button: Button = %ToolButton

func _ready() -> void:
	GameManager.level_started.connect(_on_level_started)
	GameManager.hearts_changed.connect(_on_hearts_changed)
	GameManager.time_updated.connect(_on_time_updated)
	
	restart_button.pressed.connect(_on_restart_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	hint_button.pressed.connect(_on_hint_pressed)
	tool_button.pressed.connect(_on_tool_pressed)
	
	_update_level_ui(GameManager.current_level_id)
	_on_hearts_changed(GameManager.current_hearts)

func _on_level_started(level_id: int) -> void:
	_update_level_ui(level_id)

func _update_level_ui(level_id: int) -> void:
	level_label.text = "Level %d" % level_id
	timer_label.text = "⏱ 0s"

func _on_hearts_changed(hearts_count: int) -> void:
	var hearts_str = ""
	for i in range(hearts_count):
		hearts_str += "❤️"
	for i in range(3 - hearts_count):
		hearts_str += "🖤"
	hearts_label.text = hearts_str

func _on_time_updated(seconds: float) -> void:
	var sec_int = int(seconds)
	if sec_int < 60:
		timer_label.text = "⏱ %ds" % sec_int
	else:
		var mins = sec_int / 60
		var rem_sec = sec_int % 60
		timer_label.text = "⏱ %d:%02d" % [mins, rem_sec]

func _on_restart_pressed() -> void:
	AudioManager.play_tap()
	restart_requested.emit()
	GameManager.restart_current_level()

func _on_pause_pressed() -> void:
	AudioManager.play_tap()
	pause_requested.emit()
	GameManager.change_state(GlobalConstants.GameState.PAUSED)

func _on_hint_pressed() -> void:
	AudioManager.play_tap()
	hint_requested.emit()

func _on_tool_pressed() -> void:
	AudioManager.play_tap()
	# Tool / hint action
	hint_requested.emit()
