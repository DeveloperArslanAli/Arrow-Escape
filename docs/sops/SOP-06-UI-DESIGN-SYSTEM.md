# SOP-06: UI Design System (Arrows Puzzle Escape Match)
## Purpose & Scope
Standardizes the visual aesthetics to match *Arrows – Puzzle Escape*: curved sky-blue header, dual floating metric pills (Timer & Hearts), thick rounded polyline arrows, and bottom action buttons.

---

## 1. COLOR PALETTE SPECIFICATION

| Token | Hex Code | Visual Role |
| :--- | :--- | :--- |
| `COLOR_BG` | `#EBF3FC` | Soft ice-blue clean puzzle backdrop |
| `COLOR_HEADER_BG` | `#4D90EE` | Vibrant sky-blue curved top banner |
| `COLOR_HEADER_DARK` | `#356BB3` | Progress pill bar on top header |
| `COLOR_PILL_BG` | `#FFFFFF` | Floating timer and hearts background pill |
| `COLOR_PILL_BORDER` | `#D5E4F5` | Subtle border around metric pills |
| `COLOR_HEART` | `#E74C3C` | Vibrant red heart icons |
| `COLOR_BUTTON_BLUE`| `#4D90EE` | Circular action buttons (Restart, Pause) |

---

## 2. HUD COMPOSITION & LAYOUT

1. **Top Curved Header**:
   - Spans full width with bottom rounded corners (`corner_radius_bottom_left = 24`, `corner_radius_bottom_right = 24`).
   - Left: Circular Restart button (blue background, white circular reload icon).
   - Center: "Level X" in bold white typography with dark pill underneath.
   - Right: Circular Pause button (blue background, white `||` icon).
2. **Sub-Header Floating Pills**:
   - Left: White rounded pill with stopwatch icon `⏱ 0s`.
   - Right: White rounded pill with 3 heart icons `❤️❤️❤️`.
3. **Bottom Tool Bar**:
   - Left: Magnifying glass Hint button with small play icon `🔍 ▷`.
   - Right: Grid/Tool button `#`.

---

## 3. ARROW POLYLINE STYLING

- Line width: `12.0px` to `16.0px` depending on grid density.
- Caps & Joints: Rounded (`LINE_CAP_ROUND`, `LINE_JOINT_ROUND`).
- Head: Solid filled equilateral triangle pointing in head vector direction.
- Vibrant pastel/flat distinct color per arrow.
