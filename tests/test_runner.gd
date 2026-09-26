extends Node

const TestGridPath = preload("res://tests/test_grid_path.gd")
const TestSolver = preload("res://tests/test_solver.gd")
const TestLevels = preload("res://tests/test_levels.gd")
const TestPersistence = preload("res://tests/test_persistence.gd")

const TestClickInput = preload("res://tests/test_click_input.gd")
const TestArrowMotion = preload("res://tests/test_arrow_motion.gd")

func _ready() -> void:
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
		
	# Suite 5: Click Input & Arrow Movement Verification
	print("--> Running TestClickInput (Tap & Motion Verification)...")
	if await TestClickInput.run(self):
		print("    [PASS] TestClickInput (Arrow clicking and movement verified)")
		passed += 1
	else:
		print("    [FAIL] TestClickInput")
		failed += 1
		
	# Suite 6: Polyline Slither Animation & Centering
	print("--> Running TestArrowMotion (Slither & Center Alignment)...")
	if await TestArrowMotion.run(self):
		print("    [PASS] TestArrowMotion (Smooth slither motion verified)")
		passed += 1
	else:
		print("    [FAIL] TestArrowMotion")
		failed += 1
		
	print("\n=======================================================")
	print("TEST RUN COMPLETE: %d Passed, %d Failed" % [passed, failed])
	print("=======================================================\n")
	
	if failed == 0:
		get_tree().quit(0)
	else:
		get_tree().quit(1)
