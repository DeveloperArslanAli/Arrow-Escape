# 🧠 MEMORY GRAPH & KNOWLEDGE TOPOLOGY
## Arrow Escape — Autonomous Engineering & Context Routing System

> **Document Version:** 1.0.0  
> **Target Engine:** Godot Engine 4.x (GDScript)  
> **Platform:** Android Mobile (Offline-first casual puzzle)  
> **System Purpose:** Eliminate AI hallucination, prevent architectural drift, enforce strict token minimization, and route agent executions directly to bounded SOPs.

---

## 1. AGENT ROUTING & TOKEN MINIMIZATION PROTOCOL

When tasked with reading, modifying, or creating any feature in this repository:
1. **DO NOT** read the entire codebase or load irrelevant documents into context.
2. **Consult Table 1.1 (Agent Execution Router)** below to identify the exact **SOP IDs** and **Source File Targets** required for your task.
3. Read **ONLY** the designated SOP files.
4. Execute code changes adhering strictly to the invariants defined in the SOP.
5. Execute the **Verification & Validation (V&V)** command listed for that node.
6. Verify no architectural boundaries were breached.

### Table 1.1: Agent Execution Router

| Intent / Task Domain | Primary SOP | Secondary SOPs | Core Target Files | Verification Target | Token Cost |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Grid / Path Raycasting / Arrow Movement** | `SOP-02-GRID-MOVEMENT.md` | `SOP-01`, `SOP-09` | `scripts/core/grid_manager.gd`<br>`scripts/core/arrow_controller.gd`<br>`scripts/core/path_validator.gd` | `res://tests/test_grid_path.gd` | ~1.5k |
| **Puzzle Solvability & Hint Generation** | `SOP-03-SOLVER-ALGORITHM.md` | `SOP-04`, `SOP-09` | `scripts/solver/solver_engine.gd`<br>`scripts/solver/level_validator.gd` | `res://tests/test_solver.gd` | ~1.8k |
| **Level Data, JSON Schema & Packs** | `SOP-04-LEVEL-MANAGEMENT.md` | `SOP-03`, `SOP-08` | `scripts/core/level_manager.gd`<br>`data/levels/` | `res://tests/test_levels.gd` | ~1.2k |
| **Game State, Turn Flow & Lifecycle** | `SOP-05-STATE-LIFECYCLE.md` | `SOP-01`, `SOP-02` | `scripts/autoload/game_manager.gd`<br>`scripts/core/turn_flow_controller.gd` | `res://tests/test_game_flow.gd` | ~1.4k |
| **UI Components, Themes & Screen Flow** | `SOP-06-UI-DESIGN-SYSTEM.md` | `SOP-05`, `SOP-07` | `scenes/ui/`<br>`scripts/ui/`<br>`assets/themes/` | Visual / Scene Runner | ~2.0k |
| **Audio Busses, SFX & Haptics** | `SOP-07-AUDIO-HAPTICS.md` | `SOP-05`, `SOP-08` | `scripts/autoload/audio_manager.gd`<br>`default_bus_layout.tres` | `res://tests/test_audio.gd` | ~1.1k |
| **Save/Load, Persistence & Progress** | `SOP-08-PERSISTENCE-ATOMIC.md` | `SOP-04`, `SOP-05` | `scripts/autoload/save_manager.gd` | `res://tests/test_persistence.gd` | ~1.3k |
| **Unit Testing & Headless CI Test Suite** | `SOP-09-VERIFICATION-VALIDATION.md` | `SOP-02`, `SOP-03` | `tests/`<br>`addons/gut/` (optional) | Godot Headless CLI | ~1.6k |
| **Android Export, Resolution & Performance** | `SOP-10-ANDROID-EXPORT-PERF.md` | `SOP-01`, `SOP-06` | `project.godot`<br>`export_presets.cfg` | Android Profiler / Export | ~1.4k |
| **Adding New Features / Refactoring** | `SOP-11-FEATURE-MODIFICATION.md` | Target Feature SOP | Dependent Modules | Regression Suite | ~1.2k |

---

## 2. SYSTEM TOPOLOGY GRAPH

```mermaid
graph TD
    subgraph Autoload_Singletons [Autoload Singletons (Global Scope)]
        GM[GameManager\nres://scripts/autoload/game_manager.gd]
        SM[SaveManager\nres://scripts/autoload/save_manager.gd]
        AM[AudioManager\nres://scripts/autoload/audio_manager.gd]
    end

    subgraph Level_System [Level & Solvability Engine]
        LM[LevelManager\nres://scripts/core/level_manager.gd]
        SE[SolverEngine\nres://scripts/solver/solver_engine.gd]
        LD[(Level JSON Store\nres://data/levels/)]
    end

    subgraph Core_Gameplay [Core Gameplay Graph]
        GridMgr[GridManager\nres://scripts/core/grid_manager.gd]
        PV[PathValidator\nres://scripts/core/path_validator.gd]
        AC[ArrowController Nodes\nres://scripts/core/arrow_controller.gd]
    end

    subgraph UI_System [UI & Presentation Layer]
        HUD[GameHUD / InGame UI]
        Menu[MainMenu & LevelSelect]
        CompleteModal[LevelComplete Modal]
        PauseModal[Pause & Settings Modal]
    end

    %% Singleton linkages
    GM --> LM
    GM --> SM
    GM --> AM

    %% Core Data flow
    LM --> LD
    LM --> SE
    LM --> GridMgr

    %% Gameplay interactions
    GridMgr --> AC
    GridMgr --> PV
    AC -.->|Player Tap| PV
    PV -.->|Validation Result| AC
    AC -.->|Escape Finished| GridMgr
    GridMgr -.->|Board Empty Event| GM

    %% UI Linkages
    GM -.->|State Signals| HUD
    GM -.->|Level Finished| CompleteModal
    HUD -.->|Pause / Restart / Hint| GM
```

