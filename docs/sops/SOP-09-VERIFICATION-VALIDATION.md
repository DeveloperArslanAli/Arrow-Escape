# SOP-09: Automated Verification & Validation (V&V) Suite
## Purpose & Scope
Mandates the automated verification protocols, unit tests, solvability assertions, and regression test suites executed via Godot headless CLI.

---

## 1. HEADLESS EXECUTION COMMANDS

All verification suites must be executed headlessly via the terminal before any commit:

### A. Core Test Suite (Pathing, Solver, 50 Levels, Persistence)
```powershell
& "D:\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless tests/TestRunner.tscn
```
- Exits with return code `0` on 100% test pass.
- Exits with return code `1` if any test fails, blocking bad commits or broken builds.

### B. Complete Scene Tree & Runtime Lifecycle (60 Frames)
```powershell
& "D:\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless scenes/core/Main.tscn --quit-after 60
```
- Verifies that all Autoloads, CanvasLayers, UI Modals, and GameBoard initialize with **0 errors and 0 warnings**.

---

## 2. MANDATORY V&V SUITES

| Test Suite File | Coverage Target | Pass Criteria |
| :--- | :--- | :--- |
| `tests/test_grid_path.gd` | Directional raycasting, edge escape, blocked paths, collision cases | 100% path calculations match expected truth table. |
| `tests/test_solver.gd` | Backtracking solver, cycle detection, state memoization, hint resolution | Solves valid boards in < 10ms; rejects unfinishable deadlocks. |
| `tests/test_levels.gd` | Automated sweep of every level in `res://data/levels/` | **Every single level (1–50)** has valid JSON, valid bounds, no overlapping cells, and solver returns at least one solution. |
| `tests/test_persistence.gd` | Atomic save writes, backup restoration, corrupted JSON recovery | Save survives simulated failure; fallback retains valid state. |

---

## 3. QUALITY GATES BEFORE COMMITTING

1. `tests/TestRunner.tscn` returns exit code 0 (`4 Passed, 0 Failed`).
2. Zero compiler warnings or errors reported in Godot console output.
3. Git working tree is clean.
