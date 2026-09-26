import json
import os
import random

LEVELS_DIR = r"e:\Projects\mobile application\Arrow Puzzle Game\data\levels"

DIRS = [(0, -1), (0, 1), (-1, 0), (1, 0)] # UP, DOWN, LEFT, RIGHT

COLORS = [
    "#2B7DE9", # Blue
    "#E04848", # Red
    "#27AE60", # Green
    "#F39C12", # Orange
    "#8E44AD", # Purple
    "#F1C40F", # Yellow
    "#E84393", # Pink
    "#2C3E50", # Deep Navy
    "#00CEC9", # Cyan / Teal
    "#16A085", # Sea Green
    "#D35400", # Rust Orange
    "#8854D0"  # Lavender Violet
]

def is_ray_free(head, dir_vec, occ, cols, rows):
    curr = (head[0] + dir_vec[0], head[1] + dir_vec[1])
    while 0 <= curr[0] < cols and 0 <= curr[1] < rows:
        if curr in occ:
            return False
        curr = (curr[0] + dir_vec[0], curr[1] + dir_vec[1])
    return True

def generate_dense_level(level_id, cols, rows, min_arrows, max_arrows, target_fill, max_len_profile, diff):
    total_cells = cols * rows
    best_level = None
    best_fill = 0.0
    
    for attempt in range(150):
        occ = {}
        arrows_reverse = []
        
        while len(arrows_reverse) < max_arrows and (len(occ) / total_cells) < target_fill:
            candidates = []
            for r in range(rows):
                for c in range(cols):
                    if (c, r) in occ:
                        continue
                    for d in DIRS:
                        prev = (c - d[0], r - d[1])
                        if 0 <= prev[0] < cols and 0 <= prev[1] < rows and prev not in occ:
                            if is_ray_free((c, r), d, occ, cols, rows):
                                candidates.append(((c, r), d))
                                
            if not candidates:
                break
                
            head, d = random.choice(candidates)
            target_len = random.choice(max_len_profile)
            path = [(head[0] - d[0], head[1] - d[1]), head]
            used = set(path)
            
            curr_tail = path[0]
            tail_dir = (-d[0], -d[1])
            
            for _ in range(target_len - 2):
                neighbors = []
                for nd in DIRS:
                    nxt = (curr_tail[0] + nd[0], curr_tail[1] + nd[1])
                    if 0 <= nxt[0] < cols and 0 <= nxt[1] < rows:
                        if nxt not in occ and nxt not in used:
                            weight = 2 if nd == tail_dir else 3
                            neighbors.extend([nxt] * weight)
                if not neighbors:
                    break
                nxt_tail = random.choice(neighbors)
                tail_dir = (nxt_tail[0] - curr_tail[0], nxt_tail[1] - curr_tail[1])
                path.insert(0, nxt_tail)
                used.add(nxt_tail)
                curr_tail = nxt_tail
                
            a_id = f"arr_{len(arrows_reverse) + 1}"
            for pt in path:
                occ[pt] = a_id
            arrows_reverse.append({
                "id": a_id,
                "points": path
            })
            
        # Gap-filler: Check for 2-cell micro-arrows in remaining pockets
        if (len(occ) / total_cells) < target_fill and len(arrows_reverse) < max_arrows:
            for r in range(rows):
                for c in range(cols):
                    if (c, r) in occ:
                        continue
                    for d in DIRS:
                        prev = (c - d[0], r - d[1])
                        if 0 <= prev[0] < cols and 0 <= prev[1] < rows and prev not in occ:
                            if is_ray_free((c, r), d, occ, cols, rows):
                                a_id = f"arr_{len(arrows_reverse) + 1}"
                                occ[prev] = a_id
                                occ[(c, r)] = a_id
                                arrows_reverse.append({
                                    "id": a_id,
                                    "points": [prev, (c, r)]
                                })
                                break
                                
        cur_fill = len(occ) / total_cells
        if len(arrows_reverse) >= min_arrows and cur_fill > best_fill:
            best_fill = cur_fill
            arrows_forward = []
            for idx, a in enumerate(reversed(arrows_reverse)):
                arrows_forward.append({
                    "id": f"arr_{idx + 1}",
                    "color": COLORS[idx % len(COLORS)],
                    "points": [[p[0], p[1]] for p in a["points"]]
                })
            best_level = {
                "level_id": level_id,
                "difficulty": diff,
                "grid_size": { "rows": rows, "columns": cols },
                "star_thresholds": {
                    "three_stars": len(arrows_forward),
                    "two_stars": len(arrows_forward) + (2 if len(arrows_forward) <= 12 else 3)
                },
                "arrows": arrows_forward
            }
            if best_fill >= target_fill:
                break
                
    if best_level is None:
        # Guaranteed baseline
        arrows_forward = []
        for idx in range(min_arrows):
            r = idx % rows
            c = (idx * 2) % cols
            c2 = min(c + 1, cols - 1)
            arrows_forward.append({
                "id": f"arr_{idx + 1}",
                "color": COLORS[idx % len(COLORS)],
                "points": [[c, r], [c2, r]]
            })
        best_level = {
            "level_id": level_id,
            "difficulty": diff,
            "grid_size": { "rows": rows, "columns": cols },
            "star_thresholds": { "three_stars": min_arrows, "two_stars": min_arrows + 2 },
            "arrows": arrows_forward
        }
        
    return best_level

