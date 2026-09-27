# 🧠 MEMORY GRAPH & KNOWLEDGE TOPOLOGY
## Arrow Escape (Winding Paths Edition — "Arrows Puzzle Escape" Style)

> **Document Version:** 3.0.0  
> **Game Archetype:** Winding/Bent Arrow Puzzle (Inspired by *Arrows – Puzzle Escape*)  
> **Engine:** Godot Engine 4.x (GDScript) · Mobile Portrait (720x1280)  
> **Key Mechanics:** Multi-segment orthogonal winding arrows, 3-Hearts life system, live timer, polyline slither escape along track, elastic bonk recoil, reverse-DAG 200-level saturation scaling, 8 thematic worlds with dynamic theme transitions, chapter-based level selection, and 100% mathematical solvability guarantee.

---

## 1. AGENT EXECUTION ROUTER (V3.0)

| Task Domain | Primary SOP | Key Source Files | Verification Target |
| :--- | :--- | :--- | :--- |
| **Winding Arrow / Polyline Raycast / Slither** | `SOP-02-GRID-MOVEMENT.md` | `scripts/core/arrow_controller.gd`<br>`scripts/core/grid_manager.gd`<br>`scripts/core/path_validator.gd` | `res://tests/test_grid_path.gd`<br>`res://tests/test_arrow_motion.gd` |
| **Polyline Solvability & Hint Solver** | `SOP-03-SOLVER-ALGORITHM.md` | `scripts/solver/solver_engine.gd` | `res://tests/test_solver.gd` |
| **High-Density Reverse-DAG Level Packs (200 Ls)** | `SOP-04-LEVEL-MANAGEMENT.md` | `data/levels/`<br>`scripts/generator/generate_dense_levels.py`<br>`scripts/core/level_manager.gd` | `res://tests/test_levels.gd` |
| **Click Input & Debounce Gatekeeping** | `SOP-02-GRID-MOVEMENT.md` | `scripts/core/grid_manager.gd`<br>`scenes/core/Main.tscn` | `res://tests/test_click_input.gd` |
| **8 Thematic Worlds & Dynamic Palettes** | `SOP-06-UI-DESIGN-SYSTEM.md` | `scripts/core/theme_manager.gd`<br>`scripts/core/main.gd`<br>`scripts/ui/game_hud.gd` | Runtime Headless UI Test |
| **Hearts (3 Lives), Timer, Game FSM** | `SOP-05-STATE-LIFECYCLE.md` | `scripts/autoload/game_manager.gd` | `res://tests/TestRunner.tscn` |
| **Chapter-Based Level Select & Auto-Scroll** | `SOP-06-UI-DESIGN-SYSTEM.md` | `scenes/ui/LevelSelect.tscn`<br>`scripts/ui/level_select.gd` | Headless Test & Runtime UI |
| **Audio, Synth, Slither & Bump Haptics** | `SOP-07-AUDIO-HAPTICS.md` | `scripts/autoload/audio_manager.gd` | Audio Bus triggers |
| **Atomic Persistence (Hearts, Levels, Stars)** | `SOP-08-PERSISTENCE-ATOMIC.md` | `scripts/autoload/save_manager.gd` | `res://tests/test_persistence.gd` |
| **Android Export & Play Store Pipeline** | `SOP-10-ANDROID-EXPORT-PERF.md` | `export_presets.cfg`<br>`docs/PLAYSTORE_RELEASE_CHECKLIST.md`<br>`docs/PRIVACY_POLICY.md` | `build/ArrowEscape.aab`<br>`build/ArrowEscape-release.apk` |

---

## 2. COMPONENT INVARIANTS (V3.0 WINDING ARROWS & 8 WORLDS)

1. **Polyline Path Continuity**:
   Every arrow $A_i$ consists of an ordered sequence of grid vertices:
   $$\text{Path}(A_i) = \langle p_0, p_1, \dots, p_k \rangle, \quad p_j = (c_j, r_j)$$
   where consecutive points are strictly orthogonally adjacent: $\|p_{j+1} - p_j\|_1 = 1$.
