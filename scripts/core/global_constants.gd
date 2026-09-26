class_name GlobalConstants
extends RefCounted

# Cardinal Directions
enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

# Unit Direction Vectors
const DIRECTION_VECTORS: Dictionary = {
	Direction.UP: Vector2i(0, -1),
	Direction.DOWN: Vector2i(0, 1),
	Direction.LEFT: Vector2i(-1, 0),
	Direction.RIGHT: Vector2i(1, 0)
}

# String to Direction conversion
const STRING_TO_DIRECTION: Dictionary = {
	"up": Direction.UP,
	"down": Direction.DOWN,
	"left": Direction.LEFT,
	"right": Direction.RIGHT
}

# Direction to String conversion
const DIRECTION_TO_STRING: Dictionary = {
	Direction.UP: "up",
	Direction.DOWN: "down",
	Direction.LEFT: "left",
	Direction.RIGHT: "right"
}

# Vector to Direction
static func vector_to_direction(v: Vector2i) -> int:
	if v == Vector2i(0, -1): return Direction.UP
	if v == Vector2i(0, 1): return Direction.DOWN
	if v == Vector2i(-1, 0): return Direction.LEFT
	if v == Vector2i(1, 0): return Direction.RIGHT
	return Direction.UP

# Direction to Rotation Angles (Radians)
const DIRECTION_ROTATIONS: Dictionary = {
	Direction.UP: 0.0,
	Direction.RIGHT: PI * 0.5,
	Direction.DOWN: PI,
	Direction.LEFT: PI * 1.5
}

# Game Lifecycle States
enum GameState {
	BOOT,
	MAIN_MENU,
	LEVEL_SELECT,
	PLAYING,
	PAUSED,
	LEVEL_COMPLETE,
	LEVEL_FAILED,
	SETTINGS
}

# Color Palette Matching "Arrows - Puzzle Escape"
const COLOR_BG: Color = Color("#EBF3FC")
const COLOR_HEADER_BG: Color = Color("#4D90EE")
const COLOR_HEADER_DARK: Color = Color("#356BB3")
const COLOR_BOARD: Color = Color("#E1ECFA")
const COLOR_HEART: Color = Color("#E74C3C")
const COLOR_TEXT_DARK: Color = Color("#2C3E50")
const COLOR_TEXT_MUTED: Color = Color("#7F8C8D")
const COLOR_ACCENT: Color = Color("#F1C40F")
const COLOR_SUCCESS: Color = Color("#2ECC71")

# Curated Vibrant Palette for Winding Arrows
const ARROW_COLORS: Array[Color] = [
	Color("#2B7DE9"), # Blue
	Color("#E04848"), # Red
	Color("#27AE60"), # Green
	Color("#F39C12"), # Orange
	Color("#8E44AD"), # Purple
	Color("#F1C40F"), # Yellow
	Color("#E84393"), # Pink
	Color("#2C3E50"), # Deep Navy
	Color("#00CEC9")  # Cyan / Teal
]
