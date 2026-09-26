import json
import os
import random

LEVELS_DIR = r"e:\Projects\mobile application\Arrow Puzzle Game\data\levels"

DIRS = [(0, -1), (0, 1), (-1, 0), (1, 0)] # UP, DOWN, LEFT, RIGHT

# 8 Curated World Palettes
CHAPTER_PALETTES = [
    # World 1: Sky Breeze (1-25)
    ["#2B7DE9", "#E04848", "#27AE60", "#F39C12", "#8E44AD", "#F1C40F", "#00CEC9", "#E84393"],
    # World 2: Sunset Coral (26-50)
    ["#E65C40", "#D35400", "#E67E22", "#9B59B6", "#C0392B", "#F39C12", "#16A085", "#8E44AD"],
    # World 3: Emerald Glade (51-75)
    ["#10AC84", "#2ECC71", "#16A085", "#27AE60", "#F1C40F", "#3498DB", "#E67E22", "#9B59B6"],
    # World 4: Amethyst Twilight (76-100)
    ["#6C5CE7", "#8854D0", "#A29BFE", "#E84393", "#0984E3", "#FD79A8", "#00CEC9", "#FAB1A0"],
    # World 5: Oceanic Abyss (101-125)
    ["#0984E3", "#00CEC9", "#74B9FF", "#2B7DE9", "#E17055", "#55EFC4", "#F39C12", "#6C5CE7"],
    # World 6: Golden Dunes (126-150)
    ["#D48806", "#E67E22", "#D35400", "#C0392B", "#16A085", "#8E44AD", "#27AE60", "#34495E"],
    # World 7: Cherry Blossom (151-175)
    ["#D63031", "#E84393", "#B71540", "#E17055", "#6C5CE7", "#27AE60", "#00CEC9", "#F39C12"],
    # World 8: Midnight Obsidian (176-200)
    ["#00D2D3", "#FF9F43", "#EE5253", "#10AC84", "#54A0FF", "#5F27CD", "#FF6B6B", "#FECA57"]
]

DIFF_NAMES = [
    "tutorial", "easy", "intermediate", "advanced",
    "expert", "master", "grandmaster", "apex"
]

def is_ray_free(head, dir_vec, occ, cols, rows):
    curr = (head[0] + dir_vec[0], head[1] + dir_vec[1])
    while 0 <= curr[0] < cols and 0 <= curr[1] < rows:
        if curr in occ:
            return False
        curr = (curr[0] + dir_vec[0], curr[1] + dir_vec[1])
    return True

