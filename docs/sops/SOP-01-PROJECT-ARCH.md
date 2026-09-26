# SOP-01: Godot 4.x Project Architecture & Coding Standards
## Purpose & Scope
Defines the technical architecture, singleton boundaries, scene tree conventions, and GDScript 2.0 coding standards for the Arrow Escape project.

---

## 1. PROJECT GLOBAL CONSTANTS & ENUMS
All shared enums and constants are declared in `res://scripts/core/global_constants.gd`:

```gdscript
class_name GlobalConstants

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

enum GameState {
    BOOT,
    MAIN_MENU,
    LEVEL_SELECT,
    PLAYING,
    PAUSED,
    LEVEL_COMPLETE,
    SETTINGS
}

enum ArrowState {
    IDLE,
    BLOCKED_FEEDBACK,
    ESCAPING,
    REMOVED
}
```

---

## 2. AUTOLOAD SINGLETONS SPECIFICATION

| Singleton Name | Script Path | Responsibility Boundary |
| :--- | :--- | :--- |
| **`GameManager`** | `res://scripts/autoload/game_manager.gd` | Global game state machine, current level loading coordination, turn counters, scene switching. |
| **`SaveManager`** | `res://scripts/autoload/save_manager.gd` | Player progress, unlocked levels, star ratings, volume settings, atomic disk persistence. |
| **`AudioManager`** | `res://scripts/autoload/audio_manager.gd` | Audio buses (`Master`, `SFX`, `Music`), SFX pooling, procedural tone generator fallback, haptic triggers. |

---

## 3. GDSCRIPT 2.0 CODING STANDARDS

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
   signal arrow_escape_started(arrow_id: String, start_coord: Vector2i)
   signal arrow_escape_completed(arrow_id: String)
   signal level_completed(level_id: int, moves_used: int)
   ```
3. **Node Referencing**:
   - Use `@onready` with explicit types:
     ```gdscript
     @onready var grid_container: Node2D = $GridContainer
     @onready var anim_player: AnimationPlayer = $AnimationPlayer
     ```
   - Avoid hardcoded paths; use `Unique Names` (`%NodeName`) for critical UI nodes.
4. **Memory Management**:
   - Always disconnect dynamic signals on `_exit_tree()` if connected via code.
   - Use `queue_free()` when destroying arrow entities after escape animations finish.
