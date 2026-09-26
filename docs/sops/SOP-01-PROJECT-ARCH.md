# SOP-01: Godot 4.x Project Architecture & Coding Standards
## Purpose & Scope
Defines the technical architecture, singleton boundaries, scene tree conventions, and GDScript 2.0 coding standards for the Arrow Escape project (Winding Polyline Edition).

---

## 1. PROJECT GLOBAL CONSTANTS & ENUMS
All shared enums and constants are declared in [scripts/core/global_constants.gd](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/scripts/core/global_constants.gd):

```gdscript
class_name GlobalConstants
extends RefCounted

# Cardinal Directions
enum Direction {
    UP,
    DOWN,
    LEFT,
    RIGHT
}

const DIRECTION_VECTORS: Dictionary = {
    Direction.UP: Vector2i(0, -1),
    Direction.DOWN: Vector2i(0, 1),
    Direction.LEFT: Vector2i(-1, 0),
    Direction.RIGHT: Vector2i(1, 0)
}

const STRING_TO_DIRECTION: Dictionary = {
    "up": Direction.UP,
    "down": Direction.DOWN,
    "left": Direction.LEFT,
    "right": Direction.RIGHT
}

const DIRECTION_TO_STRING: Dictionary = {
    Direction.UP: "up",
    Direction.DOWN: "down",
    Direction.LEFT: "left",
    Direction.RIGHT: "right"
}

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
```

---

## 2. AUTOLOAD SINGLETONS SPECIFICATION

| Singleton Name | Script Path | Responsibility Boundary |
| :--- | :--- | :--- |
| **`GameManager`** | `res://scripts/autoload/game_manager.gd` | Global game state machine (`GameState`), current level data, turn counters, 3-hearts lives tracking, live timer, and lifecycle coordination. |
| **`SaveManager`** | `res://scripts/autoload/save_manager.gd` | Player progress, unlocked levels, star ratings, volume settings, atomic disk persistence via temp-file and rename. |
| **`AudioManager`** | `res://scripts/autoload/audio_manager.gd` | Audio buses (`Master`), procedural tone generator fallback (`AudioStreamWAV`), ascending combo chimes, bump thuds, and mobile haptic triggers. |

---

## 3. SCENE TREE ARCHITECTURE & UI LAYERS

The root gameplay orchestrator is `res://scenes/core/Main.tscn` with script `res://scripts/core/main.gd`:
```text
Main (Node)
├── Background (ColorRect: #EBF3FC)
├── GameBoard (GameBoard.tscn)
│   └── GridManager (GridManager.gd)
│       └── [ArrowController instances dynamically spawned]
└── UILayer (CanvasLayer)
    ├── MainMenu (MainMenu.tscn)
    ├── LevelSelect (LevelSelect.tscn)
    ├── GameHUD (GameHUD.tscn)
    ├── PauseModal (PauseModal.tscn)
    ├── LevelCompleteModal (LevelCompleteModal.tscn)
    ├── LevelFailedModal (LevelFailedModal.tscn)
    └── SettingsModal (SettingsModal.tscn)
```

---

## 4. GDSCRIPT 2.0 CODING STANDARDS

1. **Static Typing Mandatory**:
   ```gdscript
   # Correct:
   var current_level_id: int = 1
   func get_arrow_at(coord: Vector2i) -> ArrowController:
   
   # FORBIDDEN:
   var current_level_id = 1
   func get_arrow_at(coord):
   ```
2. **Signals Always Strongly Typed**:
   ```gdscript
   signal hearts_changed(current_hearts: int)
   signal level_completed(level_id: int, moves_used: int, stars: int)
   signal level_failed(level_id: int)
   ```
3. **Preloads for Standalone Reliability**:
   Use `const ClassName = preload("res://path/to/script.gd")` in tool and test scripts to guarantee compilation independence before project class caches are generated.
4. **Memory Management**:
   Always call `queue_free()` when destroying arrow entities after escape animations finish.
