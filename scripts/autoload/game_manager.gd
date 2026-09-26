extends Node

const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const LevelManager = preload("res://scripts/core/level_manager.gd")

signal state_changed(new_state: GlobalConstants.GameState)
signal level_started(level_id: int)
signal level_completed(level_id: int, moves_used: int, stars: int)
signal moves_updated(current_moves: int)

var current_state: GlobalConstants.GameState = GlobalConstants.GameState.BOOT
var current_level_id: int = 1
var current_moves: int = 0
var current_level_data: Dictionary = {}
var combo_streak: int = 0

func _ready() -> void:
	change_state(GlobalConstants.GameState.MAIN_MENU)

func change_state(new_state: GlobalConstants.GameState) -> void:
	current_state = new_state
	state_changed.emit(current_state)

func start_level(level_id: int) -> void:
	current_level_id = level_id
	current_moves = 0
	combo_streak = 0
	AudioManager.reset_combo()
	
	current_level_data = LevelManager.load_level_data(level_id)
	change_state(GlobalConstants.GameState.PLAYING)
	level_started.emit(current_level_id)

func increment_moves() -> void:
	current_moves += 1
	moves_updated.emit(current_moves)

func register_arrow_escaped() -> void:
	combo_streak += 1
	AudioManager.play_escape(combo_streak)

func register_arrow_blocked() -> void:
	combo_streak = 0
	AudioManager.play_blocked()

func notify_all_arrows_cleared() -> void:
	var stars: int = _calculate_stars()
	SaveManager.record_level_completion(current_level_id, stars, current_moves)
	AudioManager.play_victory()
	change_state(GlobalConstants.GameState.LEVEL_COMPLETE)
	level_completed.emit(current_level_id, current_moves, stars)

func restart_current_level() -> void:
	start_level(current_level_id)

func next_level() -> void:
	var next_id: int = current_level_id + 1
	if LevelManager.has_level(next_id):
		start_level(next_id)
	else:
		# Return to main menu if reached end of content
		change_state(GlobalConstants.GameState.MAIN_MENU)

func _calculate_stars() -> int:
	var thresholds = current_level_data.get("star_thresholds", {})
	var three_star_limit: int = int(thresholds.get("three_stars", 999))
	var two_star_limit: int = int(thresholds.get("two_stars", 999))
	
	if current_moves <= three_star_limit:
		return 3
	elif current_moves <= two_star_limit:
		return 2
	return 1
