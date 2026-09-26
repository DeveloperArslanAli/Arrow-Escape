const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")
const SolverEngine = preload("res://scripts/solver/solver_engine.gd")

static func run() -> bool:
	var all_passed: bool = true
	var grid_size = Vector2i(3, 3)
	
	# Test 1: Linear chain puzzle: arr_1 (row 0, col 1, up), arr_2 (row 1, col 1, up), arr_3 (row 2, col 1, up)
	var arrows: Array = [
		{ "id": "arr_1", "column": 1, "row": 0, "direction": "up" },
		{ "id": "arr_2", "column": 1, "row": 1, "direction": "up" },
		{ "id": "arr_3", "column": 1, "row": 2, "direction": "up" }
	]
	
	var solution: Array[String] = SolverEngine.solve_puzzle(grid_size, arrows)
	if solution.size() != 3:
		push_error("FAIL: Linear chain puzzle solution length should be 3, got: %d" % solution.size())
		all_passed = false
	elif solution[0] != "arr_1" or solution[1] != "arr_2" or solution[2] != "arr_3":
		push_error("FAIL: Solution order wrong: %s" % str(solution))
		all_passed = false
		
	# Test 2: Deadlock puzzle: two arrows facing each other
	var deadlock_arrows: Array = [
		{ "id": "dead_1", "column": 0, "row": 1, "direction": "right" },
		{ "id": "dead_2", "column": 2, "row": 1, "direction": "left" }
	]
	var dead_sol: Array[String] = SolverEngine.solve_puzzle(grid_size, deadlock_arrows)
	if not dead_sol.is_empty():
		push_error("FAIL: Deadlock puzzle should return empty array, got: %s" % str(dead_sol))
		all_passed = false
		
	# Test 3: Hint generation
	var hint: String = SolverEngine.get_hint(grid_size, arrows)
	if hint != "arr_1":
		push_error("FAIL: Expected hint to be arr_1, got: %s" % hint)
		all_passed = false

	return all_passed
