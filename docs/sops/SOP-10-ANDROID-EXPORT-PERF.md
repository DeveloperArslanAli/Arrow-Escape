# SOP-10: Android Build, Performance Budget & Store Readiness
## Purpose & Scope
Specifies Android export presets, Gradle build pipelines, mobile performance profiling metrics, memory budgets, Google Play requirements, and release validation protocols.

---

## 1. PERFORMANCE BUDGET MATRIX

To guarantee smooth 60 FPS on entry-level Android devices:

| Metric | Target | Hard Limit | Verification Tool |
| :--- | :--- | :--- | :--- |
| **Frame Rate** | 60 FPS | 58 FPS | Godot Monitor / Android GPU Watch |
| **Frame Time** | 16.6 ms | 18.0 ms | Godot Profiler |
| **Draw Calls** | < 15 per frame | < 25 per frame | Godot Visual Profiler |
| **RAM Usage** | < 75 MB | < 120 MB | `OS.get_static_memory_usage()` |
| **AAB Bundle Size** | < 55 MB | < 150 MB | Play Console Bundle Limit |
| **APK Release Size** | < 55 MB | < 100 MB | File size audit |
| **Input Latency** | < 16 ms | < 30 ms | High-speed touch capture |

---

## 2. GODOT ANDROID EXPORT ARCHITECTURE

From [export_presets.cfg](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/export_presets.cfg):

### Preset 0: `Android (AAB - Play Store)` [Mandatory for Store Release]
- **Build Engine:** Gradle Build enabled (`gradle_build/use_gradle_build = true`).
- **Format:** Android App Bundle (`gradle_build/export_format = 1`).
- **Target SDK:** API 34 (Android 14 UpsideDownCake).
- **Min SDK:** API 24 (Android 7.0 Nougat).
- **Architectures:** `arm64-v8a` (64-bit mandatory) and `armeabi-v7a` (32-bit legacy fallback).
- **Template Pre-requisite:** `res://android/build/.build_version` containing exact Godot engine version (`4.7.2.stable`).
- **Keystore:** Signed with official 2048-bit RSA release key (`res://keystores/release.keystore`).

### Preset 1: `Android (APK - Release)` [For Direct Hardware Testing & Sideloading]
- **Build Engine:** Precompiled Template Export (`gradle_build/use_gradle_build = false`).
- **Format:** Universal APK (`gradle_build/export_format = 0`).
- **Signing & Alignment:** Aligned via `zipalign` and signed via `apksigner` (v1/v2/v3 schemes active).

---

## 3. CLI BUILD & EXPORT AUTOMATION

```powershell
# 1. Build Production App Bundle for Google Play Store (.aab via Gradle)
& "D:\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --export-release "Android (AAB - Play Store)" build/ArrowEscape.aab

# 2. Build Universal Release APK for Hardware Testing (.apk)
& "D:\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --export-release "Android (APK - Release)" build/ArrowEscape-release.apk

# 3. Verify APK Signature using Android SDK
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\36.0.0\apksigner.bat" verify --verbose "build/ArrowEscape-release.apk"
```

---

## 4. STORE PUBLICATION ASSET CHECKLIST

Before uploading to Google Play Console:
1. **High-Res App Icon:** 512 × 512 px PNG located at [`assets/store/icon_512.png`](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/assets/store/icon_512.png) (and root `icon.png`).
2. **Feature Graphic:** 1024 × 500 px PNG located at [`assets/store/feature_graphic_1024x500.png`](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/assets/store/feature_graphic_1024x500.png).
3. **Play Store Publication Checklist:** Follow [`docs/PLAYSTORE_RELEASE_CHECKLIST.md`](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/docs/PLAYSTORE_RELEASE_CHECKLIST.md).
4. **Privacy Policy:** Required URL in Play Console pointing to [`docs/PRIVACY_POLICY.md`](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/docs/PRIVACY_POLICY.md).
5. **Keystore Security:** Store offline backup of `keystores/release.keystore` and refer to [`keystores/README.md`](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/keystores/README.md).
