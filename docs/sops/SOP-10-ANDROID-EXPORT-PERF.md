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
| **RAM Usage** | < 75 MB | < 120 MB | `OS.get_static_memory_usage()` |
| **APK / AAB Size** | < 25 MB | < 40 MB | File size audit |
| **Input Latency** | < 16 ms | < 30 ms | High-speed touch capture |

---

## 2. GODOT ANDROID EXPORT CONFIGURATION

- **Renderer**: `gl_compatibility` (OpenGL ES 3.0 / WebGL 2.0). Provides instant startup and compatibility across all budget Mali, Adreno, and PowerVR chipsets.
- **Architectures**: `arm64-v8a` (Primary) and `armeabi-v7a` (Legacy fallback).
- **Target SDK**: Android 14 (API level 34) or 15 (API level 35).
- **Min SDK**: Android 7.0 (API level 24).
- **V-Sync**: Enabled (`DisplayServer.VSYNC_ENABLED`).
- **Texture Compression**: Lossless WebP / ETC2 / ASTC.

---

## 3. RELEASE ASSET CHECKLIST

Before generating the signed release AAB:
1. Adaptive App Icon (Foreground 432x432 PNG, Background color `#F7F5EF`).
2. Splash screen: Minimalist arrow logo on `#F7F5EF` background.
3. Permissions: Ensure `INTERNET` and `ACCESS_NETWORK_STATE` are excluded if MVP is 100% offline.
4. Keystore: Use official release keystore (never debug keystore for production).
