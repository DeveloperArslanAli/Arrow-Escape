class_name TestSceneTree
extends RefCounted

static func run() -> bool:
	var main_packed = load("res://scenes/core/Main.tscn")
	if main_packed == null:
		push_error("FAIL: Could not load Main.tscn")
		return false
		
	var instance = main_packed.instantiate()
	if instance == null:
		push_error("FAIL: Could not instantiate Main.tscn")
		return false
		
	instance.free()
	return true