def generate_dense_level(level_id, cols, rows, min_arrows, max_arrows, target_fill, max_len_profile, diff, palette):
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
                    placed_gap = False
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
                                placed_gap = True
                                break
                                
        cur_fill = len(occ) / total_cells
        if cur_fill > best_fill:
            best_fill = cur_fill
            arrows_forward = []
            for idx, a in enumerate(reversed(arrows_reverse)):
                arrows_forward.append({
                    "id": f"arr_{idx + 1}",
                    "color": palette[idx % len(palette)],
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
            if best_fill >= target_fill and len(arrows_reverse) >= min_arrows:
                break
                
    return best_level

def build_level_specs():
    specs = []
    
    # 200 Levels across 8 Chapters (25 levels per chapter)
    for lvl in range(1, 201):
        chap_idx = (lvl - 1) // 25
        chap_lvl = (lvl - 1) % 25 + 1 # 1 to 25
        palette = CHAPTER_PALETTES[chap_idx]
        diff = DIFF_NAMES[chap_idx]
        
        # Chapter 1 (Levels 1-25) - Special onboarding curve
        if chap_idx == 0:
            if chap_lvl <= 5: # 1-5: 4x4
                min_a = 2 + (chap_lvl + 1) // 2
                max_a = 2 + chap_lvl
                specs.append((lvl, 4, 4, min_a, max_a, 0.45 + chap_lvl * 0.04, [2, 2, 3], "tutorial", palette))
            elif chap_lvl <= 10: # 6-10: 5x5
                idx = chap_lvl - 6
                min_a = 6 + idx // 2
                max_a = 7 + idx
                specs.append((lvl, 5, 5, min_a, max_a, 0.65 + idx * 0.025, [2, 3, 3, 4], "easy", palette))
            elif chap_lvl <= 20: # 11-20: 6x6 Step-Up!
                idx = chap_lvl - 11
                min_a = 10 + idx // 3
                max_a = 11 + idx
                specs.append((lvl, 6, 6, min_a, max_a, 0.78 + idx * 0.01, [2, 3, 3, 4], "intermediate", palette))
            else: # 21-25: 7x7 Finale
                idx = chap_lvl - 21
                min_a = 13 + idx // 2
                max_a = 15 + idx
                specs.append((lvl, 7, 7, min_a, max_a, 0.82 + idx * 0.015, [2, 3, 3, 4, 4], "advanced", palette))
        else:
            # Chapters 2 to 8 (Levels 26 to 200) - Rhythmic Challenge Wave
            # In each chapter of 25 levels:
            # Part 1 (Lv 1-5): 6x6 Chapter Opener / Breather (11-13 arrows, 80-86% fill)
            # Part 2 (Lv 6-15): 7x7 Serpentine Mazes (15-18 arrows, 82-89% fill)
            # Part 3 (Lv 16-23): 8x8 Labyrinths (19-23 arrows, 84-91% fill)
            # Part 4 (Lv 24-25): 8x8 Pinnacle Challenge (22-26 arrows, 88-94% fill!)
            if chap_lvl <= 5:
                idx = chap_lvl - 1
                min_a = 10 + (chap_idx // 3) + idx // 2
                max_a = 12 + idx
                specs.append((lvl, 6, 6, min_a, max_a, 0.80 + idx * 0.012, [2, 3, 3, 4], diff, palette))
            elif chap_lvl <= 15:
                idx = chap_lvl - 6
                min_a = 14 + (chap_idx // 2) + idx // 3
                max_a = 16 + idx
                specs.append((lvl, 7, 7, min_a, max_a, 0.82 + idx * 0.007, [2, 3, 3, 4, 4], diff, palette))
            elif chap_lvl <= 23:
                idx = chap_lvl - 16
                min_a = 18 + (chap_idx // 2) + idx // 3
                max_a = 21 + idx
                specs.append((lvl, 8, 8, min_a, max_a, 0.84 + idx * 0.008, [2, 3, 3, 4], diff, palette))
            else: # 24-25 Pinnacle
                idx = chap_lvl - 24
                min_a = 21 + (chap_idx // 2) + idx
                max_a = 24 + idx * 2
                specs.append((lvl, 8, 8, min_a, max_a, 0.88 + idx * 0.02, [2, 2, 3, 3, 4], diff, palette))
                
    return specs

def validate_level(data):
    if not data or "arrows" not in data or "grid_size" not in data:
        return False
    occ = {}
    rows = data["grid_size"]["rows"]
    cols = data["grid_size"]["columns"]
    for a in data["arrows"]:
        pts = a["points"]
        if len(pts) < 2:
            return False
        for i, p in enumerate(pts):
            coord = (p[0], p[1])
            if coord[0] < 0 or coord[0] >= cols or coord[1] < 0 or coord[1] >= rows:
                return False
            if coord in occ:
                return False
            occ[coord] = a["id"]
            if i > 0:
                prev = pts[i - 1]
                dist = abs(coord[0] - prev[0]) + abs(coord[1] - prev[1])
                if dist != 1:
                    return False
    return True

def main():
    random.seed(2026)
    os.makedirs(LEVELS_DIR, exist_ok=True)
    
    specs = build_level_specs()
    print(f"Generating {len(specs)} levels with strict validation...")
    
    for lvl, c, r, min_a, max_a, target_fill, profile, diff, palette in specs:
        data = None
        for retry in range(10):
            data = generate_dense_level(lvl, c, r, min_a, max_a, target_fill, profile, diff, palette)
            if validate_level(data):
                break
        if not validate_level(data):
            print(f"CRITICAL ERROR: Failed to validate Level {lvl}")
            
        out_path = os.path.join(LEVELS_DIR, f"level_{lvl:03d}.json")
        with open(out_path, "w", encoding="utf-8") as fp:
            json.dump(data, fp, indent=2)
        total_c = c * r
        occ_c = sum(len(a["points"]) for a in data["arrows"])
        if lvl % 25 == 0 or lvl == 1 or lvl == 200:
            print(f"Level {lvl:03d} [{diff:12s}]: Grid {c}x{r} | Arrows: {len(data['arrows']):2d} | Cells: {occ_c:2d}/{total_c:2d} ({occ_c/total_c*100:.1f}%)")

    print("All 200 levels generated and validated successfully!")

if __name__ == "__main__":
    main()
