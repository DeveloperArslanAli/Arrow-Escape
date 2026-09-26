class_name PathValidator
extends RefCounted

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

## Determines whether a winding arrow with points can escape given current occupancy
static func can_arrow_escape_polyline(
	arrow_points: Array,
	arrow_id: String,
	occupancy: Dictionary,
	grid_size: Vector2i
) -> bool:
	if arrow_points.size() < 2:
		return false
		
	var head: Vector2i = arrow_points[-1]
	var prev: Vector2i = arrow_points[-2]
	var dir_vec: Vector2i = head - prev
	
	var current: Vector2i = head + dir_vec
	while current.x >= 0 and current.x < grid_size.x and current.y >= 0 and current.y < grid_size.y:
		if occupancy.has(current) and occupancy[current] != null:
			var blocker = occupancy[current]
			var blocker_id: String = ""
			if blocker is Dictionary:
				blocker_id = str(blocker.get("id", ""))
			elif "arrow_id" in blocker:
				blocker_id = str(blocker.arrow_id)
			elif blocker is String:
				blocker_id = blocker
				
			# If occupied by another arrow, blocked!
			if blocker_id != arrow_id:
				return false
		current += dir_vec
		
	return true

## Single-point legacy check for backwards compatibility
static func can_arrow_escape(
	start_pos: Vector2i,
	direction: int,
	occupancy: Dictionary,
	grid_size: Vector2i
) -> bool:
	if not GlobalConstants.DIRECTION_VECTORS.has(direction):
		return false
	var dir_vec: Vector2i = GlobalConstants.DIRECTION_VECTORS[direction]
	var current: Vector2i = start_pos + dir_vec
	while current.x >= 0 and current.x < grid_size.x and current.y >= 0 and current.y < grid_size.y:
		if occupancy.has(current) and occupancy[current] != null:
			return false
		current += dir_vec
	return true