2. **Arrowhead Orientation & Raycast**:
   The arrow head is located at $p_k$ pointing in direction $\mathbf{d} = p_k - p_{k-1}$. A discrete raycast along $\mathbf{d}$ must not intersect any segment of any remaining arrow.
3. **Multi-Cell Occupancy & Zero Collision**:
   Arrows occupy every cell along their polyline. No two arrows may share any coordinate cell at level start. The reverse-DAG generator enforces strict pre-save collision validation.
4. **Collision & 3-Heart Penalty**:
   Tapping an arrow whose escape ray is obstructed triggers an elastic bounce recoil and deducts 1 heart (3 hearts total). Depletion triggers `LEVEL_FAILED`.
5. **Slither Escape Motion**:
   Unobstructed arrows slither smoothly along their established multi-segment path out of the board before being culled.
6. **Chapter Theming & Transitions**:
   On level load, `ThemeManager.get_theme_for_level(level_id)` supplies the active world's background color, header accent, and arrow palette. Background colors transition smoothly via a 0.35s tween.

---

## 3. THE 8 THEMATIC WORLDS & CHAPTER PALETTES

```text
• World 1: Sky Breeze        (Lvls 1–25)   | 4x4 -> 6x6   | Ice-Blue (#EBF3FC)  | Classic Sky-Blue (#3A80E0)
• World 2: Sunset Coral      (Lvls 26–50)  | 6x6 -> 8x8   | Soft Peach (#FDF2EE)| Coral Sunset (#E65C40)
• World 3: Emerald Glade     (Lvls 51–75)  | 8x8 -> 10x10 | Mint Mist (#EEF9F5) | Lush Jade (#10AC84)
• World 4: Amethyst Twilight (Lvls 76–100) | 10x10->12x12 | Lilac (#F6F3FF)     | Deep Amethyst (#6C5CE7)
• World 5: Oceanic Abyss     (Lvls 101–125)| 12x12->14x14 | Arctic Ice (#EAF6FF)| Sapphire Blue (#0984E3)
• World 6: Golden Dunes      (Lvls 126–150)| 14x14->16x16 | Sandstone (#FDFBF2) | Desert Gold (#D48806)
• World 7: Cherry Blossom    (Lvls 151–175)| 16x16->18x18 | Sakura (#FFF0F3)    | Sakura Ruby (#D63031)
• World 8: Midnight Obsidian (Lvls 176–200)| 18x18->20x20 | Obsidian (#181E24)  | Neon Metallic Slate (#2C3E50)
```

---

## 4. PRODUCTION RELEASE & GOOGLE PLAY STORE PIPELINE

- **Package Identifier:** `com.developerarslanali.arrowescape`
- **Engine Version:** Godot Engine 4.7.2.stable (`res://android/build/.build_version`)
- **Version Code / Name:** `1` / `1.0.0`
- **Target SDK / Min SDK:** API 34 (Android 14) / API 24 (Android 7.0)
- **Supported ABIs:** `arm64-v8a` (Primary 64-bit), `armeabi-v7a` (32-bit legacy fallback)
- **Release Presets in `export_presets.cfg`:**
  1. `Android (AAB - Play Store)`: Gradle build enabled (`export_format = 1`). Produces `build/ArrowEscape.aab` (52.96 MB).
  2. `Android (APK - Release)`: Standalone template export (`export_format = 0`). Produces `build/ArrowEscape-release.apk` (52.99 MB).
- **Keystore:** `keystores/release.keystore` (RSA 2048-bit, Alias: `arrowescape`, Validity: 10,000 days).
- **Store Assets:**
  - High-Res App Icon: `assets/store/icon_512.png` (512x512 PNG) & root `icon.png`.
  - Feature Graphic: `assets/store/feature_graphic_1024x500.png` (1024x500 PNG).
- **Release Documentation:**
  - Play Store Checklist: [`docs/PLAYSTORE_RELEASE_CHECKLIST.md`](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/docs/PLAYSTORE_RELEASE_CHECKLIST.md)
  - Privacy Policy: [`docs/PRIVACY_POLICY.md`](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/docs/PRIVACY_POLICY.md)
  - Keystore Security Guide: [`keystores/README.md`](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/keystores/README.md)

