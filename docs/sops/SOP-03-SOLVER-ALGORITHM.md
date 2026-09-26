# SOP-03: Deterministic Puzzle Solver & Solvability Verification
## Purpose & Scope
Provides the mathematical solver engine used to:
1. Verify 100% solvability of any puzzle level before shipping.
2. Calculate the optimal or valid move sequence for the player Hint system.
3. Automatically detect deadlocks.

---

## 1. STATE SPACE FORMULATION

Let state $S$ be the set of active arrows remaining on the board:
$$S = \{ A_1, A_2, \dots, A_n \}$$
A transition $S \xrightarrow{A_k} S'$ exists if and only if:
$$\text{PathValidator.can_arrow_escape}(A_k, S) = \text{true}$$
and
$$S' = S \setminus \{A_k\}$$

A level is **Solvable** if there exists an ordered sequence of moves:
$$\sigma = \langle A_{\pi(1)}, A_{\pi(2)}, \dots, A_{\pi(n)} \rangle$$
such that:
$$S_0 \xrightarrow{A_{\pi(1)}} S_1 \xrightarrow{A_{\pi(2)}} \dots \xrightarrow{A_{\pi(n)}} \emptyset$$

---

## 2. BACKTRACKING SOLVER ALGORITHM (GDScript & Headless)

```gdscript
class_name SolverEngine

# Returns Array of arrow IDs representing a complete valid solution, or empty Array if unsolvable.
static func solve_puzzle(grid_size: Vector2i, arrows: Array[Dictionary]) -> Array[String]:
    var occupancy: Dictionary = {}
    for a in arrows:
        occupancy[Vector2i(a.column, a.row)] = a
    
    var solution: Array[String] = []
    var visited_states: Dictionary = {}
    
    if _search(grid_size, occupancy, arrows.size(), solution, visited_states):
        return solution
    return []

static func _search(grid_size: Vector2i, occupancy: Dictionary, remaining_count: int, solution: Array[String], visited: Dictionary) -> bool:
    if remaining_count == 0:
        return true # Solved!
        
    # State hash for memoization
    var state_key: int = _compute_state_hash(occupancy)
    if visited.has(state_key):
        return false
    visited[state_key] = true
    
    # Find all currently removable arrows
    var removable: Array[Dictionary] = []
    for coord in occupancy.keys():
        var arrow: Dictionary = occupancy[coord]
        if arrow != null:
            if _can_escape(coord, arrow.direction, occupancy, grid_size):
                removable.append(arrow)
                
    if removable.is_empty():
        return false # Deadlock in this branch
        
    for candidate in removable:
        var c_coord: Vector2i = Vector2i(candidate.column, candidate.row)
        # Apply move
        occupancy.erase(c_coord)
        solution.append(candidate.id)
        
        if _search(grid_size, occupancy, remaining_count - 1, solution, visited):
            return true
            
        # Backtrack
        occupancy[c_coord] = candidate
        solution.pop_back()
        
    return false
```

---

## 3. HINT SYSTEM INTEGRATION

When player requests a Hint:
1. Extract current board occupancy from `GridManager`.
2. Run solver from current state.
3. If a solution is found, the **first arrow in the returned solution array** is highlighted.
4. If no complete solution exists from current state (impossible in standard rules since no arrows block reversely), highlight any currently removable arrow.
5. Highlight animation: gentle scale bounce (1.1x) + golden accent glow (`#F6D365`) for 2.0s.
