#!/bin/bash
# ============================================
# SoulSpeak Setup Script
# Run this ONCE after cloning the repo.
# It copies your assets from ~/SoulSpeakAssets into the project.
#
# IMPORTANT: After running this script, just open Xcode and build.
# Images will auto-load because Contents.json already references them.
# You only need to "Add Files" for the Resources/ folder (mp3/mp4).
# ============================================

ASSETS_DIR="$HOME/SoulSpeakAssets"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
XCASSETS="$PROJECT_DIR/SoulSpeak/Assets.xcassets"
RESOURCES="$PROJECT_DIR/SoulSpeak/Resources"

echo ""
echo "🎙️  SoulSpeak Asset Setup"
echo "========================"
echo ""

# Create Resources dir if missing
mkdir -p "$RESOURCES"

# Check if assets folder exists
if [ ! -d "$ASSETS_DIR" ]; then
    echo "❌ ~/SoulSpeakAssets folder not found!"
    echo ""
    echo "Please create it and add your files:"
    echo "  mkdir -p ~/SoulSpeakAssets"
    echo ""
    echo "Required images (copy into ~/SoulSpeakAssets/):"
    echo "  - dr_hope.jpg"
    echo "  - mr_hope.png"
    echo "  - dr_hope_listening.jpg"
    echo "  - dr_hope_office_render.png"
    echo "  - mr_hope_office_render.png"
    echo "  - main_lobby.png"
    echo "  - AppIcon.png"
    echo ""
    echo "Required config:"
    echo "  - GeminiConfig.plist (with API_KEY and ELEVENLABS_API_KEY)"
    echo ""
    echo "Optional media (mp4/mp3):"
    echo "  - office_entry.mp4"
    echo "  - mr_hope_greeting.mp4"
    echo "  - mr_hope_walkthrough.mp4"
    echo "  - dr_hope_intro.mp4"
    echo "  - journal_door_entry.mp4"
    echo "  - mr_hope_vent_room.mp4"
    echo "  - centered_room_intro.mp4"
    echo "  - dr_hope_response.mp4"
    echo "  - (any .mp3 meditation/soundscape files)"
    echo ""
    echo "Then run this script again: bash setup.sh"
    exit 1
fi

echo "✅ Found ~/SoulSpeakAssets"
echo ""

# ============================================
# 1. IMAGES → Assets.xcassets (auto-loaded by Xcode)
# ============================================
echo "📸 Copying images to Assets.xcassets..."
echo ""

# dr_hope.jpg (or convert from png)
if [ -f "$ASSETS_DIR/dr_hope.jpg" ]; then
    cp "$ASSETS_DIR/dr_hope.jpg" "$XCASSETS/dr_hope.imageset/dr_hope.jpg"
    echo "  ✅ dr_hope.jpg"
elif [ -f "$ASSETS_DIR/dr_hope.png" ]; then
    cp "$ASSETS_DIR/dr_hope.png" "$XCASSETS/dr_hope.imageset/dr_hope.jpg"
    echo "  ✅ dr_hope.png → dr_hope.jpg"
elif [ -f "$ASSETS_DIR/Dr_Hope.jpg" ]; then
    cp "$ASSETS_DIR/Dr_Hope.jpg" "$XCASSETS/dr_hope.imageset/dr_hope.jpg"
    echo "  ✅ Dr_Hope.jpg → dr_hope.jpg"
elif [ -f "$ASSETS_DIR/Dr_Hope.png" ]; then
    cp "$ASSETS_DIR/Dr_Hope.png" "$XCASSETS/dr_hope.imageset/dr_hope.jpg"
    echo "  ✅ Dr_Hope.png → dr_hope.jpg"
else
    echo "  ⚠️  dr_hope image not found"
fi

# mr_hope.png (or convert from jpg)
if [ -f "$ASSETS_DIR/mr_hope.png" ]; then
    cp "$ASSETS_DIR/mr_hope.png" "$XCASSETS/mr_hope.imageset/mr_hope.png"
    echo "  ✅ mr_hope.png"
