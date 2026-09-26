# SOP-07: Audio Bus Architecture, Sound Design & Haptics
## Purpose & Scope
Governs audio bus routing, sound effect triggers, procedural tone generation fallbacks, volume control persistence, and Android mobile haptic feedback.

---

## 1. AUDIO BUS TOPOLOGY

Godot audio layout `res://default_bus_layout.tres`:
- **`Master`** (0 dB)
  ├── **`Music`** (-6 dB, volume controllable via Settings)
  └── **`SFX`** (0 dB, volume controllable via Settings)
      └── **`HapticsBus`** (linked trigger signals)

---

## 2. SOUND DESIGN SPECIFICATION & PROCEDURAL FALLBACK

To guarantee full functionality even before raw external `.wav` files are imported, `AudioManager` includes a lightweight procedural tone generator using `AudioStreamGenerator`:

| Event | Audio Character | Pitch Variation | Procedural Formula |
| :--- | :--- | :--- | :--- |
| **Arrow Tap / Select** | Crisp, gentle pop | None | 440 Hz short decay sine burst (30ms) |
| **Arrow Escape** | Uplifting chime | Scales up per combo (`+1` semitone) | Pentatonic frequency: $f_0 \cdot 2^{n/12}$ |
| **Arrow Blocked** | Soft low-frequency thud | Fixed low pitch | 120 Hz decaying sine wave (60ms) |
| **Level Complete** | 3-tone ascending chord | Fixed | Major triad: C5 - E5 - G5 with warm reverb |
| **Hint Triggered** | Shimmering bell | Fixed high | 880 Hz dual harmonic with gentle flutter |

---

## 3. MOBILE HAPTIC FEEDBACK

Haptic vibrations are executed via native Godot API with a user toggle in Settings:

```gdscript
func trigger_haptic(type: String) -> void:
    if not SaveManager.settings.haptics_enabled:
        return
        
    match type:
        "tap":
            Input.vibrate_handheld(8)   # Light tap
        "blocked":
            Input.vibrate_handheld(25)  # Soft warning thud
        "success":
            Input.vibrate_handheld(45)  # Celebratory pulse
```
