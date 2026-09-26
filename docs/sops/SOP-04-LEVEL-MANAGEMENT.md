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

## 3. DIFFICULTY & PROGRESSION CURVE (50 LEVELS)

| Tier | Levels | Grid Dimensions | Winding Arrows | Solvability Depth | Target Time |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Tutorial** | 1 – 5 | 4x4 | 3 – 7 | 3 – 7 steps | < 20s |
| **Easy** | 6 – 15 | 5x5 | 5 – 8 | 5 – 8 steps | 20 – 45s |
| **Intermediate** | 16 – 30 | 6x6 | 8 – 12 | 8 – 12 steps | 45 – 90s |
| **Expert** | 31 – 50 | 7x7 | 11 – 15 | 11 – 15 steps | 90 – 180s |
