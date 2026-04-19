import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FONT_PATH = Path(r"C:\Users\LENOVO\flutter\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf")
RESTAURANT_CODEPOINT = "\ue532"

START_COLOR = (46, 125, 50)
END_COLOR = (67, 160, 71)
ICON_COLOR = (255, 255, 255)
ICON_SCALE = 0.52
ADAPTIVE_ICON_SCALE = 0.56


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def gradient_image(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), START_COLOR)
    px = img.load()

    max_index = max(1, (size - 1) * 2)
    for y in range(size):
        for x in range(size):
            t = (x + y) / max_index
            px[x, y] = (
                lerp(START_COLOR[0], END_COLOR[0], t),
                lerp(START_COLOR[1], END_COLOR[1], t),
                lerp(START_COLOR[2], END_COLOR[2], t),
            )

    return img


def draw_restaurant_icon(size: int) -> Image.Image:
    img = gradient_image(size)
    draw = ImageDraw.Draw(img)

    # Keep icon large but still inside Android adaptive icon safe zone.
    font_size = int(size * ICON_SCALE)
    font = ImageFont.truetype(str(FONT_PATH), font_size)

    bbox = draw.textbbox((0, 0), RESTAURANT_CODEPOINT, font=font)
    glyph_w = bbox[2] - bbox[0]
    glyph_h = bbox[3] - bbox[1]
    x = (size - glyph_w) / 2 - bbox[0]
    y = (size - glyph_h) / 2 - bbox[1]

    draw.text((x, y), RESTAURANT_CODEPOINT, font=font, fill=ICON_COLOR)
    return img


def draw_adaptive_background(size: int) -> Image.Image:
    return gradient_image(size)


def draw_adaptive_foreground(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Foreground stays within adaptive safe zone for all launcher masks.
    font_size = int(size * ADAPTIVE_ICON_SCALE)
    font = ImageFont.truetype(str(FONT_PATH), font_size)

    bbox = draw.textbbox((0, 0), RESTAURANT_CODEPOINT, font=font)
    glyph_w = bbox[2] - bbox[0]
    glyph_h = bbox[3] - bbox[1]
    x = (size - glyph_w) / 2 - bbox[0]
    y = (size - glyph_h) / 2 - bbox[1]

    draw.text((x, y), RESTAURANT_CODEPOINT, font=font, fill=ICON_COLOR)
    return img


def generate_android_icons() -> None:
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    for folder, size in android_sizes.items():
        folder_path = ROOT / "android" / "app" / "src" / "main" / "res" / folder
        folder_path.mkdir(parents=True, exist_ok=True)

        launcher_path = folder_path / "ic_launcher.png"
        foreground_path = folder_path / "ic_launcher_foreground.png"
        background_path = folder_path / "ic_launcher_background.png"

        draw_restaurant_icon(size).save(launcher_path, format="PNG")
        draw_adaptive_foreground(size).save(foreground_path, format="PNG")
        draw_adaptive_background(size).save(background_path, format="PNG")

        print(f"Updated {launcher_path} ({size}x{size})")
        print(f"Updated {foreground_path} ({size}x{size})")
        print(f"Updated {background_path} ({size}x{size})")


def generate_ios_icons() -> None:
    app_iconset = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    contents_path = app_iconset / "Contents.json"

    contents = json.loads(contents_path.read_text(encoding="utf-8"))

    for item in contents.get("images", []):
        filename = item.get("filename")
        size = item.get("size")
        scale = item.get("scale")
        if not filename or not size or not scale:
            continue

        base = float(size.split("x")[0])
        multiplier = int(scale.replace("x", ""))
        pixel_size = int(round(base * multiplier))

        out_path = app_iconset / filename
        draw_restaurant_icon(pixel_size).save(out_path, format="PNG")
        print(f"Updated {out_path} ({pixel_size}x{pixel_size})")


def main() -> None:
    if not FONT_PATH.exists():
        raise FileNotFoundError(f"Material icon font not found: {FONT_PATH}")

    generate_android_icons()
    generate_ios_icons()
    print("Launcher icons regenerated successfully.")


if __name__ == "__main__":
    main()
