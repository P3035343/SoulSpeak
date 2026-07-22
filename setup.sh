#!/bin/bash
# ============================================
# SoulSpeak Setup Script
# Run this ONCE after cloning the repo.
# It copies your assets from ~/SoulSpeakAssets into the project.
# ============================================

ASSETS_DIR="$HOME/SoulSpeakAssets"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🎙️  SoulSpeak Asset Setup"
echo "========================"
echo ""

# Check if assets folder exists
if [ ! -d "$ASSETS_DIR" ]; then
    echo "❌ ~/SoulSpeakAssets folder not found!"
    echo ""
    echo "Please create it and put your files there:"
    echo "  mkdir -p ~/SoulSpeakAssets"
    echo ""
    echo "Then add your files:"
    echo "  - mr_hope_intro.mp4"
    echo "  - dr_hope_intro.mp4"
    echo "  - dr_hope_response.mp4"
    echo "  - mr_hope_vent_room.mp4"
    echo "  - centered_room_intro.mp4"
    echo "  - dr_hope_listening.png (or .jpg)"
    echo "  - dr_hope.png"
    echo "  - mr_hope.png"
    echo "  - GeminiConfig.plist"
    echo "  - Any sound files (.mp3)"
    echo ""
    echo "Then run this script again: bash setup.sh"
    exit 1
fi

echo "✅ Found ~/SoulSpeakAssets"
echo ""

# Copy GeminiConfig.plist
if [ -f "$ASSETS_DIR/GeminiConfig.plist" ]; then
    cp "$ASSETS_DIR/GeminiConfig.plist" "$PROJECT_DIR/SoulSpeak/"
    echo "✅ GeminiConfig.plist → SoulSpeak/"
else
    echo "⚠️  GeminiConfig.plist not found (AI features won't work without it)"
fi

# Copy video files to project root (Xcode will find them in bundle)
for video in mr_hope_intro.mp4 dr_hope_intro.mp4 dr_hope_response.mp4 mr_hope_vent_room.mp4 centered_room_intro.mp4; do
    if [ -f "$ASSETS_DIR/$video" ]; then
        cp "$ASSETS_DIR/$video" "$PROJECT_DIR/SoulSpeak/Resources/"
        echo "✅ $video → SoulSpeak/Resources/"
    fi
done

# Copy any other mp4/mov files
for video in "$ASSETS_DIR"/*.mp4 "$ASSETS_DIR"/*.mov; do
    if [ -f "$video" ]; then
        filename=$(basename "$video")
        if [ ! -f "$PROJECT_DIR/SoulSpeak/Resources/$filename" ]; then
            cp "$video" "$PROJECT_DIR/SoulSpeak/Resources/"
            echo "✅ $filename → SoulSpeak/Resources/"
        fi
    fi
done

# Copy sound files
for sound in "$ASSETS_DIR"/*.mp3; do
    if [ -f "$sound" ]; then
        filename=$(basename "$sound")
        cp "$sound" "$PROJECT_DIR/SoulSpeak/Resources/"
        echo "✅ $filename → SoulSpeak/Resources/"
    fi
done

# Copy images to Assets.xcassets
XCASSETS="$PROJECT_DIR/SoulSpeak/Assets.xcassets"

# dr_hope avatar
for ext in png jpg jpeg; do
    if [ -f "$ASSETS_DIR/dr_hope.$ext" ]; then
        cp "$ASSETS_DIR/dr_hope.$ext" "$XCASSETS/dr_hope.imageset/"
        echo "✅ dr_hope.$ext → Assets.xcassets/dr_hope.imageset/"
    fi
done

# mr_hope avatar
for ext in png jpg jpeg; do
    if [ -f "$ASSETS_DIR/mr_hope.$ext" ]; then
        cp "$ASSETS_DIR/mr_hope.$ext" "$XCASSETS/mr_hope.imageset/"
        echo "✅ mr_hope.$ext → Assets.xcassets/mr_hope.imageset/"
    fi
done

# dr_hope_listening
for ext in png jpg jpeg; do
    if [ -f "$ASSETS_DIR/dr_hope_listening.$ext" ]; then
        cp "$ASSETS_DIR/dr_hope_listening.$ext" "$XCASSETS/dr_hope_listening.imageset/"
        echo "✅ dr_hope_listening.$ext → Assets.xcassets/dr_hope_listening.imageset/"
    fi
done

# dr_hope_office_render
for ext in png jpg jpeg; do
    if [ -f "$ASSETS_DIR/dr_hope_office_render.$ext" ]; then
        cp "$ASSETS_DIR/dr_hope_office_render.$ext" "$XCASSETS/dr_hope_office_render.imageset/"
        echo "✅ dr_hope_office_render.$ext → Assets.xcassets/dr_hope_office_render.imageset/"
    fi
    if [ -f "$ASSETS_DIR/Dr_Hope_Office_Render.$ext" ]; then
        cp "$ASSETS_DIR/Dr_Hope_Office_Render.$ext" "$XCASSETS/dr_hope_office_render.imageset/"
        echo "✅ Dr_Hope_Office_Render.$ext → Assets.xcassets/dr_hope_office_render.imageset/"
    fi
done

# mr_hope_office_render
for ext in png jpg jpeg; do
    if [ -f "$ASSETS_DIR/mr_hope_office_render.$ext" ]; then
        cp "$ASSETS_DIR/mr_hope_office_render.$ext" "$XCASSETS/mr_hope_office_render.imageset/"
        echo "✅ mr_hope_office_render.$ext → Assets.xcassets/mr_hope_office_render.imageset/"
    fi
    if [ -f "$ASSETS_DIR/Mr_Hope_Office_Render.$ext" ]; then
        cp "$ASSETS_DIR/Mr_Hope_Office_Render.$ext" "$XCASSETS/mr_hope_office_render.imageset/"
        echo "✅ Mr_Hope_Office_Render.$ext → Assets.xcassets/mr_hope_office_render.imageset/"
    fi
done

# AppIcon
if [ -f "$ASSETS_DIR/AppIcon.png" ]; then
    cp "$ASSETS_DIR/AppIcon.png" "$XCASSETS/AppIcon.appiconset/"
    echo "✅ AppIcon.png → Assets.xcassets/AppIcon.appiconset/"
fi

# Copy any .usdz 3D models
for model in "$ASSETS_DIR"/*.usdz; do
    if [ -f "$model" ]; then
        filename=$(basename "$model")
        cp "$model" "$PROJECT_DIR/SoulSpeak/Resources/"
        echo "✅ $filename → SoulSpeak/Resources/"
    fi
done

echo ""
echo "========================"
echo "🎉 Setup complete!"
echo ""
echo "Now open Xcode:"
echo "  open SoulSpeak.xcodeproj"
echo ""
echo "Then:"
echo "  1. In Xcode: File → Add Files → select SoulSpeak/Resources/ → Add all"
echo "  2. Make sure 'Add to target: SoulSpeak' is checked"
echo "  3. Cmd+R to build and run"
echo ""
echo "Next time you re-clone, just run: bash setup.sh"
