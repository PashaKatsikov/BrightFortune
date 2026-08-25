"""
Slices source sprite sheets from assets/Bright_Fortune_gameplay_assets and
assets/Bright_Fortune_additional_assets into individual, tightly-cropped PNG
sprites used by the Flutter game, and copies full-size background/screen
images into their final destination folders.
"""
import os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GAMEPLAY_SRC = os.path.join(ROOT, "assets", "Bright_Fortune_gameplay_assets")
ADDITIONAL_SRC = os.path.join(ROOT, "assets", "Bright_Fortune_additional_assets")

OUT_SPRITES = os.path.join(ROOT, "assets", "game", "sprites")
OUT_BACKGROUNDS = os.path.join(ROOT, "assets", "game", "backgrounds")
OUT_UI = os.path.join(ROOT, "assets", "game", "ui")

os.makedirs(OUT_SPRITES, exist_ok=True)
os.makedirs(OUT_BACKGROUNDS, exist_ok=True)
os.makedirs(OUT_UI, exist_ok=True)

PAD = 6  # padding pixels kept around autocropped content


def autocrop(im: Image.Image, pad=PAD) -> Image.Image:
    alpha = im.split()[-1]
    bbox = alpha.getbbox()
    if bbox is None:
        return im
    l, t, r, b = bbox
    l = max(0, l - pad)
    t = max(0, t - pad)
    r = min(im.width, r + pad)
    b = min(im.height, b + pad)
    return im.crop((l, t, r, b))


def content_groups(mask_1d, gap=6):
    """Given a 1D boolean array, return list of (start, end) inclusive ranges
    of contiguous True regions, merging gaps smaller than `gap` pixels."""
    idx = np.where(mask_1d)[0]
    if len(idx) == 0:
        return []
    groups = []
    start = idx[0]
    prev = idx[0]
    for x in idx[1:]:
        if x - prev > gap:
            groups.append((int(start), int(prev)))
            start = x
        prev = x
    groups.append((int(start), int(prev)))
    return groups


def slice_grid(filename, names, rows=1, cols=None, src_dir=GAMEPLAY_SRC, out_dir=OUT_SPRITES,
               row_gap=6, col_gap=6):
    """Auto-detects sprite cell boundaries by finding gaps of transparent
    pixels between icons, instead of assuming perfectly equal grid cells.
    This avoids bleed from neighboring icons that overlap equal-division
    boundaries."""
    if cols is None:
        cols = len(names) // rows
    path = os.path.join(src_dir, filename)
    im = Image.open(path).convert("RGBA")
    alpha = np.array(im.split()[-1])
    row_mask = alpha.max(axis=1) > 10
    row_groups = content_groups(row_mask, gap=row_gap)
    if rows == 1:
        row_groups = [(0, im.height - 1)]
    if len(row_groups) < rows:
        # fall back to equal split if detection failed
        rh = im.height // rows
        row_groups = [(r * rh, (r + 1) * rh - 1) for r in range(rows)]

    idx = 0
    for r in range(rows):
        rt, rb = row_groups[r]
        row_alpha = alpha[rt:rb + 1, :]
        col_mask = row_alpha.max(axis=0) > 10
        col_groups = content_groups(col_mask, gap=col_gap)
        if len(col_groups) < cols:
            cw = im.width // cols
            col_groups = [(c * cw, (c + 1) * cw - 1) for c in range(cols)]
        for c in range(cols):
            if idx >= len(names):
                break
            cl, cr = col_groups[c]
            cell = im.crop((cl, rt, cr + 1, rb + 1))
            cell = autocrop(cell)
            out_path = os.path.join(out_dir, names[idx] + ".png")
            cell.save(out_path)
            print("sliced", out_path, cell.size)
            idx += 1


def copy_single(filename, out_name, src_dir=GAMEPLAY_SRC, out_dir=OUT_SPRITES, crop=True):
    path = os.path.join(src_dir, filename)
    im = Image.open(path).convert("RGBA")
    if crop:
        im = autocrop(im)
    out_path = os.path.join(out_dir, out_name + ".png")
    im.save(out_path)
    print("copied", out_path, im.size)


# ---------------------------------------------------------------------------
# Grid-sliced sprite sheets (1 row)
# ---------------------------------------------------------------------------
slice_grid("Defensive_Towers_Set_asset.webp",
           ["tower_basic", "tower_fast", "tower_slow", "tower_heavy"])

slice_grid("Common_Enemies_Set_1_asset.webp",
           ["enemy_fast", "enemy_round", "enemy_armored_small", "enemy_berry"])

slice_grid("Special_Enemies_Set_2_asset.webp",
           ["enemy_flame_attacker", "enemy_heavy_armored", "enemy_ranged", "enemy_wall_breaker"])

