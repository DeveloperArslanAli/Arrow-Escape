# SOP-04: Level Data Architecture & Progression (Winding Polyline Edition)
## Purpose & Scope
Specifies the canonical JSON schema for winding polyline levels, data validation gates, pack organization, and dynamic loading procedures.

---

## 1. LEVEL JSON SCHEMA DEFINITION

Every level file in `res://data/levels/level_XXX.json` must strictly conform to this structure:

```json
{
  "level_id": 11,
  "difficulty": "easy",
  "grid_size": {
    "rows": 5,
    "columns": 5
  },
  "star_thresholds": {
    "three_stars": 6,
    "two_stars": 8
  },
  "arrows": [
    {
      "id": "arr_1",
      "color": "#2B7DE9",
      "points": [
        [0, 2],
        [1, 2],
        [1, 1],
        [2, 1]
      ]
    },
    {
      "id": "arr_2",
      "color": "#E04848",
      "points": [
        [3, 3],
        [3, 2],
        [4, 2]
      ]
    }
  ]
}
```

- `points[0]` is the **tail**.
- `points[-1]` is the **arrowhead**.
- Consecutive points must be strictly orthogonally adjacent: $|c_{j+1} - c_j| + |r_{j+1} - r_j| = 1$.

---

## 2. STRICT VALIDATION CONSTRAINTS

Prior to accepting any level into the release package:
1. `level_id` must match file naming convention `level_%03d.json`.
2. `grid_size.rows >= 3` and `grid_size.columns >= 3`.
3. For every arrow $i$:
   - $\text{points.size()} \ge 2$.
   - Every point must satisfy $0 \le c < \text{columns}$ and $0 \le r < \text{rows}$.
   - No two points of the same or different arrows may overlap (single occupancy).
4. **Mandatory Solvability**: Automated headless solver must confirm at least one path to empty board.

---

## 3. DIFFICULTY & PROGRESSION CURVE (200 LEVELS / 8 WORLDS)

| World / Chapter | Levels | Grid Dimensions | Arrow Count | Cell Saturation | Target Time |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **World 1: Sky Breeze** | 1 – 25 | 4x4 $\to$ 7x7 | 3 – 15 | 50.0% – 89.8% | 15 – 45s |
| **World 2: Sunset Coral** | 26 – 50 | 7x7 $\to$ 8x8 | 15 – 23 | 85.0% – 92.2% | 45 – 90s |
| **World 3: Emerald Glade** | 51 – 75 | 8x8 | 20 – 24 | 88.0% – 92.2% | 60 – 120s |
| **World 4: Amethyst Twilight** | 76 – 100 | 8x8 | 20 – 24 | 88.0% – 92.2% | 75 – 130s |
| **World 5: Oceanic Abyss** | 101 – 125 | 8x8 | 21 – 24 | 89.0% – 92.2% | 90 – 140s |
| **World 6: Golden Dunes** | 126 – 150 | 8x8 | 21 – 24 | 89.0% – 92.2% | 90 – 150s |
| **World 7: Cherry Blossom** | 151 – 175 | 8x8 | 20 – 23 | 89.0% – 92.2% | 90 – 160s |
| **World 8: Midnight Obsidian** | 176 – 200 | 8x8 | 21 – 24 | 89.0% – 92.2% | 90 – 180s |

