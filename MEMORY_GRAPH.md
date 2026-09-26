# 🧠 MEMORY GRAPH & KNOWLEDGE TOPOLOGY
## Arrow Escape (Winding Paths Edition — "Arrows Puzzle Escape" Style)

> **Document Version:** 2.0.0  
> **Game Archetype:** Winding/Bent Arrow Puzzle (Inspired by *Arrows – Puzzle Escape*)  
> **Engine:** Godot Engine 4.x (GDScript) · Mobile Portrait  
> **Key Mechanics:** Multi-segment orthogonal winding arrows, 3-Hearts life system, live timer, slither escape, collision recoil, and 100% solvability guarantee.

---

## 1. AGENT EXECUTION ROUTER (V2.0)

| Task Domain | Primary SOP | Key Source Files | Verification Target |
| :--- | :--- | :--- | :--- |
| **Winding Arrow / Polyline Raycast / Slither** | `SOP-02-GRID-MOVEMENT.md` | `scripts/core/arrow_controller.gd`<br>`scripts/core/grid_manager.gd`<br>`scripts/core/path_validator.gd` | `res://tests/test_grid_path.gd` |
| **Polyline Solvability & Hint Solver** | `SOP-03-SOLVER-ALGORITHM.md` | `scripts/solver/solver_engine.gd` | `res://tests/test_solver.gd` |
| **Winding Level JSON Schema & Packs** | `SOP-04-LEVEL-MANAGEMENT.md` | `data/levels/`<br>`scripts/core/level_manager.gd` | `res://tests/test_levels.gd` |
| **Hearts (3 Lives), Timer, Game FSM** | `SOP-05-STATE-LIFECYCLE.md` | `scripts/autoload/game_manager.gd` | `res://tests/TestRunner.tscn` |
| **Top Sky-Blue Header, HUD Pills, Bottom Bar** | `SOP-06-UI-DESIGN-SYSTEM.md` | `scenes/ui/GameHUD.tscn`<br>`scripts/ui/game_hud.gd` | Runtime Headless UI Test |
| **Audio, Synth, Slither & Bump Haptics** | `SOP-07-AUDIO-HAPTICS.md` | `scripts/autoload/audio_manager.gd` | Audio Bus triggers |
| **Atomic Persistence (Hearts, Levels, Stars)** | `SOP-08-PERSISTENCE-ATOMIC.md` | `scripts/autoload/save_manager.gd` | `res://tests/test_persistence.gd` |

---

## 2. COMPONENT INVARIANTS (WINDING ARROW EDITION)

1. **Polyline Path Continuity**:
   Every arrow $A_i$ consists of an ordered sequence of grid vertices:
   $$\text{Path}(A_i) = \langle p_0, p_1, \dots, p_k \rangle, \quad p_j = (c_j, r_j)$$
   where consecutive points are strictly orthogonally adjacent: $\|p_{j+1} - p_j\|_1 = 1$.
2. **Arrowhead Orientation**:
   The arrow head is located at $p_k$ pointing in direction:
   $$\mathbf{d} = p_k - p_{k-1}$$
3. **Multi-Cell Occupancy**:
   An arrow occupies every cell/segment along its polyline. A raycast from arrowhead $p_k$ along $\mathbf{d}$ must not intersect any segment of any remaining arrow.
4. **Collision & 3-Heart Penalty**:
   If an arrow is tapped whose escape ray intersects another arrow, it recoils and the player loses **1 Heart** (out of 3). At 0 hearts, state transitions to `LEVEL_FAILED`.
5. **Slither Escape Tween**:
   When unobstructed, the arrow slithers along its own polyline out of the board.

---

## 3. COLOR PALETTE FOR WINDING ARROWS

```text
• Background: Ice Blue (#EBF3FC)
• Top Banner: Sky Blue (#4D90EE -> #3A80E0)
• Arrow Colors:
  - Blue:   #2B7DE9
  - Red:    #E04848
  - Green:  #27AE60
  - Orange: #F39C12
  - Purple: #8E44AD
  - Yellow: #F1C40F
  - Pink:   #E84393
  - Navy:   #2C3E50
  - Teal:   #00CEC9
```
