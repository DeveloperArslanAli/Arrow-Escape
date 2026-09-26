class_name SolverEngine
extends RefCounted

const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")

## Solves the puzzle using Depth-First Search with transposition memoization.
## Returns Array of arrow IDs representing a complete valid solution, or empty Array if unsolvable.
static func solve_puzzle(grid_size: Vector2i, arrows: Array) -> Array[String]:
	var occupancy: Dictionary = {}
	for item in arrows:
		var col: int = int(item["column"])
		var row: int = int(item["row"])
		occupancy[Vector2i(col, row)] = item
	
	var solution: Array[String] = []
	var visited_states: Dictionary = {}
	
	if _search(grid_size, occupancy, arrows.size(), solution, visited_states):
		return solution
	return []

static func _search(
	grid_size: Vector2i,
	occupancy: Dictionary,
	remaining_count: int,
	solution: Array[String],
	visited: Dictionary
) -> bool:
	if remaining_count == 0:
		return true # Solution reached!
		
	var state_key: int = _compute_state_hash(occupancy)
	if visited.has(state_key):
		return false
	visited[state_key] = true
	
	var removable_coords: Array[Vector2i] = PathValidator.get_removable_arrows(occupancy, grid_size)
	if removable_coords.is_empty():
		return false # Deadlock state
		
	for coord in removable_coords:
		var arrow_item: Dictionary = occupancy[coord]
		var arrow_id: String = str(arrow_item.get("id", ""))
		
		# Apply move
		occupancy.erase(coord)
		solution.append(arrow_id)
		
		if _search(grid_size, occupancy, remaining_count - 1, solution, visited):
			return true
			
		# Backtrack
		occupancy[coord] = arrow_item
		solution.pop_back()
		
	return false

## Simple deterministic hash of active arrow coordinates for memoization
static func _compute_state_hash(occupancy: Dictionary) -> int:
	var h: int = 17
	for coord in occupancy.keys():
		var c: Vector2i = coord
		h = (h * 31 + c.x * 7919 + c.y) & 0x7FFFFFFF
	return h

## Calculates hint: returns the ID of a valid move leading to victory
static func get_hint(grid_size: Vector2i, arrows: Array) -> String:
	var sol: Array[String] = solve_puzzle(grid_size, arrows)
	if not sol.is_empty():
		return sol[0]
	return ""
