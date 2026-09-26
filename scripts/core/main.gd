extends Node

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

@onready var game_board: Node2D = $GameBoard
@onready var game_hud: Control = $UILayer/GameHUD
@onready var main_menu: Control = $UILayer/MainMenu
@onready var level_select: Control = $UILayer/LevelSelect
@onready var level_complete_modal: Control = $UILayer/LevelCompleteModal
@onready var settings_modal: Control = $UILayer/SettingsModal

func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	game_hud.hint_requested.connect(_on_hint_requested)
	main_menu.open_settings_requested.connect(func(): settings_modal.show())
	_on_state_changed(GameManager.current_state)

func _on_state_changed(new_state: GlobalConstants.GameState) -> void:
	match new_state:
		GlobalConstants.GameState.MAIN_MENU:
			main_menu.show()
			level_select.hide()
			game_board.hide()
			game_hud.hide()
			level_complete_modal.hide()
		GlobalConstants.GameState.LEVEL_SELECT:
			main_menu.hide()
			level_select.show()
			game_board.hide()
			game_hud.hide()
			level_complete_modal.hide()
		GlobalConstants.GameState.PLAYING:
			main_menu.hide()
			level_select.hide()
			game_board.show()
			game_hud.show()
			level_complete_modal.hide()
		GlobalConstants.GameState.LEVEL_COMPLETE:
			main_menu.hide()
			level_select.hide()
			game_board.show()
			game_hud.show()
			level_complete_modal.show()

func _on_hint_requested() -> void:
	if game_board.has_method("trigger_hint"):
		game_board.trigger_hint()