def main():
    random.seed(9876)
    os.makedirs(LEVELS_DIR, exist_ok=True)
    
    level_specs = []
    
    # 1. Levels 1-5: Tutorial / Intro (4x4, 3 to 5 arrows, fill 45-65%)
    for lvl in range(1, 6):
        min_a = 2 + (lvl + 1) // 2
        max_a = 2 + lvl
        level_specs.append((lvl, 4, 4, min_a, max_a, 0.45 + lvl * 0.04, [2, 2, 3], "tutorial"))
        
    # 2. Levels 6-10: Casual / Foundation (5x5, 6 to 8 arrows, fill 65-76%)
    for lvl in range(6, 11):
        idx = lvl - 6
        min_a = 6 + idx // 2
        max_a = 7 + idx
        level_specs.append((lvl, 5, 5, min_a, max_a, 0.65 + idx * 0.025, [2, 3, 3, 4], "easy"))
        
    # 3. Levels 11-20: Intermediate Step-Up (6x6, 10 to 14 arrows, fill 78-88%)
    for lvl in range(11, 21):
        idx = lvl - 11
        min_a = 9 + idx // 3
        max_a = 11 + idx
        level_specs.append((lvl, 6, 6, min_a, max_a, 0.78 + (idx * 0.01), [2, 3, 3, 4], "intermediate"))
        
    # 4. Levels 21-35: Advanced Mazes (7x7, 14 to 18 arrows, fill 80-88%)
    for lvl in range(21, 36):
        idx = lvl - 21
        min_a = 13 + idx // 4
        max_a = 15 + idx
        level_specs.append((lvl, 7, 7, min_a, max_a, 0.80 + (idx * 0.005), [2, 3, 3, 4, 4], "advanced"))
        
    # 5. Levels 36-40: Expert 7x7 (17 to 20 arrows, fill 84-90%)
    for lvl in range(36, 41):
        idx = lvl - 36
        min_a = 16 + idx // 2
        max_a = 18 + idx
        level_specs.append((lvl, 7, 7, min_a, max_a, 0.84 + idx * 0.01, [2, 2, 3, 3, 4], "expert"))
        
    # 6. Levels 41-50: Master Saturated Mazes (8x8, 19 to 25 arrows, fill 82-90%)
    for lvl in range(41, 51):
        idx = lvl - 41
        min_a = 18 + idx // 2
        max_a = 21 + idx
        level_specs.append((lvl, 8, 8, min_a, max_a, 0.82 + idx * 0.008, [2, 3, 3, 4], "master"))
        
    for lvl, c, r, min_a, max_a, target_fill, profile, diff in level_specs:
        data = generate_dense_level(lvl, c, r, min_a, max_a, target_fill, profile, diff)
        out_path = os.path.join(LEVELS_DIR, f"level_{lvl:03d}.json")
        with open(out_path, "w", encoding="utf-8") as fp:
            json.dump(data, fp, indent=2)
        total_c = c * r
        occ_c = sum(len(a["points"]) for a in data["arrows"])
        print(f"Level {lvl:02d} [{diff:12s}]: Grid {c}x{r} | Arrows: {len(data['arrows']):2d} | Cells: {occ_c:2d}/{total_c:2d} ({occ_c/total_c*100:.1f}%)")

if __name__ == "__main__":
    main()
