class_name TestPersistence
extends RefCounted

const SaveManagerClass = preload("res://scripts/autoload/save_manager.gd")

static func run() -> bool:
	var all_passed: bool = true
	var sm = SaveManagerClass.new()
	sm.load_data()
	
	# Test 1: Record completion for level 1
	sm.record_level_completion(1, 3, 4)
	if sm.get_highest_unlocked_level() < 2:
		push_error("FAIL: Completing level 1 should unlock level 2")
		all_passed = false
		
	if sm.get_level_stars(1) != 3:
		push_error("FAIL: Expected 3 stars for level 1")
		all_passed = false
		
	# Test 2: Atomic file write check
	if not FileAccess.file_exists(sm.SAVE_PATH):
		push_error("FAIL: Save file does not exist on disk")
		all_passed = false

	sm.free()
	return all_passed
