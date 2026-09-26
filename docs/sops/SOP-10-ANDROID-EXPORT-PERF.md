# SOP-10: Android Build, Performance Budget & Store Readiness
## Purpose & Scope
Specifies Android export settings, mobile performance profiling metrics, memory budgets, Google Play requirements, and release preparation.

---

## 1. PERFORMANCE BUDGET MATRIX

To guarantee smooth 60 FPS on entry-level Android devices:

| Metric | Target | Hard Limit | Verification Tool |
| :--- | :--- | :--- | :--- |
| **Frame Rate** | 60 FPS | 58 FPS | Godot Monitor / Android GPU Watch |
| **Frame Time** | 16.6 ms | 18.0 ms | Godot Profiler |
| **Draw Calls** | < 15 per frame | < 25 per frame | Godot Visual Profiler |
| **RAM Usage** | < 65 MB | < 100 MB | `OS.get_static_memory_usage()` |
| **APK / AAB Size** | < 25 MB | < 40 MB | File size audit |
| **Input Latency** | < 16 ms | < 30 ms | High-speed touch capture |

---

## 2. GODOT ANDROID EXPORT CONFIGURATION

From [export_presets.cfg](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/export_presets.cfg):
- **Renderer**: `gl_compatibility` (OpenGL ES 3.0 / WebGL 2.0). Provides instant startup and compatibility across all budget Mali, Adreno, and PowerVR chipsets.
- **Architectures**: `arm64-v8a` (Primary) and `armeabi-v7a` (Legacy fallback).
- **Target SDK**: Android 14 (API level 34).
- **Min SDK**: Android 7.0 (API level 24).
- **Orientation**: Locked Portrait (`orientation = 1`).
- **Immersive Mode**: Enabled (`screen/immersive_mode = true`).
- **Permissions**: Fully offline (`internet = false`, `access_network_state = false`, `vibrate = true`).

---

## 3. RELEASE ASSET CHECKLIST

Before generating the signed release AAB:
1. Adaptive App Icon (Foreground 432x432 PNG, Background color `#EBF3FC`).
2. Splash screen: Minimalist arrow logo on `#EBF3FC` background.
3. Keystore: Use official release keystore (never debug keystore for production).
4. Store metadata: Follow [docs/STORE_METADATA.md](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/docs/STORE_METADATA.md).
