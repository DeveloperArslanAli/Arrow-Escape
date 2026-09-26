const GlobalConstants = preload("res://scripts/core/global_constants.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")

static func run() -> bool:
	var all_passed: bool = true
	var grid_size = Vector2i(4, 4)
	
	# Test 1: Empty board - arrow pointing up can escape
	var occ1: Dictionary = {}
	if not PathValidator.can_arrow_escape(Vector2i(1, 2), GlobalConstants.Direction.UP, occ1, grid_size):
		push_error("FAIL: Empty board UP escape failed")
		all_passed = false
		
	# Test 2: Arrow blocked by another arrow above it
	var occ2: Dictionary = {
		Vector2i(1, 1): { "id": "blocker" }
	}
	if PathValidator.can_arrow_escape(Vector2i(1, 2), GlobalConstants.Direction.UP, occ2, grid_size):
		push_error("FAIL: Arrow should be blocked by arrow at (1, 1)")
		all_passed = false
		
	# Test 3: Arrow pointing right with obstacle to the left (should NOT be blocked)
	var occ3: Dictionary = {
		Vector2i(0, 2): { "id": "behind" }
	}
	if not PathValidator.can_arrow_escape(Vector2i(1, 2), GlobalConstants.Direction.RIGHT, occ3, grid_size):
		push_error("FAIL: Obstacle behind arrow should not block forward escape")
		all_passed = false
		
	# Test 4: Arrow on the very edge pointing outwards
	if not PathValidator.can_arrow_escape(Vector2i(3, 2), GlobalConstants.Direction.RIGHT, occ1, grid_size):
		push_error("FAIL: Arrow on right edge pointing right must escape")
		all_passed = false
		
	# Test 5: Arrow pointing down with blocker at the very bottom edge
	var occ5: Dictionary = {
		Vector2i(2, 3): { "id": "bottom_blocker" }
	}
	if PathValidator.can_arrow_escape(Vector2i(2, 0), GlobalConstants.Direction.DOWN, occ5, grid_size):
		push_error("FAIL: Distant blocker at edge should still block")
		all_passed = false

	return all_passed