slice_grid("Elite_Enemies_Set_asset.webp",
           ["elite_guardian", "elite_corrupted_fruit", "elite_star_energy"])

slice_grid("Magical_Fruits_Set_asset.webp",
           ["fruit_apple", "fruit_strawberry", "fruit_blueberry", "fruit_golden_star"])

slice_grid("Berry_Resources_Set_asset.webp",
           ["berry_strawberry", "berry_blueberry", "berry_raspberry", "berry_blackberry"])

slice_grid("Fruit_Trees_Set_asset.webp",
           ["tree_apple", "tree_orange", "tree_pear", "tree_flowering"])

slice_grid("Berry_Bushes_Set_asset.webp",
           ["bush_strawberry", "bush_blueberry", "bush_raspberry", "bush_blackberry"])

slice_grid("Decorative_Bells_Set_asset.webp",
           ["deco_bell_gold", "deco_bell_blue", "deco_bell_pink", "deco_bell_purple"])

slice_grid("Decorative_Plants_Set_asset.webp",
           ["plant_flower_yellow", "plant_leaf", "plant_star_flower", "plant_fern"])

slice_grid("Star_Crystals_Set_asset.webp",
           ["crystal_blue", "crystal_purple", "crystal_gold", "crystal_white"])

slice_grid("Defensive_Walls_Set_asset.webp",
           ["wall_straight", "wall_corner", "wall_gem_full", "wall_broken"])

# ---------------------------------------------------------------------------
# Grid-sliced sprite sheets (2x2)
# ---------------------------------------------------------------------------
slice_grid("Decorative_Stones_Set_asset.webp",
           ["stone_small", "stone_flat", "stone_crystal", "stone_gold_veined"],
           rows=2, cols=2)

slice_grid("Stone_Paths_Set_asset.webp",
           ["path_straight", "path_corner", "path_t", "path_cross"],
           rows=2, cols=2)

# ---------------------------------------------------------------------------
# Single sprites (gameplay objects / effects)
# ---------------------------------------------------------------------------
singles = [
    ("Bright_Burst_Crystal_asset.webp", "bright_burst_crystal"),
    ("Bright_Burst_Effect_asset.webp", "bright_burst_effect"),
    ("Bright_Keeper_asset.webp", "bright_keeper"),
    ("Enemy_Defeat_Effect_asset.webp", "enemy_defeat_effect"),
    ("Energy_Beam_asset.webp", "energy_beam"),
    ("Energy_Generator_asset.webp", "energy_generator"),
    ("Energy_Shield_asset.webp", "energy_shield"),
    ("Final_Boss_asset.webp", "final_boss"),
    ("Fortress_Entrance_Gate_asset.webp", "fortress_gate"),
    ("Golden_Coin_asset.webp", "golden_coin"),
    ("Golden_Warning_Bell_asset.webp", "golden_warning_bell"),
    ("Repair_Tower_asset.webp", "repair_tower"),
    ("Star_Core_Activation_Effect_asset.webp", "star_core_activation_effect"),
    ("Star_Core_R_asset.webp", "star_core"),
    ("Star_Shard_asset.webp", "star_shard"),
]
for fname, outname in singles:
    copy_single(fname, outname)

# ---------------------------------------------------------------------------
# Full-bleed backgrounds (no autocrop)
# ---------------------------------------------------------------------------
backgrounds = [
    ("Bright_Garden_Background_asset.webp", "bg_bright_garden"),
    ("Berry_Valley_Background_asset.webp", "bg_berry_valley"),
    ("Golden_Orchard_Background_asset.webp", "bg_golden_orchard"),
    ("Bellwood_Background_asset.webp", "bg_bellwood"),
    ("Star_Ridge_Background_asset.webp", "bg_star_ridge"),
    ("Gameplay_Terrain_asset.webp", "bg_gameplay_terrain"),
]
for fname, outname in backgrounds:
    copy_single(fname, outname, out_dir=OUT_BACKGROUNDS, crop=False)

# ---------------------------------------------------------------------------
# UI (loading screens, logo, icon)
# ---------------------------------------------------------------------------
copy_single("Game_Name.webp", "game_name", src_dir=ADDITIONAL_SRC, out_dir=OUT_UI, crop=False)
copy_single("Horizontal_Loading_Screen.webp", "loading_horizontal", src_dir=ADDITIONAL_SRC, out_dir=OUT_UI, crop=False)
copy_single("Vertical_Loading_Screen.webp", "loading_vertical", src_dir=ADDITIONAL_SRC, out_dir=OUT_UI, crop=False)

print("DONE")
