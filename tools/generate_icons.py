#!/usr/bin/env python3
"""
Production Icon Generator for Zingify App
Generates all required app icons and splash screens for Play Store publishing
"""

import os
import sys
from PIL import Image, ImageDraw, ImageFont
import math

def create_zingify_logo(size):
    """Create a professional Zingify logo"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Zingify colors
    primary_color = (99, 102, 241, 255)  # Indigo
    secondary_color = (236, 72, 153, 255)  # Pink
    accent_color = (16, 185, 129, 255)    # Emerald
    
    # Create gradient background
    for y in range(size):
        for x in range(size):
            # Calculate gradient
            r1 = int(primary_color[0] + (secondary_color[0] - primary_color[0]) * x / size)
            g1 = int(primary_color[1] + (secondary_color[1] - primary_color[1]) * x / size)
            b1 = int(primary_color[2] + (secondary_color[2] - primary_color[2]) * x / size)
            
            r2 = int(r1 + (accent_color[0] - r1) * y / size)
            g2 = int(g1 + (accent_color[1] - g1) * y / size)
            b2 = int(b1 + (accent_color[2] - b1) * y / size)
            
            draw.point((x, y), fill=(r2, g2, b2, 255))
    
    # Draw "Z" letter
    margin = size // 8
    font_size = size // 2
    
    try:
        # Try to use a nice font
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Draw Z with shadow effect
    shadow_offset = size // 50
    text = "Z"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center the text
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    # Draw shadow
    draw.text((x + shadow_offset, y + shadow_offset), text, 
              fill=(0, 0, 0, 100), font=font)
    
    # Draw main text
    draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    
    # Add chat bubbles decoration
    bubble_size = size // 8
    bubble_positions = [
        (margin, margin),
        (size - margin - bubble_size, margin),
        (margin, size - margin - bubble_size),
        (size - margin - bubble_size, size - margin - bubble_size)
    ]
    
    for bx, by in bubble_positions:
        draw.ellipse([bx, by, bx + bubble_size, by + bubble_size], 
                    fill=(255, 255, 255, 80))
    
    return img

def create_app_icon(size):
    """Create adaptive app icon"""
    # Create base icon
    icon = create_zingify_logo(size)
    
    # Add rounded corners for adaptive icon
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    
    # Draw rounded rectangle
    corner_radius = size // 5
    draw.rounded_rectangle([0, 0, size, size], radius=corner_radius, fill=255)
    
    # Apply mask
    icon.putalpha(mask)
    
    return icon

def create_splash_screen(width, height):
    """Create splash screen"""
    img = Image.new('RGBA', (width, height), (248, 250, 252, 255))  # Light background
    draw = ImageDraw.Draw(img)
    
    # Add gradient overlay
    for y in range(height):
        alpha = int(50 * (1 - y / height))
        draw.line([(0, y), (width, y)], fill=(99, 102, 241, alpha))
    
    # Add logo in center
    logo_size = min(width, height) // 3
    logo = create_zingify_logo(logo_size)
    
    # Center the logo
    x = (width - logo_size) // 2
    y = (height - logo_size) // 2
    img.paste(logo, (x, y), logo)
    
    # Add app name
    try:
        font = ImageFont.truetype("arial.ttf", width // 20)
    except:
        font = ImageFont.load_default()
    
    text = "Zingify"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    text_x = (width - text_width) // 2
    text_y = y + logo_size + width // 20
    
    draw.text((text_x, text_y), text, fill=(99, 102, 241, 255), font=font)
    
    return img

def generate_all_icons():
    """Generate all required icons and assets"""
    
    # Create directories
    base_dir = "assets/images"
    android_dir = "android/app/src/main/res"
    
    os.makedirs(base_dir, exist_ok=True)
    os.makedirs(android_dir, exist_ok=True)
    
    # Generate main app icons
    icon_sizes = {
        "zingify_logo.png": 1024,
        "zingify_icon.png": 512,
        "app_icon.png": 1024,
        "zingify_splash.png": 1920
    }
    
    for filename, size in icon_sizes.items():
        if filename == "zingify_splash.png":
            icon = create_splash_screen(size, int(size * 0.5625))  # 16:9 ratio
        else:
            icon = create_app_icon(size)
        
        filepath = os.path.join(base_dir, filename)
        icon.save(filepath, "PNG")
        print(f"Generated: {filepath}")
    
    # Generate Android mipmap icons
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192
    }
    
    for folder, size in android_sizes.items():
        folder_path = os.path.join(android_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # Generate foreground icon
        fg_icon = create_app_icon(size)
        fg_path = os.path.join(folder_path, "ic_launcher_foreground.png")
        fg_icon.save(fg_path, "PNG")
        
        # Generate background icon
        bg_icon = Image.new('RGBA', (size, size), (255, 255, 255, 255))
        bg_path = os.path.join(folder_path, "ic_launcher_background.png")
        bg_icon.save(bg_path, "PNG")
        
        print(f"Generated Android icons for {folder}")
    
    # Generate adaptive icon
    adaptive_dir = os.path.join(android_dir, "drawable")
    os.makedirs(adaptive_dir, exist_ok=True)
    
    adaptive_icon = create_app_icon(108)
    adaptive_path = os.path.join(adaptive_dir, "ic_launcher.png")
    adaptive_icon.save(adaptive_path, "PNG")
    print(f"Generated adaptive icon: {adaptive_path}")
    
    print("\n✅ All icons and assets generated successfully!")
    print("📱 Your app is now ready for Play Store publishing!")

if __name__ == "__main__":
    try:
        generate_all_icons()
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