elif [ -f "$ASSETS_DIR/mr_hope.jpg" ]; then
    cp "$ASSETS_DIR/mr_hope.jpg" "$XCASSETS/mr_hope.imageset/mr_hope.png"
    echo "  ✅ mr_hope.jpg → mr_hope.png"
elif [ -f "$ASSETS_DIR/Mr_Hope.png" ]; then
    cp "$ASSETS_DIR/Mr_Hope.png" "$XCASSETS/mr_hope.imageset/mr_hope.png"
    echo "  ✅ Mr_Hope.png → mr_hope.png"
elif [ -f "$ASSETS_DIR/Mr_Hope.jpg" ]; then
    cp "$ASSETS_DIR/Mr_Hope.jpg" "$XCASSETS/mr_hope.imageset/mr_hope.png"
    echo "  ✅ Mr_Hope.jpg → mr_hope.png"
else
    echo "  ⚠️  mr_hope image not found"
fi

# dr_hope_listening.jpg
if [ -f "$ASSETS_DIR/dr_hope_listening.jpg" ]; then
    cp "$ASSETS_DIR/dr_hope_listening.jpg" "$XCASSETS/dr_hope_listening.imageset/dr_hope_listening.jpg"
    echo "  ✅ dr_hope_listening.jpg"
elif [ -f "$ASSETS_DIR/dr_hope_listening.png" ]; then
    cp "$ASSETS_DIR/dr_hope_listening.png" "$XCASSETS/dr_hope_listening.imageset/dr_hope_listening.jpg"
    echo "  ✅ dr_hope_listening.png → dr_hope_listening.jpg"
elif [ -f "$ASSETS_DIR/Dr_Hope_Listening.jpg" ]; then
    cp "$ASSETS_DIR/Dr_Hope_Listening.jpg" "$XCASSETS/dr_hope_listening.imageset/dr_hope_listening.jpg"
    echo "  ✅ Dr_Hope_Listening.jpg → dr_hope_listening.jpg"
else
    echo "  ⚠️  dr_hope_listening image not found"
fi

# dr_hope_office_render.png
if [ -f "$ASSETS_DIR/dr_hope_office_render.png" ]; then
    cp "$ASSETS_DIR/dr_hope_office_render.png" "$XCASSETS/dr_hope_office_render.imageset/dr_hope_office_render.png"
    echo "  ✅ dr_hope_office_render.png"
elif [ -f "$ASSETS_DIR/dr_hope_office_render.jpg" ]; then
    cp "$ASSETS_DIR/dr_hope_office_render.jpg" "$XCASSETS/dr_hope_office_render.imageset/dr_hope_office_render.png"
    echo "  ✅ dr_hope_office_render.jpg → dr_hope_office_render.png"
elif [ -f "$ASSETS_DIR/Dr_Hope_Office_Render.png" ]; then
    cp "$ASSETS_DIR/Dr_Hope_Office_Render.png" "$XCASSETS/dr_hope_office_render.imageset/dr_hope_office_render.png"
    echo "  ✅ Dr_Hope_Office_Render.png"
elif [ -f "$ASSETS_DIR/Dr_Hope_Office_Render.jpg" ]; then
    cp "$ASSETS_DIR/Dr_Hope_Office_Render.jpg" "$XCASSETS/dr_hope_office_render.imageset/dr_hope_office_render.png"
    echo "  ✅ Dr_Hope_Office_Render.jpg"
else
    echo "  ⚠️  dr_hope_office_render image not found"
fi

# mr_hope_office_render.png
if [ -f "$ASSETS_DIR/mr_hope_office_render.png" ]; then
    cp "$ASSETS_DIR/mr_hope_office_render.png" "$XCASSETS/mr_hope_office_render.imageset/mr_hope_office_render.png"
    echo "  ✅ mr_hope_office_render.png"
