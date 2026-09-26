class_name PathValidator
extends RefCounted

const GlobalConstants = preload("res://scripts/core/global_constants.gd")

## Determines whether an arrow at start_pos can escape along direction given current occupancy
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
	
	# Raycast towards the boundary of the board
	while current.x >= 0 and current.x < grid_size.x and current.y >= 0 and current.y < grid_size.y:
		if occupancy.has(current) and occupancy[current] != null:
			return false # Obstacle detected in path
		current += dir_vec
		
	return true # Path is unobstructed to the edge of the board

## Identifies all currently removable arrow coordinates on the board
static func get_removable_arrows(occupancy: Dictionary, grid_size: Vector2i) -> Array[Vector2i]:
	var removable: Array[Vector2i] = []
	for coord in occupancy.keys():
		var arrow_data = occupancy[coord]
		if arrow_data == null:
			continue
			
		var dir: int
		if arrow_data is Dictionary:
			if arrow_data.has("direction"):
				var d_val = arrow_data["direction"]
				if d_val is String:
					dir = GlobalConstants.STRING_TO_DIRECTION.get(d_val, GlobalConstants.Direction.UP)
				else:
					dir = int(d_val)
			else:
				continue
		elif "direction" in arrow_data:
			dir = int(arrow_data.direction)
		else:
			continue
			
		if can_arrow_escape(coord, dir, occupancy, grid_size):
			removable.append(coord)
			
	return removable
