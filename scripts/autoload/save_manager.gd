extends Node

const SAVE_PATH: String = "user://arrow_escape_save.json"
const TEMP_PATH: String = "user://arrow_escape_save.tmp"
const BACKUP_PATH: String = "user://arrow_escape_save.bak"
const CURRENT_SCHEMA_VERSION: int = 1

var save_data: Dictionary = {
	"schema_version": CURRENT_SCHEMA_VERSION,
	"highest_unlocked_level": 1,
	"completed_levels": {},
	"settings": {
		"sound_enabled": true,
		"music_enabled": true,
		"haptics_enabled": true,
		"sfx_volume": 1.0,
		"music_volume": 0.8
	}
}

func _ready() -> void:
	load_data()

func get_highest_unlocked_level() -> int:
	return int(save_data.get("highest_unlocked_level", 1))

func is_level_unlocked(level_id: int) -> bool:
	return level_id <= get_highest_unlocked_level()

func get_level_stars(level_id: int) -> int:
	var completed = save_data.get("completed_levels", {})
	var entry = completed.get(str(level_id), null)
	if entry != null and entry is Dictionary:
		return int(entry.get("stars", 0))
	return 0

func record_level_completion(level_id: int, stars: int, moves: int) -> void:
	var completed: Dictionary = save_data.get("completed_levels", {})
	var str_id: String = str(level_id)
	
	var existing_stars: int = 0
	var existing_moves: int = 999999
	if completed.has(str_id):
		existing_stars = int(completed[str_id].get("stars", 0))
		existing_moves = int(completed[str_id].get("best_moves", 999999))
		
	completed[str_id] = {
		"stars": maxi(existing_stars, stars),
		"best_moves": mini(existing_moves, moves),
		"completed_at": Time.get_unix_time_from_system()
	}
	save_data["completed_levels"] = completed
	
	# Unlock next level
	var current_highest: int = int(save_data.get("highest_unlocked_level", 1))
	if level_id >= current_highest:
		save_data["highest_unlocked_level"] = level_id + 1
		
	save_data_atomic()

func save_data_atomic() -> bool:
	var data_string: String = JSON.stringify(save_data, "\t")
	
	# 1. Write to temporary file
	var temp_file = FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if temp_file == null:
		push_error("Failed to write temp save file: %d" % FileAccess.get_open_error())
		return false
	temp_file.store_string(data_string)
	temp_file.close()
	
	# 2. Backup previous save if present
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(SAVE_PATH, BACKUP_PATH)
		
	# 3. Rename temp file to destination save path
	var dir = DirAccess.open("user://")
	if dir != null:
		var err = dir.rename(TEMP_PATH, SAVE_PATH)
		if err != OK:
			push_error("Failed to rename temp save to destination: %d" % err)
			return false
	return true

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		# Fresh game start
		save_data_atomic()
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_recover_from_backup()
		return
		
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(content)
	if parse_result == OK and json.data is Dictionary:
		save_data = json.data
	else:
		push_warning("Corrupted save file detected, recovering from backup...")
		_recover_from_backup()

func _recover_from_backup() -> void:
	if FileAccess.file_exists(BACKUP_PATH):
		var b_file = FileAccess.open(BACKUP_PATH, FileAccess.READ)
		if b_file != null:
			var b_content = b_file.get_as_text()
			b_file.close()
			var json = JSON.new()
			if json.parse(b_content) == OK and json.data is Dictionary:
				save_data = json.data
				save_data_atomic()
				return
	# Default fallback
	save_data = {
		"schema_version": CURRENT_SCHEMA_VERSION,
		"highest_unlocked_level": 1,
		"completed_levels": {},
		"settings": {
			"sound_enabled": true,
			"music_enabled": true,
			"haptics_enabled": true,
			"sfx_volume": 1.0,
			"music_volume": 0.8
		}
	}
	save_data_atomic()