elif [ -f "$ASSETS_DIR/mr_hope_office_render.jpg" ]; then
    cp "$ASSETS_DIR/mr_hope_office_render.jpg" "$XCASSETS/mr_hope_office_render.imageset/mr_hope_office_render.png"
    echo "  ✅ mr_hope_office_render.jpg → mr_hope_office_render.png"
elif [ -f "$ASSETS_DIR/Mr_Hope_Office_Render.png" ]; then
    cp "$ASSETS_DIR/Mr_Hope_Office_Render.png" "$XCASSETS/mr_hope_office_render.imageset/mr_hope_office_render.png"
    echo "  ✅ Mr_Hope_Office_Render.png"
elif [ -f "$ASSETS_DIR/Mr_Hope_Office_Render.jpg" ]; then
    cp "$ASSETS_DIR/Mr_Hope_Office_Render.jpg" "$XCASSETS/mr_hope_office_render.imageset/mr_hope_office_render.png"
    echo "  ✅ Mr_Hope_Office_Render.jpg"
else
    echo "  ⚠️  mr_hope_office_render image not found"
fi

# main_lobby.png
if [ -f "$ASSETS_DIR/main_lobby.png" ]; then
    cp "$ASSETS_DIR/main_lobby.png" "$XCASSETS/main_lobby.imageset/main_lobby.png"
    echo "  ✅ main_lobby.png"
elif [ -f "$ASSETS_DIR/main_lobby.jpg" ]; then
    cp "$ASSETS_DIR/main_lobby.jpg" "$XCASSETS/main_lobby.imageset/main_lobby.png"
    echo "  ✅ main_lobby.jpg → main_lobby.png"
elif [ -f "$ASSETS_DIR/Main_Lobby.png" ]; then
    cp "$ASSETS_DIR/Main_Lobby.png" "$XCASSETS/main_lobby.imageset/main_lobby.png"
    echo "  ✅ Main_Lobby.png"
elif [ -f "$ASSETS_DIR/Main_Lobby.jpg" ]; then
    cp "$ASSETS_DIR/Main_Lobby.jpg" "$XCASSETS/main_lobby.imageset/main_lobby.png"
    echo "  ✅ Main_Lobby.jpg"
else
    echo "  ⚠️  main_lobby image not found"
fi

# AppIcon.png
if [ -f "$ASSETS_DIR/AppIcon.png" ]; then
    cp "$ASSETS_DIR/AppIcon.png" "$XCASSETS/AppIcon.appiconset/AppIcon.png"
    echo "  ✅ AppIcon.png"
elif [ -f "$ASSETS_DIR/appicon.png" ]; then
    cp "$ASSETS_DIR/appicon.png" "$XCASSETS/AppIcon.appiconset/AppIcon.png"
    echo "  ✅ appicon.png → AppIcon.png"
else
    echo "  ⚠️  AppIcon.png not found"
fi

echo ""

# ============================================
# 2. GeminiConfig.plist (API keys - gitignored)
# ============================================
echo "🔑 Copying API config..."
echo ""

if [ -f "$ASSETS_DIR/GeminiConfig.plist" ]; then
    cp "$ASSETS_DIR/GeminiConfig.plist" "$PROJECT_DIR/SoulSpeak/GeminiConfig.plist"
    echo "  ✅ GeminiConfig.plist"
else
    # Create a template if it doesn't exist
    if [ ! -f "$PROJECT_DIR/SoulSpeak/GeminiConfig.plist" ]; then
        cat > "$PROJECT_DIR/SoulSpeak/GeminiConfig.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_KEY</key>
    <string>YOUR_GEMINI_API_KEY_HERE</string>
    <key>ELEVENLABS_API_KEY</key>
    <string>YOUR_ELEVENLABS_API_KEY_HERE</string>
