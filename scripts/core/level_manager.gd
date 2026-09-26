class_name LevelManager
extends RefCounted

const LEVELS_DIR: String = "res://data/levels"

static func get_level_path(level_id: int) -> String:
	return "%s/level_%03d.json" % [LEVELS_DIR, level_id]

static func has_level(level_id: int) -> bool:
	return FileAccess.file_exists(get_level_path(level_id))

static func load_level_data(level_id: int) -> Dictionary:
	var path: String = get_level_path(level_id)
	if not FileAccess.file_exists(path):
		push_warning("Level file not found: %s, falling back to default level." % path)
		return _generate_fallback_level(level_id)
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open level file: %s" % path)
		return _generate_fallback_level(level_id)
		
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var err = json.parse(text)
	if err == OK and json.data is Dictionary:
		return json.data
	else:
		push_error("Failed to parse JSON in %s" % path)
		return _generate_fallback_level(level_id)

static func get_total_levels_count() -> int:
	var dir = DirAccess.open(LEVELS_DIR)
	if dir == null:
		return 0
	dir.list_dir_begin()
	var count = 0
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			count += 1
		file_name = dir.get_next()
	return count

static func _generate_fallback_level(level_id: int) -> Dictionary:
	return {
		"level_id": level_id,
		"difficulty": "tutorial",
		"grid_size": { "rows": 3, "columns": 3 },
		"star_thresholds": { "three_stars": 3, "two_stars": 4 },
		"arrows": [
			{ "id": "arr_1", "row": 0, "column": 0, "direction": "up" },
			{ "id": "arr_2", "row": 1, "column": 1, "direction": "right" },
			{ "id": "arr_3", "row": 2, "column": 2, "direction": "down" }
		]
	}
