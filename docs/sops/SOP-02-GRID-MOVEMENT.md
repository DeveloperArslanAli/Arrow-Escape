# SOP-02: Winding Polyline Arrow Movement, Raycasting & Slither Animation
## Purpose & Scope
Governs the core mechanics of winding/bent multi-segment arrows (as in *Arrows – Puzzle Escape*), multi-cell raycasting, slither escape animations, collision recoil, and heart deductions.

---

## 1. DATA STRUCTURE OF A WINDING ARROW

An arrow is defined by an ordered list of integer grid coordinates:
```json
{
  "id": "arrow_1",
  "color": "#27AE60",
  "points": [
    [2, 3],
    [2, 2],
    [3, 2],
    [3, 1]
  ]
}
```
- `points[0]` is the **tail**.
- `points[-1]` is the **head**.
- Head direction vector: $\mathbf{d} = \text{points}[-1] - \text{points}[-2]$.

---

## 2. RAYCAST COLLISION ENGINE

A winding arrow can escape if and only if a discrete ray cast from its arrowhead along $\mathbf{d}$ reaches the edge of the grid without intersecting any cell occupied by any active arrow:

```gdscript
static func can_arrow_escape(arrow_data: Dictionary, occupancy_map: Dictionary, grid_size: Vector2i) -> bool:
    var points: Array = arrow_data["points"]
    if points.size() < 2:
        return false
    var head: Vector2i = points[-1]
    var prev: Vector2i = points[-2]
    var dir: Vector2i = head - prev
    
    var ray_pos: Vector2i = head + dir
    while ray_pos.x >= 0 and ray_pos.x < grid_size.x and ray_pos.y >= 0 and ray_pos.y < grid_size.y:
        if occupancy_map.has(ray_pos) and occupancy_map[ray_pos] != null:
            return false # Intersects another arrow segment!
        ray_pos += dir
    return true
```

---

## 3. COLLISION PENALTY (3 HEARTS)

- When an invalid tap occurs:
  1. The tapped arrow recoils with a sharp jiggle (6px forward, spring back in 0.15s).
  2. `AudioManager.play_blocked()` triggers a warning thud + haptic buzz.
  3. `GameManager.deduct_heart()` decrements hearts: `3 -> 2 -> 1 -> 0`.
  4. At 0 hearts, game triggers `LEVEL_FAILED` modal.

---

## 4. SLITHER ESCAPE ANIMATION

- When path is clear:
  1. Occupancy of all cells in `points` is cleared immediately from `occupancy_map`.
  2. The arrow polyline slithers forward along its head direction out of the screen using a smooth Tween (`0.32s`).
  3. Tail collapses forward into head path until completely off-board.
  4. `AudioManager.play_escape()` triggers ascending combo chime.
