# SOP-06: UI Design System, Themes & Screen Layouts
## Purpose & Scope
Standardizes the visual aesthetics, design tokens, responsive layout rules, typography, and animation curves for Arrow Escape to ensure a cohesive, premium, and relaxing mobile experience.

---

## 1. DESIGN TOKENS & COLOR PALETTE

All colors are stored as `Color` constants in `ThemeManager` or custom Godot `.tres` themes:

| Token Name | Hex Code | Visual Role |
| :--- | :--- | :--- |
| `COLOR_BG` | `#F7F5EF` | Primary app background (Soft cream) |
| `COLOR_BOARD` | `#E9E8E2` | Board container background & inactive cells (Light gray) |
| `COLOR_ARROW_PRIMARY` | `#5596E6` | Standard arrow body & head (Sleek calm blue) |
| `COLOR_ARROW_SECONDARY`| `#F28B82` | Alternate arrow or multi-type variant (Soft coral) |
| `COLOR_ACCENT` | `#F6D365` | Hint highlights, star ratings, CTA badges (Soft yellow) |
| `COLOR_SUCCESS` | `#7BCFA6` | Win state banner, checkmarks, progress bars (Mint green) |
| `COLOR_TEXT_DARK` | `#30343B` | Primary headings, move counters, body text (Dark slate) |
| `COLOR_TEXT_MUTED` | `#8C9099` | Secondary captions, disabled level icons (Muted gray) |

---

## 2. RESPONSIVE MOBILE SCALING & SAFE AREAS

1. **Godot Display Settings**:
   - `display/window/size/viewport_width = 720`
   - `display/window/size/viewport_height = 1280`
   - `display/window/stretch/mode = "canvas_items"`
   - `display/window/stretch/aspect = "expand"`
   - `display/window/handheld/orientation = "portrait"`
2. **Safe Area Insets**:
   - Top notch & bottom home-bar padding managed by `DisplayServer.get_display_safe_area()`.
   - All interactive HUD buttons (Pause, Restart, Hint) are anchored with a minimum safe top margin of 48px.
3. **Board Centering**:
   - Board container computes `cell_size` dynamically:
     $$\text{cell\_size} = \min\left(\frac{W_{\text{available}}}{C}, \frac{H_{\text{available}}}{R}\right) \times 0.92$$
   - This ensures puzzle fits comfortably on any screen from 16:9 phones to 4:3 tablets.

---

## 3. MICRO-INTERACTIONS & JUICE

1. **Button Presses**:
   - Press down: Scale down to `0.94` in 0.08s.
   - Release: Bounce back to `1.0` in 0.12s (`Tween.TRANS_BACK`, `Tween.EASE_OUT`).
   - Trigger soft click sound and 5ms light haptic.
2. **Win Celebration**:
   - Board smoothly fades/scales down slightly (`0.95`).
   - Victory modal drops from top with elastic ease (`Tween.TRANS_SPRING`).
   - Stars illuminate sequentially with a 0.15s stagger and rising pitch tone.
