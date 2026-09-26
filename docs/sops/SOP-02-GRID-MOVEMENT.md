# SOP-02: Grid Representation, Path Raycasting & Arrow Movement
## Purpose & Scope
Governs the core mechanics of the puzzle: grid layout calculations, touch selection, deterministic path raycasting, escape animations, blocked feedback, and input debounce synchronization.

---

## 1. MATHEMATICAL FORMULATION OF THE BOARD

1. **Grid Space**:
   A board has dimensions $R \times C$ where rows $r \in [0, R-1]$ and columns $c \in [0, C-1]$.
   Origin `(0, 0)` is the **top-left** cell.

2. **Occupancy Grid**:
   Represented by a 2D Dictionary or Array:
   `grid_occupancy[Vector2i(c, r)] = ArrowController` or `null`.

3. **Direction Vectors**:
   - `UP` $\rightarrow \vec{d} = (0, -1)$
   - `DOWN` $\rightarrow \vec{d} = (0, 1)$
   - `LEFT` $\rightarrow \vec{d} = (-1, 0)$
   - `RIGHT` $\rightarrow \vec{d} = (1, 0)$

---

## 2. DETERMINISTIC PATH RAYCASTING ALGORITHM

An arrow at $(c_0, r_0)$ pointing in direction $\vec{d} = (dc, dr)$ can escape **if and only if** every subsequent cell along its ray is empty until it crosses the boundary of the board:

```gdscript
func can_arrow_escape(start_pos: Vector2i, direction: GlobalConstants.Direction, occupancy: Dictionary, grid_size: Vector2i) -> bool:
    var dir_vec: Vector2i = GlobalConstants.DIRECTION_VECTORS[direction]
    var current: Vector2i = start_pos + dir_vec
    
    while current.x >= 0 and current.x < grid_size.x and current.y >= 0 and current.y < grid_size.y:
        if occupancy.has(current) and occupancy[current] != null:
            return false # Path blocked by another arrow
        current += dir_vec
        
    return true # Path is unobstructed to the edge of the board
```

---

## 3. INPUT GATEKEEPER & RACE PREVENTION

To prevent rapid-tap glitches and state corruption:
1. `GridManager.is_animating: bool = false`.
2. When the player taps any arrow:
   ```gdscript
   func handle_arrow_tapped(arrow: ArrowController) -> void:
       if is_input_locked or is_animating:
           return # Ignore tap during active tween
       
       if PathValidator.can_arrow_escape(arrow.grid_coord, arrow.direction, grid_occupancy, grid_size):
           execute_escape(arrow)
       else:
           execute_blocked_feedback(arrow)
   ```
3. **Atomic Occupancy Clearing**:
   The cell `grid_occupancy[arrow.grid_coord]` is cleared to `null` **immediately** at the start of the escape tween, so arrows behind it can subsequently be evaluated without waiting for the animation to completely vanish from the scene tree.

---

## 4. ANIMATION SPECIFICATIONS

- **Escape Movement**:
  - Distance: Moves along $\vec{d}$ beyond the board viewport boundary (offset: ~600px).
  - Duration: 0.28 seconds.
  - Transition: `Tween.TRANS_CUBIC`, Ease: `Tween.EASE_IN`.
  - SFX: `sfx_escape.play()` (pitch scaled slightly based on combo streak).
- **Blocked Movement**:
  - Subtle forward nudge (8px) followed by an elastic bounce back to rest.
  - Duration: 0.16 seconds.
  - SFX: `sfx_blocked.play()` (soft low-frequency thump).
  - Haptic: Gentle micro-vibration (5ms).
