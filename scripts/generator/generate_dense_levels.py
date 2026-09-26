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

def is_ray_free(head, dir_vec, occ, cols, rows):
    cx = head[0] + dir_vec[0]
    cy = head[1] + dir_vec[1]
    while 0 <= cx < cols and 0 <= cy < rows:
        if (cx, cy) in occ:
            return False
        cx += dir_vec[0]
        cy += dir_vec[1]
    return True

def generate_dense_level(level_id, cols, rows, min_arrows, max_arrows, target_fill, max_len_profile, diff, palette):
    total_cells = cols * rows
    best_level = None
    best_fill = 0.0
    
    # Adaptive attempts based on board scale for optimal runtime
    if cols <= 6:
        max_attempts = 50
    elif cols <= 10:
        max_attempts = 25
    elif cols <= 14:
        max_attempts = 15
    else:
        max_attempts = 8
    
    for attempt in range(max_attempts):
        occ = {}
        arrows_reverse = []
        empty_cells = set((c, r) for c in range(cols) for r in range(rows))
        
        while len(arrows_reverse) < max_arrows and (len(occ) / total_cells) < target_fill:
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
            target_len = random.choice(max_len_profile)
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
            
        # Fast Gap-filler on remaining empty cells
        for c, r in list(empty_cells):
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
                    "two_stars": len(arrows_forward) + (2 if len(arrows_forward) <= 12 else 4)
                },
                "arrows": arrows_forward
            }
            if best_fill >= target_fill * 0.95 and len(arrows_reverse) >= min_arrows:
                break
                
    return best_level

def build_level_specs():
    specs = []
    
    # 200 Levels across 8 Chapters (25 levels per chapter)
    # Chapter 1: 4x4 -> 6x6
    # Chapter 2: 6x6 -> 8x8
    # Chapter 3: 8x8 -> 10x10
    # Chapter 4: 10x10 -> 12x12
    # Chapter 5: 12x12 -> 14x14
    # Chapter 6: 14x14 -> 16x16
    # Chapter 7: 16x16 -> 18x18
    # Chapter 8: 18x18 -> 20x20
    
    for lvl in range(1, 201):
        chap_idx = (lvl - 1) // 25
        chap_lvl = (lvl - 1) % 25 + 1 # 1 to 25
        palette = CHAPTER_PALETTES[chap_idx]
        diff = DIFF_NAMES[chap_idx]
        
        base_dim = 4 + chap_idx * 2 # 4, 6, 8, 10, 12, 14, 16, 18
        
        # 3-tier integer progression within each 25-level chapter
        if chap_lvl <= 8:
            dim = base_dim
            sub_idx = chap_lvl - 1
            ratio = sub_idx / 8.0
        elif chap_lvl <= 16:
            dim = base_dim + 1
            sub_idx = chap_lvl - 9
            ratio = sub_idx / 8.0
        else:
            dim = base_dim + 2
            sub_idx = chap_lvl - 17
            ratio = sub_idx / 9.0
            
        total_c = dim * dim
        
        # Target fill and arrow profile smoothly parameterized by grid scale
        if dim <= 5:
            min_a = max(2, int(total_c * 0.20))
            max_a = int(total_c * 0.35)
            target_fill = 0.50 + ratio * 0.15
            profile = [2, 2, 3] if dim == 4 else [2, 3, 3, 4]
        elif dim <= 8:
            min_a = int(total_c * 0.24)
            max_a = int(total_c * 0.38)
            target_fill = 0.72 + ratio * 0.12
            profile = [2, 3, 3, 4, 4]
        elif dim <= 12:
            min_a = int(total_c * 0.22)
            max_a = int(total_c * 0.35)
            target_fill = 0.68 + ratio * 0.10
            profile = [2, 3, 3, 4, 4, 5]
        elif dim <= 16:
            min_a = int(total_c * 0.20)
            max_a = int(total_c * 0.32)
            target_fill = 0.64 + ratio * 0.08
            profile = [2, 3, 3, 4, 4, 5]
        else: # 17 to 20
            min_a = int(total_c * 0.18)
            max_a = int(total_c * 0.28)
            target_fill = 0.62 + ratio * 0.08
            profile = [2, 3, 3, 4, 4, 5]
            
        specs.append((lvl, dim, dim, min_a, max_a, target_fill, profile, diff, palette))
                
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
    print(f"Generating {len(specs)} levels with strict validation across 8 Worlds (4x4 to 20x20)...")
    start_time = time.time()
    
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
            print(f"Level {lvl:03d} [{diff:12s}]: Grid {c:2d}x{r:2d} | Arrows: {len(data['arrows']):2d} | Cells: {occ_c:3d}/{total_c:3d} ({occ_c/total_c*100:.1f}%)")

    total_time = round(time.time() - start_time, 2)
    print(f"All 200 levels generated and validated successfully in {total_time}s!")

if __name__ == "__main__":
    main()
