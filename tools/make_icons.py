"""Generate the web app icons in web/icons/ and web/favicon.png.

Run from the project root:  python tools/make_icons.py
Requires Pillow. Uses the bundled Noto Sans Devanagari Bold (OFL) font.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
FONT = ROOT / "assets/fonts/NotoSansDevanagari-Bold.ttf"
OUT = ROOT / "web"
FOREST = (23, 107, 89)
GOLD = (255, 200, 87)
PAPER = (247, 248, 242)


def draw_mark(img: Image.Image, safe: float) -> None:
    """Draw the Devanagari "a" mark centred inside a square of side size*safe."""
    size = img.width
    d = ImageDraw.Draw(img)
    box = size * safe
    font = ImageFont.truetype(str(FONT), int(box * 0.62))
    text = "अ"  # Devanagari letter A
    l, t, r, b = d.textbbox((0, 0), text, font=font)
    tw, th = r - l, b - t
    bar_h = box * 0.06
    gap = box * 0.07
    total = th + gap + bar_h
    x = (size - tw) / 2 - l
    y = (size - total) / 2 - t
    d.text((x, y), text, font=font, fill=PAPER)
    bar_w = tw * 0.62
    bx = (size - bar_w) / 2
    by = (size - total) / 2 + th + gap
    d.rounded_rectangle((bx, by, bx + bar_w, by + bar_h), radius=bar_h / 2, fill=GOLD)


def rounded(size: int) -> Image.Image:
    """Standard icon: rounded forest tile on transparent background."""
    scale = 4
    big = Image.new("RGBA", (size * scale, size * scale), (0, 0, 0, 0))
    ImageDraw.Draw(big).rounded_rectangle(
        (0, 0, size * scale - 1, size * scale - 1), radius=size * scale * 0.22, fill=FOREST
    )
    draw_mark(big, 0.9)
    return big.resize((size, size), Image.LANCZOS)


def full_bleed(size: int, safe: float) -> Image.Image:
    """Maskable / Apple icon: square forest background, mark inside safe zone."""
    scale = 4
    big = Image.new("RGB", (size * scale, size * scale), FOREST)
    draw_mark(big, safe)
    return big.resize((size, size), Image.LANCZOS)


def main() -> None:
    icons = OUT / "icons"
    icons.mkdir(parents=True, exist_ok=True)
    rounded(192).save(icons / "Icon-192.png")
    rounded(512).save(icons / "Icon-512.png")
    full_bleed(192, 0.7).save(icons / "Icon-maskable-192.png")
    full_bleed(512, 0.7).save(icons / "Icon-maskable-512.png")
    full_bleed(180, 0.85).save(icons / "apple-touch-icon.png")
    rounded(32).save(OUT / "favicon.png")
    print("Icons written to", icons)


if __name__ == "__main__":
    main()
