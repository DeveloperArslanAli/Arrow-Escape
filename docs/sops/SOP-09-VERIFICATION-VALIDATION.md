# SOP-09: Automated Verification & Validation (V&V) Suite
## Purpose & Scope
Mandates the automated verification protocols, unit tests, solvability assertions, and regression test suites executed via Godot headless CLI.

---

## 1. HEADLESS EXECUTION COMMAND

All tests must be executable headlessly via the terminal:

```powershell
& "D:\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless -s tests/run_all_tests.gd
```

The script exits with code `0` on 100% test pass, or code `1` if any test fails, blocking bad commits or broken builds.

---

## 2. MANDATORY V&V SUITES

| Test Suite File | Coverage Target | Pass Criteria |
| :--- | :--- | :--- |
| `tests/test_grid_path.gd` | Directional raycasting, edge escape, blocked paths, collision cases | 100% path calculations match expected truth table. |
| `tests/test_solver.gd` | Backtracking solver, cycle detection, state memoization, hint resolution | Solves valid boards in < 10ms; rejects unfinishable deadlocks. |
| `tests/test_levels.gd` | Automated sweep of every level in `res://data/levels/` | **Every single level** has valid JSON, valid bounds, no overlapping cells, and solver returns at least one solution. |
| `tests/test_persistence.gd` | Atomic save writes, backup restoration, corrupted JSON recovery | Save survives simulated failure; fallback retains valid state. |

---

## 3. TEST ASSERTION PATTERN

Tests follow standard GDScript assertion wrappers:

```gdscript
func assert_true(condition: bool, message: String) -> void:
    if not condition:
        push_error("TEST FAILURE: %s" % message)
        failed_count += 1
    else:
        passed_count += 1
```
