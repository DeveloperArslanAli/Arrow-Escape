extends Control

signal hint_requested()
signal restart_requested()
signal menu_requested()

@onready var level_label: Label = %LevelLabel
@onready var moves_label: Label = %MovesLabel
@onready var restart_button: Button = %RestartButton
@onready var hint_button: Button = %HintButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	GameManager.level_started.connect(_on_level_started)
	GameManager.moves_updated.connect(_on_moves_updated)
	
	restart_button.pressed.connect(_on_restart_pressed)
	hint_button.pressed.connect(_on_hint_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	_update_hud(GameManager.current_level_id, GameManager.current_moves)

func _on_level_started(level_id: int) -> void:
	_update_hud(level_id, 0)

func _on_moves_updated(moves: int) -> void:
	moves_label.text = "Moves: %d" % moves

func _update_hud(level_id: int, moves: int) -> void:
	level_label.text = "Level %d" % level_id
	moves_label.text = "Moves: %d" % moves

func _on_restart_pressed() -> void:
	AudioManager.play_tap()
	restart_requested.emit()
	GameManager.restart_current_level()

func _on_hint_pressed() -> void:
	AudioManager.play_tap()
	hint_requested.emit()

func _on_menu_pressed() -> void:
	AudioManager.play_tap()
	menu_requested.emit()
	GameManager.change_state(GlobalConstants.GameState.MAIN_MENU)
