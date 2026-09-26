const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")
const SolverEngine = preload("res://scripts/solver/solver_engine.gd")

static func run() -> bool:
	var dir = DirAccess.open("res://data/levels")
	if dir == null:
		push_error("FAIL: Could not open res://data/levels directory")
		return false
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var all_passed: bool = true
	var level_count: int = 0
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			level_count += 1
			var file_path = "res://data/levels/" + file_name
			if not _validate_level_file(file_path):
				all_passed = false
		file_name = dir.get_next()
		
	if level_count == 0:
		push_error("FAIL: No level files found in res://data/levels")
		return false
		
	print("Verified %d packaged levels successfully." % level_count)
	return all_passed

static func _validate_level_file(path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("FAIL: Cannot open %s" % path)
		return false
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		push_error("FAIL: Invalid JSON in %s" % path)
		return false
		
	var data: Dictionary = json.data
	if not data.has("grid_size") or not data.has("arrows"):
		push_error("FAIL: Missing grid_size or arrows in %s" % path)
		return false
		
	var rows: int = int(data["grid_size"]["rows"])
	var cols: int = int(data["grid_size"]["columns"])
	var grid_size = Vector2i(cols, rows)
	var arrows: Array = data["arrows"]
	
	var occupied_coords: Dictionary = {}
	for arrow in arrows:
		var r: int = int(arrow["row"])
		var c: int = int(arrow["column"])
		var coord = Vector2i(c, r)
		
		# Bounds check
		if r < 0 or r >= rows or c < 0 or c >= cols:
			push_error("FAIL: Arrow %s out of bounds in %s" % [arrow.get("id", ""), path])
			return false
			
		# Duplicate check
		if occupied_coords.has(coord):
			push_error("FAIL: Duplicate arrow coordinate (%d, %d) in %s" % [c, r, path])
			return false
		occupied_coords[coord] = true
		
		# Direction check
		var dir_str: String = str(arrow.get("direction", ""))
		if not GlobalConstants.STRING_TO_DIRECTION.has(dir_str):
			push_error("FAIL: Invalid direction '%s' in %s" % [dir_str, path])
			return false
			
	# Solvability check
	var solution: Array[String] = SolverEngine.solve_puzzle(grid_size, arrows)
	if solution.is_empty() and not arrows.is_empty():
		push_error("FAIL: Level %s is mathematically UNSOLVABLE!" % path)
		return false
		
	return true
