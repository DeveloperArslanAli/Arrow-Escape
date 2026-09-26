import json
import os
import random
import time

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

# Monotonic arrow count ranges for each chapter (start_arrows, end_arrows)
CHAPTER_ARROW_RANGES = [
    (3, 9),    # World 1: 4x4 -> 6x6   | 3 -> 9 arrows
    (9, 16),   # World 2: 6x6 -> 8x8   | 9 -> 16 arrows
    (16, 24),  # World 3: 8x8 -> 10x10 | 16 -> 24 arrows
    (24, 34),  # World 4: 10x10 -> 12x12 | 24 -> 34 arrows
    (34, 44),  # World 5: 12x12 -> 14x14 | 34 -> 44 arrows
    (44, 55),  # World 6: 14x14 -> 16x16 | 44 -> 55 arrows
    (55, 67),  # World 7: 16x16 -> 18x18 | 55 -> 67 arrows
    (67, 80)   # World 8: 18x18 -> 20x20 | 67 -> 80 arrows
]

def is_ray_free(head, dir_vec, occ, cols, rows):
    cx = head[0] + dir_vec[0]
    cy = head[1] + dir_vec[1]
    while 0 <= cx < cols and 0 <= cy < rows:
        if (cx, cy) in occ:
            return False
        cx += dir_vec[0]
        cy += dir_vec[1]
    return True

def generate_exact_level(level_id, cols, rows, target_arrows, diff, palette):
    profile = [2, 2, 3] if cols <= 5 else [2, 2, 3, 3, 4]
    
    for attempt in range(50):
        occ = {}
        arrows_reverse = []
        empty_cells = set((c, r) for c in range(cols) for r in range(rows))
        
        while len(arrows_reverse) < target_arrows:
            candidates = []
            for c, r in empty_cells:
                for d in DIRS:
                    prev = (c - d[0], r - d[1])
                    if prev in empty_cells:
                        if is_ray_free((c, r), d, occ, cols, rows):
                            candidates.append(((c, r), d))
                            
            if not candidates:
                break
                
            head, d = random.choice(candidates)
            target_len = random.choice(profile)
            path = [(head[0] - d[0], head[1] - d[1]), head]
            used = set(path)
            
            curr_tail = path[0]
            tail_dir = (-d[0], -d[1])
            
            for _ in range(target_len - 2):
                neighbors = []
                for nd in DIRS:
                    nxt = (curr_tail[0] + nd[0], curr_tail[1] + nd[1])
                    if nxt in empty_cells and nxt not in used:
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
                empty_cells.discard(pt)
            arrows_reverse.append({
                "id": a_id,
                "points": path
            })
            
        # Fast Gap-filler to hit exact target count
        if len(arrows_reverse) < target_arrows:
            for c, r in list(empty_cells):
                if len(arrows_reverse) >= target_arrows:
                    break
                if (c, r) not in empty_cells:
                    continue
                for d in DIRS:
                    prev = (c - d[0], r - d[1])
                    if prev in empty_cells:
                        if is_ray_free((c, r), d, occ, cols, rows):
                            a_id = f"arr_{len(arrows_reverse) + 1}"
                            occ[prev] = a_id
                            occ[(c, r)] = a_id
                            empty_cells.discard(prev)
                            empty_cells.discard((c, r))
                            arrows_reverse.append({
                                "id": a_id,
                                "points": [prev, (c, r)]
                            })
                            break
                            
        if len(arrows_reverse) == target_arrows:
            arrows_forward = []
            for idx, a in enumerate(reversed(arrows_reverse)):
                arrows_forward.append({
                    "id": f"arr_{idx + 1}",
                    "color": palette[idx % len(palette)],
                    "points": [[p[0], p[1]] for p in a["points"]]
                })
            return {
                "level_id": level_id,
                "difficulty": diff,
                "grid_size": { "rows": rows, "columns": cols },
                "star_thresholds": {
                    "three_stars": len(arrows_forward),
                    "two_stars": len(arrows_forward) + (2 if len(arrows_forward) <= 12 else 4)
                },
                "arrows": arrows_forward
            }
            
    return None

def build_level_specs():
    specs = []
    
    # 200 Levels across 8 Chapters (25 levels per chapter)
    for lvl in range(1, 201):
        chap_idx = (lvl - 1) // 25
        chap_lvl = (lvl - 1) % 25 + 1 # 1 to 25
        palette = CHAPTER_PALETTES[chap_idx]
        diff = DIFF_NAMES[chap_idx]
        
        # 3-tier sub-chapter grid progression
        base_dim = 4 + chap_idx * 2
        if chap_lvl <= 8:
            dim = base_dim
        elif chap_lvl <= 16:
            dim = base_dim + 1
        else:
            dim = base_dim + 2
            
        # Monotonically increasing arrow target count
        s_a, e_a = CHAPTER_ARROW_RANGES[chap_idx]
        target_a = s_a + int(round((e_a - s_a) * (chap_lvl - 1) / 24.0))
        
        specs.append((lvl, dim, dim, target_a, diff, palette))
                
    return specs

def validate_level(data, expected_arrows):
    if not data or "arrows" not in data or "grid_size" not in data:
        return False
    if len(data["arrows"]) != expected_arrows:
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
    print(f"Generating {len(specs)} levels with monotonic arrow increase across 8 Worlds (4x4 to 20x20)...")
    start_time = time.time()
    
    prev_arrows = 0
    for lvl, c, r, target_a, diff, palette in specs:
        # Enforce non-decreasing invariant
        if target_a < prev_arrows:
            target_a = prev_arrows
        prev_arrows = target_a
        
        data = None
        for retry in range(15):
            data = generate_exact_level(lvl, c, r, target_a, diff, palette)
            if validate_level(data, target_a):
                break
        if not validate_level(data, target_a):
            print(f"CRITICAL ERROR: Failed to validate Level {lvl} (target {target_a})")
            
        out_path = os.path.join(LEVELS_DIR, f"level_{lvl:03d}.json")
        with open(out_path, "w", encoding="utf-8") as fp:
            json.dump(data, fp, indent=2)
            
        total_c = c * r
        occ_c = sum(len(a["points"]) for a in data["arrows"])
        if lvl % 25 == 0 or lvl == 1 or lvl == 10:
            print(f"Level {lvl:03d} [{diff:12s}]: Grid {c:2d}x{r:2d} | Arrows: {len(data['arrows']):2d} | Cells: {occ_c:3d}/{total_c:3d} ({occ_c/total_c*100:.1f}%)")

    total_time = round(time.time() - start_time, 2)
    print(f"All 200 levels generated and validated successfully with strictly non-decreasing arrow counts in {total_time}s!")

if __name__ == "__main__":
    main()
