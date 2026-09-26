# SOP-04: Level Data Architecture & Progression
## Purpose & Scope
Specifies the canonical JSON schema for levels, data validation gates, pack organization, and dynamic loading procedures.

---

## 1. LEVEL JSON SCHEMA DEFINITION

Every level file in `res://data/levels/level_XXX.json` must strictly conform to this structure:

```json
{
  "level_id": 1,
  "difficulty": "tutorial",
  "grid_size": {
    "rows": 3,
    "columns": 3
  },
  "star_thresholds": {
    "three_stars": 3,
    "two_stars": 5
  },
  "arrows": [
    {
      "id": "arrow_1",
      "row": 1,
      "column": 0,
      "direction": "left"
    },
    {
      "id": "arrow_2",
      "row": 1,
      "column": 1,
      "direction": "down"
    },
    {
      "id": "arrow_3",
      "row": 2,
      "column": 1,
      "direction": "right"
    }
  ]
}
```

---

## 2. STRICT VALIDATION CONSTRAINTS

Prior to loading or accepting any level into the release bundle:
1. `level_id` must match file naming convention `level_%03d.json`.
2. `grid_size.rows >= 2` and `grid_size.columns >= 2`.
3. For every arrow $i$:
   - $0 \le \text{row}_i < \text{rows}$
   - $0 \le \text{column}_i < \text{columns}$
   - `direction` $\in \{\text{"up"}, \text{"down"}, \text{"left"}, \text{"right"}\}$
4. **No Coordinate Collisions**: No two arrows may share the same `(row, column)`.
5. **Mandatory Solvability**: Automated headless solver must confirm at least one path to empty board.

---

## 3. DIFFICULTY & PROGRESSION CURVE

| Tier | Levels | Grid Dimensions | Arrow Count | Solvability Depth | Target Time |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Tutorial** | 1 – 5 | 3x3 | 2 – 4 | 2 – 4 steps | < 15s |
| **Easy** | 6 – 20 | 4x4 | 5 – 8 | 5 – 8 steps | 20 – 40s |
| **Intermediate** | 21 – 50 | 5x5 | 9 – 15 | 9 – 15 steps | 45 – 90s |
| **Advanced** | 51 – 100 | 6x6 | 16 – 24 | 16 – 24 steps | 2 – 3 min |
| **Expert** | 101+ | 7x7 to 8x8 | 25 – 36 | 25+ steps | 3 – 5 min |
