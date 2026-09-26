# SOP-03: Deterministic Puzzle Solver & Solvability Verification (Winding Polyline Edition)
## Purpose & Scope
Provides the mathematical solver engine used to:
1. Verify 100% solvability of any winding puzzle level before shipping.
2. Calculate the optimal or valid move sequence for the player Hint system.
3. Automatically detect deadlocks.

---

## 1. STATE SPACE FORMULATION FOR WINDING ARROWS

Let state $S$ be the set of active winding arrows on the board:
$$S = \{ A_1, A_2, \dots, A_m \}$$
where each arrow $A_i$ occupies a set of integer coordinates $\text{Points}(A_i) = \langle p_{i,0}, p_{i,1}, \dots, p_{i,k} \rangle$.

Let $\mathbf{d}_i = p_{i,k} - p_{i,k-1}$ be the exit direction of arrow $A_i$.
The exit trajectory ray is:
$$\text{Ray}(A_i) = \{ p_{i,k} + j \cdot \mathbf{d}_i \mid j \ge 1, \ (p_{i,k} + j \cdot \mathbf{d}_i) \in G \}$$

A transition $S \xrightarrow{A_k} S'$ exists if and only if:
$$\forall \mathbf{q} \in \text{Ray}(A_k), \quad \forall A_j \in S \setminus \{A_k\}, \quad \mathbf{q} \notin \text{Points}(A_j)$$
and
$$S' = S \setminus \{A_k\}$$

A level is **Solvable** if there exists an ordered sequence of moves:
$$\sigma = \langle A_{\pi(1)}, A_{\pi(2)}, \dots, A_{\pi(m)} \rangle \quad \text{such that} \quad S_0 \xrightarrow{\sigma} \emptyset$$

---

## 2. BACKTRACKING SOLVER ALGORITHM (GDScript Implementation)

```gdscript
class_name SolverEngine
extends RefCounted

const PathValidator = preload("res://scripts/core/path_validator.gd")

static func solve_puzzle(grid_size: Vector2i, arrows: Array) -> Array[String]:
    var occupancy: Dictionary = {}
    var normalized_arrows: Array[Dictionary] = []
    
    for item in arrows:
        var norm_a: Dictionary = { "id": str(item.get("id", "")) }
        var pts: Array[Vector2i] = []
        for p in item["points"]:
            pts.append(Vector2i(int(p[0]), int(p[1])))
        norm_a["points"] = pts
        for p in pts:
            occupancy[p] = norm_a
        normalized_arrows.append(norm_a)
        
    var solution: Array[String] = []
    var visited: Dictionary = {}
    
    if _search(grid_size, occupancy, normalized_arrows, normalized_arrows.size(), solution, visited):
        return solution
    return []

static func _search(grid_size: Vector2i, occupancy: Dictionary, active_arrows: Array[Dictionary], remaining_count: int, solution: Array[String], visited: Dictionary) -> bool:
    if remaining_count == 0:
        return true # Solved!
        
    var state_key: int = _compute_hash(active_arrows)
    if visited.has(state_key):
        return false
    visited[state_key] = true
    
    # Identify all currently removable winding arrows
    var removable: Array[Dictionary] = []
    for a in active_arrows:
        if PathValidator.can_arrow_escape_polyline(a["points"], a["id"], occupancy, grid_size):
            removable.append(a)
            
    if removable.is_empty():
        return false # Deadlock in this branch
        
    for candidate in removable:
        var pts: Array[Vector2i] = candidate["points"]
        var c_id: String = candidate["id"]
        
        # Apply move: clear occupied cells
        for p in pts:
            occupancy.erase(p)
        active_arrows.erase(candidate)
        solution.append(c_id)
        
        if _search(grid_size, occupancy, active_arrows, remaining_count - 1, solution, visited):
            return true
            
        # Backtrack: restore cells
        for p in pts:
            occupancy[p] = candidate
        active_arrows.append(candidate)
        solution.pop_back()
        
    return false
```

---

## 3. HINT SYSTEM INTEGRATION

When player taps the `🔍 ▷` Hint button:
1. Extract current board occupancy from `GridManager`.
2. Execute `SolverEngine.get_hint(grid_size, active_arrows)`.
3. Highlight the returned arrow with a golden pulsing outline (`#F1C40F`).
4. If no complete solution exists from current state, fallback to highlighting any arrow whose immediate path is clear.
