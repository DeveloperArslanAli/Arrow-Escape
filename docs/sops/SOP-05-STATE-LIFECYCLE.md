# SOP-05: Game State Lifecycle, Hearts (Lives) & Timer
## Purpose & Scope
Governs the game state machine, 3-hearts life tracking, live elapsed timer, fail/restart flows, and victory triggers.

---

## 1. EXTENDED STATE MACHINE

```mermaid
stateDiagram-v2
    [*] --> BOOT
    BOOT --> MAIN_MENU : Assets & Save Loaded
    MAIN_MENU --> LEVEL_SELECT : Tap 'Select Level'
    MAIN_MENU --> PLAYING : Tap 'Play'
    LEVEL_SELECT --> PLAYING : Level Picked
    PLAYING --> PAUSED : Tap Pause
    PAUSED --> PLAYING : Tap Resume
    PLAYING --> LEVEL_FAILED : Hearts == 0
    LEVEL_FAILED --> PLAYING : Tap Retry
    PLAYING --> LEVEL_COMPLETE : All Arrows Escaped
    LEVEL_COMPLETE --> PLAYING : Tap Next Level
```

---

## 2. HEARTS & TIMER INVARIANTS

1. **Hearts (3 Lives)**:
   - Initialized to `3` on `start_level()`.
   - Decremented by `1` when player taps an arrow whose path is blocked.
   - UI reflects `❤️❤️❤️`, `❤️❤️💔`, `❤️💔💔`, `💔💔💔`.
   - On 0 hearts: input locks immediately, transition to `LEVEL_FAILED`.
2. **Timer**:
   - Live timer increments in `_process(delta)` during `PLAYING` state.
   - Formatted as `⏱ Xs` (or `M:SS` if > 60s).
   - Displayed in the left top pill widget matching the screenshot.