---

## 3. COMPONENT INVARIANT MATRIX

To prevent regressions and architectural rot, every module enforces strict invariant contracts:

| Component | Responsibility Boundary | Strict Invariants (NEVER VIOLATE) |
| :--- | :--- | :--- |
| **`PathValidator`** | Pure logical calculation of ray paths | • **Pure Functionality**: Must NOT mutate board state.<br>• **Zero Scene Tree Dependency**: Must run headlessly in under 0.1ms without node references. |
| **`GridManager`** | 2D coordinate space & cell occupancy mapping | • **Single Occupancy**: No cell `(r, c)` can contain more than 1 arrow.<br>• **Atomic Updates**: Grid array updates immediately when arrow begins escape to prevent race conditions. |
| **`ArrowController`** | Entity visual representation, tweening & input | • **Input Locking**: All arrow taps are disabled while any arrow is in an active escape tween.<br>• **Deterministic Directions**: Arrow direction must be strictly cardinal (`UP`, `DOWN`, `LEFT`, `RIGHT`). |
| **`SolverEngine`** | Automated level validation & hint computation | • **Soundness**: If solver returns `UNSOLVABLE`, level MUST NOT be shipped.<br>• **Loop Prevention**: Transposition table (Zobrist hash or bitset) required for search depth > 10. |
| **`SaveManager`** | Persistent player progress | • **Atomic Writes**: Save to `.tmp` file first, then atomic rename to prevent power-loss corruption.<br>• **Checksum Validation**: Encrypted or hash-validated to prevent invalid/corrupted saves. |
| **`GameManager`** | Finite state machine orchestrator | • **Unidirectional Flow**: State transitions are strictly governed: `BOOT -> MENU -> PLAYING -> COMPLETE`. |

---

## 4. ARCHITECTURAL DECISION REGISTRY (ADR)

### ADR-001: Godot 4.x with 2D Compatibility / Mobile Renderer
- **Decision:** Use Godot 4.x with `gl_compatibility` or `mobile` renderer.
- **Rationale:** Ensures 60 FPS on low-end Android chipsets (e.g. Mali-G52, Adreno 506) with zero shader compile stutters.
- **Constraints:** Avoid 3D nodes, heavy screen-reading shaders, or complex viewport nestings.

### ADR-002: Logical Coordinate Decoupling
- **Decision:** Logical puzzle coordinates `Vector2i(col, row)` are completely decoupled from pixel coordinates `Vector2(x, y)`.
- **Rationale:** Allows dynamic board centering and scaling across phone aspect ratios (16:9, 19.5:9, 21:9, and tablets 4:3) without modifying gameplay logic.

### ADR-003: Deterministic Offline JSON Level Repository
- **Decision:** Levels are stored as clean JSON files with numeric IDs.
- **Rationale:** Allows offline validation via headless Python and GDScript test runners. Zero backend needed for release.

### ADR-004: Event-Driven UI (Signal-Up, Method-Down)
- **Decision:** Child nodes emit Godot signals to parents; parent nodes call methods on children.
- **Rationale:** Eliminates cyclic references, memory leaks, and brittle `get_parent().get_parent()` node lookups.

---

## 5. REPOSITORY DIRECTORY LAYOUT

```text
e:/Projects/mobile application/Arrow Puzzle Game/
├── .godot/                     # Godot internal cache (gitignored)
├── assets/
│   ├── audio/                  # WAV/OGG SFX & ambient tracks
│   │   ├── sfx/                # tap.wav, escape.wav, blocked.wav, victory.wav
│   │   └── music/              # ambient_loop.ogg
│   ├── fonts/                  # Custom modern font (Outfit / Poppins)
│   ├── icons/                  # Game launcher icons for Android
│   └── themes/                 # Godot Theme resources & StyleBoxes
├── data/
│   └── levels/                 # Packaged level JSON files
│       ├── level_001.json
│       ├── level_002.json
│       └── ...
├── docs/
│   └── sops/                   # Standard Operating Procedures (SOP-00 to SOP-11)
├── scenes/
│   ├── autoload/               # Global singletons (GameManager, SaveManager, AudioManager)
│   ├── core/                   # GameBoard.tscn, Arrow.tscn
│   └── ui/                     # MainMenu.tscn, HUD.tscn, LevelComplete.tscn, Settings.tscn
├── scripts/
│   ├── autoload/               # GameManager.gd, SaveManager.gd, AudioManager.gd
│   ├── core/                   # GridManager.gd, ArrowController.gd, PathValidator.gd, LevelManager.gd
│   ├── solver/                 # SolverEngine.gd, LevelValidator.gd
│   └── ui/                     # UI Controllers
├── tests/                      # Automated headless verification suite
│   ├── run_all_tests.gd        # Master test harness
│   ├── test_grid_path.gd       # Path & Grid unit tests
│   ├── test_solver.gd          # Solvability verification tests
│   └── test_persistence.gd     # Save/Load integrity tests
├── GeneralDocument.md          # Original requirements document
├── MASTER_IMPLEMENTATION_PLAN.md # Publication-ready master engineering plan
├── MEMORY_GRAPH.md             # This document (System Router)
├── export_presets.cfg          # Android export settings
└── project.godot               # Godot 4.x project manifest
```
