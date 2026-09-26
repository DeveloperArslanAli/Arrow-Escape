class_name SolverEngine
extends RefCounted

const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")

## Solves winding or standard arrow puzzles using DFS backtracking.
## Returns Array of arrow IDs representing a complete valid solution, or empty Array if unsolvable.
static func solve_puzzle(grid_size: Vector2i, arrows: Array) -> Array[String]:
	var occupancy: Dictionary = {}
	var normalized_arrows: Array[Dictionary] = []
	
	for item in arrows:
		var norm_a: Dictionary = {}
		norm_a["id"] = str(item.get("id", ""))
		
		if item.has("points"):
			var raw_pts: Array = item["points"]
			var pts: Array[Vector2i] = []
			for p in raw_pts:
				if p is Array:
					pts.append(Vector2i(int(p[0]), int(p[1])))
				elif p is Vector2i:
					pts.append(p)
			norm_a["points"] = pts
			for p in pts:
				occupancy[p] = norm_a
		else:
			# Legacy single point
			var c = int(item.get("column", 0))
			var r = int(item.get("row", 0))
			var d_str = str(item.get("direction", "up"))
			var d = GlobalConstants.STRING_TO_DIRECTION.get(d_str, GlobalConstants.Direction.UP)
			var dir_v = GlobalConstants.DIRECTION_VECTORS[d]
			# Convert to 2-point segment [c - dir_v, c]
			var pts: Array[Vector2i] = [Vector2i(c, r) - dir_v, Vector2i(c, r)]
			norm_a["points"] = pts
			occupancy[Vector2i(c, r)] = norm_a
			
		normalized_arrows.append(norm_a)
		
	var solution: Array[String] = []
	var visited: Dictionary = {}
	
	if _search(grid_size, occupancy, normalized_arrows, normalized_arrows.size(), solution, visited):
		return solution
	return []

static func _search(
	grid_size: Vector2i,
	occupancy: Dictionary,
	active_arrows: Array[Dictionary],
	remaining_count: int,
	solution: Array[String],
	visited: Dictionary
) -> bool:
	if remaining_count == 0:
		return true
		
	var state_key: int = _compute_hash(active_arrows)
	if visited.has(state_key):
		return false
	visited[state_key] = true
	
	# Find removable arrows
	var removable: Array[Dictionary] = []
	for a in active_arrows:
		if PathValidator.can_arrow_escape_polyline(a["points"], a["id"], occupancy, grid_size):
			removable.append(a)
			
	if removable.is_empty():
		return false
		
	for candidate in removable:
		var pts: Array[Vector2i] = candidate["points"]
		var c_id: String = candidate["id"]
		
		# Erase candidate cells from occupancy
		for p in pts:
			occupancy.erase(p)
		active_arrows.erase(candidate)
		solution.append(c_id)
		
		if _search(grid_size, occupancy, active_arrows, remaining_count - 1, solution, visited):
			return true
			
		# Backtrack
		for p in pts:
			occupancy[p] = candidate
		active_arrows.append(candidate)
		solution.pop_back()
		
	return false

static func _compute_hash(active_arrows: Array[Dictionary]) -> int:
	var h: int = 0
	for a in active_arrows:
		h ^= a["id"].hash()
	return h

static func get_hint(grid_size: Vector2i, arrows: Array) -> String:
	var sol: Array[String] = solve_puzzle(grid_size, arrows)
	if not sol.is_empty():
		return sol[0]
	return ""
