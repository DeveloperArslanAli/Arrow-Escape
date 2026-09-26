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

## 2. PROCEDURAL SOUND SYNTHESIS SPECIFICATION

To guarantee 100% offline self-containment with zero external audio asset dependencies, [scripts/autoload/audio_manager.gd](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/scripts/autoload/audio_manager.gd) synthesizes crisp audio waves dynamically via `AudioStreamWAV` (16-bit, 44.1 kHz):

| Event | Audio Character | Pitch Variation | Procedural Formula |
| :--- | :--- | :--- | :--- |
| **Arrow Tap** | Crisp, gentle pop | Fixed | $f = 520\,\text{Hz}$, duration $0.04\,\text{s}$, envelope $\exp(-4t)$ |
| **Arrow Escape** | Uplifting chime | Scales up per combo streak | Pentatonic scale: $f = 440 \cdot 2^{s/12}$ semitones $\{0, 2, 4, 7, 9, 12, 14, 16\}$ |
| **Arrow Collision** | Low-frequency thud | Fixed low pitch | $f = 130\,\text{Hz}$, duration $0.12\,\text{s}$, envelope $\exp(-4t)$ |
| **Level Complete** | Celebratory arpeggio | 4-tone ascending | Major chord: $\{523.25, 659.25, 783.99, 1046.50\}\,\text{Hz}$ |
| **Hint Triggered** | Shimmering chime | Fixed high | $f = 880\,\text{Hz}$ with gentle flutter |

---

## 3. MOBILE HAPTIC FEEDBACK

Haptic vibrations are executed via native Godot API (`Input.vibrate_handheld(ms)`) gated by `SaveManager.save_data.settings.haptics_enabled`:

| Action | Duration (ms) | Tactile Sensation |
| :--- | :--- | :--- |
| **Arrow Selection / Tap** | `8 ms` | Ultra-light subtle click |
| **Successful Arrow Escape** | `15 ms` | Satisfying release pulse |
| **Arrow Collision / Blocked** | `28 ms` | Warning thud |
| **Level Complete Victory** | `45 ms` | Celebratory double buzz |
