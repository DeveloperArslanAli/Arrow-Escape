extends Node

const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const LevelManager = preload("res://scripts/core/level_manager.gd")

signal state_changed(new_state: GlobalConstants.GameState)
signal level_started(level_id: int)
signal level_completed(level_id: int, moves_used: int, stars: int)
signal level_failed(level_id: int)
signal moves_updated(current_moves: int)
signal hearts_changed(current_hearts: int)
signal time_updated(elapsed_seconds: float)

const MAX_HEARTS: int = 3
var current_state: GlobalConstants.GameState = GlobalConstants.GameState.BOOT
var current_level_id: int = 1
var current_moves: int = 0
var current_hearts: int = MAX_HEARTS
var elapsed_time: float = 0.0
var current_level_data: Dictionary = {}
var combo_streak: int = 0

func _ready() -> void:
	change_state(GlobalConstants.GameState.MAIN_MENU)

func _process(delta: float) -> void:
	if current_state == GlobalConstants.GameState.PLAYING:
		elapsed_time += delta
		time_updated.emit(elapsed_time)

func change_state(new_state: GlobalConstants.GameState) -> void:
	current_state = new_state
	state_changed.emit(current_state)

func start_level(level_id: int) -> void:
	current_level_id = level_id
	current_moves = 0
	current_hearts = MAX_HEARTS
	elapsed_time = 0.0
	combo_streak = 0
	AudioManager.reset_combo()
	
	current_level_data = LevelManager.load_level_data(level_id)
	change_state(GlobalConstants.GameState.PLAYING)
	level_started.emit(current_level_id)
	hearts_changed.emit(current_hearts)
	moves_updated.emit(current_moves)

func register_arrow_escaped() -> void:
	current_moves += 1
	combo_streak += 1
	moves_updated.emit(current_moves)
	AudioManager.play_escape(combo_streak)

func deduct_heart() -> void:
	combo_streak = 0
	AudioManager.play_blocked()
	current_hearts = maxi(0, current_hearts - 1)
	hearts_changed.emit(current_hearts)
	
	if current_hearts <= 0:
		change_state(GlobalConstants.GameState.LEVEL_FAILED)
		level_failed.emit(current_level_id)

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
		change_state(GlobalConstants.GameState.MAIN_MENU)

func _calculate_stars() -> int:
	if current_hearts == 3:
		return 3
	elif current_hearts == 2:
		return 2
	return 1
