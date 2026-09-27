"""
Generate publication-grade 512x512 app icon and 1024x500 feature graphic for Google Play Store.
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import os

os.makedirs("assets/store", exist_ok=True)

def create_rounded_rect(draw, bbox, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(bbox, radius=radius, fill=fill, outline=outline, width=width)

def draw_arrow(draw, center_x, center_y, size, angle_deg, fill_color, border_color="#1E232A", border_w=8):
    # Base arrow pointing up centered at (0,0)
    # Unit coords:
    # Tip: (0, -0.9)
    # Right corner: (0.6, -0.15)
    # Right inner: (0.25, -0.15)
    # Right base: (0.25, 0.85)
    # Left base: (-0.25, 0.85)
    # Left inner: (-0.25, -0.15)
    # Left corner: (-0.6, -0.15)
    pts = [
        (0.0, -0.85),
        (0.55, -0.15),
        (0.22, -0.15),
        (0.22, 0.80),
        (-0.22, 0.80),
        (-0.22, -0.15),
        (-0.55, -0.15)
    ]
    rad = math.radians(angle_deg)
    cos_a = math.cos(rad)
    sin_a = math.sin(rad)
    
    transformed = []
    for x, y in pts:
        rx = (x * cos_a - y * sin_a) * size + center_x
        ry = (x * sin_a + y * cos_a) * size + center_y
        transformed.append((rx, ry))
    
    # Shadow/Border
    if border_w > 0:
        draw.polygon(transformed, fill=fill_color, outline=border_color, width=border_w)
    else:
        draw.polygon(transformed, fill=fill_color)

def generate_app_icon():
    size = 512
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Outer base tile (Soft Ice / Warm Slate)
    # Draw soft rounded square with subtle depth
    margin = 16
    r = 110
    
    # Drop shadow
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow)
    create_rounded_rect(s_draw, (margin + 6, margin + 14, size - margin + 6, size - margin + 14), r, (15, 23, 42, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(16))
    img.alpha_composite(shadow)
    
    # Main tile surface - sleek modern frosted card
    draw = ImageDraw.Draw(img)
    create_rounded_rect(draw, (margin, margin, size - margin, size - margin), r, "#F3F7FC", outline="#D0DEEB", width=4)
    
    # Subtle inner border
    inner_m = margin + 18
    create_rounded_rect(draw, (inner_m, inner_m, size - inner_m, size - inner_m), r - 12, "#E5EFF9", outline="#CBDCF0", width=3)
    
    # Draw stylized arrow trio reflecting the puzzle mechanics
    # Background accent arrows
    draw_arrow(draw, 185, 335, 110, 45, "#F78D74", border_color="#303A46", border_w=6)  # Coral arrow
    draw_arrow(draw, 345, 315, 105, -35, "#3BB78F", border_color="#303A46", border_w=6) # Jade arrow
    
    # Main hero Azure arrow pointing up-right escaping the grid
    # Soft glow for hero arrow
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    g_draw = ImageDraw.Draw(glow)
    draw_arrow(g_draw, 256, 225, 175, 25, (56, 140, 245, 160), border_color=(0,0,0,0), border_w=0)
    glow = glow.filter(ImageFilter.GaussianBlur(14))
    img.alpha_composite(glow)
    
    draw = ImageDraw.Draw(img)
    draw_arrow(draw, 256, 225, 175, 25, "#3B82F6", border_color="#1E293B", border_w=10)
    
    icon_path = "assets/store/icon_512.png"
    img.save(icon_path, "PNG")
    print(f"Generated {icon_path}")

def generate_feature_graphic():
    w, h = 1024, 500
    img = Image.new("RGBA", (w, h), "#0F172A")
    draw = ImageDraw.Draw(img)
    
    # Subtle gradient / background dots
    for x in range(30, w, 40):
        for y in range(30, h, 40):
            draw.ellipse((x, y, x + 3, y + 3), fill=(255, 255, 255, 18))
            
    # Draw puzzle grid representation on right
    grid_cx, grid_cy = 730, 250
    # Floating puzzle board
    create_rounded_rect(draw, (grid_cx - 190, grid_cy - 190, grid_cx + 190, grid_cy + 190), 32, (30, 41, 59, 230), outline=(51, 65, 85, 255), width=3)
    
    # Arrows on the board
    draw_arrow(draw, grid_cx - 90, grid_cy - 70, 70, 0, "#3B82F6", border_color="#0F172A", border_w=5)
    draw_arrow(draw, grid_cx + 80, grid_cy - 80, 65, 90, "#F97316", border_color="#0F172A", border_w=5)
    draw_arrow(draw, grid_cx - 80, grid_cy + 80, 65, -90, "#10B981", border_color="#0F172A", border_w=5)
    draw_arrow(draw, grid_cx + 70, grid_cy + 75, 75, 180, "#A855F7", border_color="#0F172A", border_w=5)
    draw_arrow(draw, grid_cx, grid_cy, 85, 45, "#E2E8F0", border_color="#0F172A", border_w=6)
    
    # Left typography
    # Big title: ARROW ESCAPE
    try:
        font_title = ImageFont.truetype("arialbd.ttf", 64)
        font_sub = ImageFont.truetype("arial.ttf", 26)
        font_badge = ImageFont.truetype("arialbd.ttf", 20)
    except:
        font_title = ImageFont.load_default()
        font_sub = ImageFont.load_default()
        font_badge = ImageFont.load_default()
        
    draw.text((70, 110), "ARROW ESCAPE", fill="#FFFFFF", font=font_title)
    draw.text((70, 190), "Untangle the Grid • Master the Flow", fill="#94A3B8", font=font_sub)
    draw.text((70, 230), "200 Solvable Levels across 8 Thematic Worlds", fill="#64748B", font=font_sub)
    
    # Badges
    b1_x = 70
    create_rounded_rect(draw, (b1_x, 310, b1_x + 160, 360), 16, "#1E293B", outline="#3B82F6", width=2)
    draw.text((b1_x + 22, 324), "4x4 → 20x20", fill="#60A5FA", font=font_badge)
    
    b2_x = b1_x + 180
    create_rounded_rect(draw, (b2_x, 310, b2_x + 180, 360), 16, "#1E293B", outline="#10B981", width=2)
    draw.text((b2_x + 20, 324), "100% Solvable", fill="#34D399", font=font_badge)
    
    b3_x = b2_x + 200
    create_rounded_rect(draw, (b3_x, 310, b3_x + 160, 360), 16, "#1E293B", outline="#F97316", width=2)
    draw.text((b3_x + 24, 324), "Pure Offline", fill="#FB923C", font=font_badge)
    
    feat_path = "assets/store/feature_graphic_1024x500.png"
    img.save(feat_path, "PNG")
    print(f"Generated {feat_path}")

if __name__ == "__main__":
    generate_app_icon()
    generate_feature_graphic()
