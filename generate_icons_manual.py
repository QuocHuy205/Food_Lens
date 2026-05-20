from PIL import Image
import os

source_path = r'd:\CaloriesAI\food_lens\assets\images\logo.png'
icon = Image.open(source_path).convert('RGBA')
width, height = icon.size
print(f"Source size: {width}x{height}")

# Keep the full logo image and fit it into the launcher canvas without cutting.
cropped = icon
print(f"Cropped size: {cropped.size}")

canvas_size = 1024
canvas = Image.new('RGBA', (canvas_size, canvas_size), (255, 255, 255, 255))

# Make the logo larger so it fills the launcher icon better without clipping.
target_size = int(canvas_size * 0.90)
aspect = cropped.width / cropped.height
if aspect >= 1:
    resized_width = target_size
    resized_height = int(target_size / aspect)
else:
    resized_height = target_size
    resized_width = int(target_size * aspect)

resized = cropped.resize((resized_width, resized_height), Image.Resampling.LANCZOS)
offset_x = (canvas_size - resized_width) // 2
offset_y = (canvas_size - resized_height) // 2
canvas.alpha_composite(resized, (offset_x, offset_y))

app_icon_path = r'd:\CaloriesAI\food_lens\assets\images\app_icon.png'
canvas.save(app_icon_path)
print(f"✅ App icon saved: {app_icon_path}")

# Define mipmap folders and their densities.
mipmaps = {
    r'd:\CaloriesAI\food_lens\android\app\src\main\res\mipmap-mdpi': 48,
    r'd:\CaloriesAI\food_lens\android\app\src\main\res\mipmap-hdpi': 72,
    r'd:\CaloriesAI\food_lens\android\app\src\main\res\mipmap-xhdpi': 96,
    r'd:\CaloriesAI\food_lens\android\app\src\main\res\mipmap-xxhdpi': 144,
    r'd:\CaloriesAI\food_lens\android\app\src\main\res\mipmap-xxxhdpi': 192,
}

for folder, size in mipmaps.items():
    if not os.path.exists(folder):
        print(f"❌ Folder not found: {folder}")
        continue

    resized_icon = canvas.resize((size, size), Image.Resampling.LANCZOS)
    output_path = os.path.join(folder, 'ic_launcher.png')
    resized_icon.save(output_path)
    print(f"✅ Saved {size}x{size} to {os.path.basename(folder)}")

print("\n✅ All icons generated successfully!")
