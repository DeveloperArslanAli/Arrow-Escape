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
	SETTINGS
}

# Arrow Lifecycle States
enum ArrowState {
	IDLE,
	BLOCKED_FEEDBACK,
	ESCAPING,
	REMOVED
}

# Color Palette Design Tokens
const COLOR_BG: Color = Color("#F7F5EF")
const COLOR_BOARD: Color = Color("#E9E8E2")
const COLOR_ARROW_PRIMARY: Color = Color("#5596E6")
const COLOR_ARROW_SECONDARY: Color = Color("#F28B82")
const COLOR_ACCENT: Color = Color("#F6D365")
const COLOR_SUCCESS: Color = Color("#7BCFA6")
const COLOR_TEXT_DARK: Color = Color("#30343B")
const COLOR_TEXT_MUTED: Color = Color("#8C9099")