</dict>
</plist>
EOF
        echo "  ⚠️  Created TEMPLATE GeminiConfig.plist — you MUST edit it!"
        echo "     Open SoulSpeak/GeminiConfig.plist and add your keys:"
        echo "     - API_KEY: Get from https://aistudio.google.com/app/apikey"
        echo "     - ELEVENLABS_API_KEY: Get from https://elevenlabs.io/app/settings/api-keys"
    else
        echo "  ℹ️  GeminiConfig.plist already exists (not overwriting)"
    fi
fi

echo ""

# ============================================
# 3. VIDEO & AUDIO FILES → Resources/
# ============================================
echo "🎬 Copying videos and audio to Resources/..."
echo ""

# Copy ALL mp4 files
for video in "$ASSETS_DIR"/*.mp4; do
    if [ -f "$video" ]; then
        filename=$(basename "$video")
        cp "$video" "$RESOURCES/$filename"
        echo "  ✅ $filename"
    fi
done

# Copy ALL mp3 files
for audio in "$ASSETS_DIR"/*.mp3; do
    if [ -f "$audio" ]; then
        filename=$(basename "$audio")
        cp "$audio" "$RESOURCES/$filename"
        echo "  ✅ $filename"
    fi
done

# Copy any .usdz 3D models
for model in "$ASSETS_DIR"/*.usdz; do
    if [ -f "$model" ]; then
        filename=$(basename "$model")
        cp "$model" "$RESOURCES/$filename"
        echo "  ✅ $filename"
    fi
done

echo ""

# ============================================
# 4. VERIFY
# ============================================
echo "========================"
echo "📋 Asset Check:"
echo ""

# Check images
MISSING_IMAGES=0
for img in "dr_hope.imageset/dr_hope.jpg" "mr_hope.imageset/mr_hope.png" "dr_hope_listening.imageset/dr_hope_listening.jpg" "dr_hope_office_render.imageset/dr_hope_office_render.png" "mr_hope_office_render.imageset/mr_hope_office_render.png" "main_lobby.imageset/main_lobby.png" "AppIcon.appiconset/AppIcon.png"; do
    if [ -f "$XCASSETS/$img" ]; then
        echo "  ✅ $img"
    else
        echo "  ❌ MISSING: $img"
        MISSING_IMAGES=$((MISSING_IMAGES + 1))
    fi
done

echo ""

# Count resources
VIDEO_COUNT=$(find "$RESOURCES" -name "*.mp4" 2>/dev/null | wc -l | tr -d ' ')
AUDIO_COUNT=$(find "$RESOURCES" -name "*.mp3" 2>/dev/null | wc -l | tr -d ' ')
echo "  🎬 Videos: $VIDEO_COUNT mp4 files"
echo "  🎵 Audio: $AUDIO_COUNT mp3 files"

# Check GeminiConfig
if [ -f "$PROJECT_DIR/SoulSpeak/GeminiConfig.plist" ]; then
    if grep -q "YOUR_GEMINI_API_KEY_HERE\|YOUR_ELEVENLABS_API_KEY_HERE" "$PROJECT_DIR/SoulSpeak/GeminiConfig.plist"; then
        echo "  ⚠️  GeminiConfig.plist has PLACEHOLDER keys — edit it!"
    else
        echo "  ✅ GeminiConfig.plist (has real keys)"
    fi
else
    echo "  ❌ GeminiConfig.plist MISSING"
fi

echo ""
echo "========================"

if [ $MISSING_IMAGES -eq 0 ]; then
    echo "🎉 All images are in place!"
    echo ""
    echo "Now open Xcode:"
    echo "  open SoulSpeak.xcodeproj"
    echo ""
    echo "Then:"
    echo "  1. File → Add Files → select SoulSpeak/Resources/ folder"
    echo "  2. Check ✅ 'Add to target: SoulSpeak'"
    echo "  3. Cmd+R to build and run"
    echo ""
    echo "💡 Images will auto-load (no need to add them manually!)"
else
    echo "⚠️  $MISSING_IMAGES image(s) missing. Add them to ~/SoulSpeakAssets/ and run again."
fi

echo ""
echo "Next time you re-clone, just run: bash setup.sh"
echo ""
