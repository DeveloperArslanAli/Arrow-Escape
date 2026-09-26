extends SceneTree

const TestGridPath = preload("res://tests/test_grid_path.gd")
const TestSolver = preload("res://tests/test_solver.gd")
const TestLevels = preload("res://tests/test_levels.gd")
const TestPersistence = preload("res://tests/test_persistence.gd")
const TestSceneTree = preload("res://tests/test_scene_tree.gd")

func _init() -> void:
	print("\n=======================================================")
	print("   ARROW ESCAPE — AUTOMATED V&V TEST HARNESS")
	print("=======================================================\n")
	
	var passed: int = 0
	var failed: int = 0
	
	# Suite 1: Path Raycasting & Boundaries
	print("--> Running TestGridPath...")
	if TestGridPath.run():
		print("    [PASS] TestGridPath")
		passed += 1
	else:
		print("    [FAIL] TestGridPath")
		failed += 1
		
	# Suite 2: Backtracking Solver & Deadlock
	print("--> Running TestSolver...")
	if TestSolver.run():
		print("    [PASS] TestSolver")
		passed += 1
	else:
		print("    [FAIL] TestSolver")
		failed += 1
		
	# Suite 3: Packaged Levels & 100% Solvability Audit
	print("--> Running TestLevels (100% Solvability Verification)...")
	if TestLevels.run():
		print("    [PASS] TestLevels (All packaged levels validated)")
		passed += 1
	else:
		print("    [FAIL] TestLevels")
		failed += 1
		
	# Suite 4: Atomic Persistence & Unlocks
	print("--> Running TestPersistence...")
	if TestPersistence.run():
		print("    [PASS] TestPersistence")
		passed += 1
	else:
		print("    [FAIL] TestPersistence")
		failed += 1

	# Suite 5: Full Scene Tree & Autoload Integrity
	print("--> Running TestSceneTree (Full Scene & UI Instantiation)...")
	if TestSceneTree.run():
		print("    [PASS] TestSceneTree")
		passed += 1
	else:
		print("    [FAIL] TestSceneTree")
		failed += 1
		
	print("\n=======================================================")
	print("TEST RUN COMPLETE: %d Passed, %d Failed" % [passed, failed])
	print("=======================================================\n")
	
	if failed == 0:
		quit(0)
	else:
		quit(1)
