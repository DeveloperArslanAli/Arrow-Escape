extends Node

const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const ThemeManager = preload("res://scripts/core/theme_manager.gd")

@onready var background: ColorRect = $Background
@onready var game_board: Node2D = $GameBoard
@onready var ui_layer: CanvasLayer = $UILayer
@onready var game_hud: Control = $UILayer/GameHUD
@onready var main_menu: Control = $UILayer/MainMenu
@onready var level_select: Control = $UILayer/LevelSelect
@onready var level_complete_modal: Control = $UILayer/LevelCompleteModal
@onready var level_failed_modal: Control = $UILayer/LevelFailedModal
@onready var pause_modal: Control = $UILayer/PauseModal
@onready var settings_modal: Control = $UILayer/SettingsModal

func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.level_started.connect(_on_level_started)
	game_hud.hint_requested.connect(_on_hint_requested)
	main_menu.open_settings_requested.connect(func(): settings_modal.show())
	pause_modal.open_settings_requested.connect(func(): settings_modal.show())
	
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)
	
	_on_state_changed(GameManager.current_state)

func _on_level_started(level_id: int) -> void:
	var theme: Dictionary = ThemeManager.get_theme_for_level(level_id)
	var tween = create_tween()
	tween.tween_property(background, "color", theme["bg_color"], 0.35)

func _apply_safe_area() -> void:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var window_size: Vector2i = DisplayServer.window_get_size()
	
	if window_size.y > 0 and safe_area.size.y > 0:
		var top_inset = safe_area.position.y
		if top_inset > 0:
			var top_bar = game_hud.get_node_or_null("TopBar")
			if top_bar is PanelContainer:
				var margin = top_bar.get_node_or_null("Margin")
				if margin is MarginContainer:
					margin.add_theme_constant_override("margin_top", top_inset + 24)

func _on_state_changed(new_state: GlobalConstants.GameState) -> void:
	match new_state:
		GlobalConstants.GameState.MAIN_MENU:
			main_menu.show()
			level_select.hide()
			game_board.hide()
			game_hud.hide()
			pause_modal.hide()
			level_complete_modal.hide()
			level_failed_modal.hide()
		GlobalConstants.GameState.LEVEL_SELECT:
			main_menu.hide()
			level_select.show()
			game_board.hide()
			game_hud.hide()
			pause_modal.hide()
			level_complete_modal.hide()
			level_failed_modal.hide()
		GlobalConstants.GameState.PLAYING:
			main_menu.hide()
			level_select.hide()
			game_board.show()
			game_hud.show()
			pause_modal.hide()
			level_complete_modal.hide()
			level_failed_modal.hide()
		GlobalConstants.GameState.PAUSED:
			main_menu.hide()
			level_select.hide()
			game_board.show()
			game_hud.show()
			pause_modal.show()
			level_complete_modal.hide()
			level_failed_modal.hide()
		GlobalConstants.GameState.LEVEL_COMPLETE:
			main_menu.hide()
			level_select.hide()
			game_board.show()
			game_hud.show()
			pause_modal.hide()
			level_complete_modal.show()
			level_failed_modal.hide()
		GlobalConstants.GameState.LEVEL_FAILED:
			main_menu.hide()
			level_select.hide()
			game_board.show()
			game_hud.show()
			pause_modal.hide()
			level_complete_modal.hide()
			level_failed_modal.show()

func _on_hint_requested() -> void:
	if game_board.has_method("trigger_hint"):
		game_board.trigger_hint()
