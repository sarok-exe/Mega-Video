#!/bin/bash
set -e  # Exit on any error
set -x  # Print commands as they execute

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Mega-Video Installer         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"

# Clean up old processes
echo -e "${YELLOW}🔧 Cleaning up old processes...${NC}"
pkill -f "python main.py" 2>/dev/null || true
fuser -k 5000/tcp 2>/dev/null || true

echo "Step 1: Cleaning completed."

# Create necessary directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "$HOME/.config/mega-video"
mkdir -p "$HOME/Videos/Mega-Video-Downloads"
mkdir -p "$HOME/.cache/mega-video"
echo "Step 2: Directories created."

# Copy files
echo -e "${YELLOW}📋 Copying files to ~/.config/mega-video...${NC}"
# Remove old destination first to avoid conflicts
rm -rf "$HOME/.config/mega-video"
mkdir -p "$HOME/.config/mega-video"
cp -r . "$HOME/.config/mega-video/"
echo "Step 3: Files copied."

cd "$HOME/.config/mega-video"
echo "Step 4: Changed directory to $HOME/.config/mega-video"

# Setup Python virtual environment
echo -e "${YELLOW}🐍 Setting up Python virtual environment...${NC}"
python3 -m venv venv
source venv/bin/activate
echo "Step 5: Virtual environment created and activated."

# Upgrade pip and install dependencies
echo -e "${YELLOW}📦 Installing Python packages...${NC}"
pip install --upgrade pip
pip install flask yt-dlp psutil
echo "Step 6: Packages installed."

# Make run.sh executable
chmod +x run.sh
echo "Step 7: run.sh made executable."

# Create desktop entry
echo -e "${YELLOW}🖥️ Creating desktop entry...${NC}"
DESKTOP_FILE="$HOME/.local/share/applications/Mega-Video.desktop"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Mega-Video
Comment=Download videos from YouTube and other sites
Exec=$HOME/.config/mega-video/run.sh
Icon=$HOME/.config/mega-video/static/images/icon.png
Terminal=false
Type=Application
Categories=Utility;AudioVideo;Network;
StartupNotify=true
EOF
echo "Step 8: Desktop entry created."

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications/"
    echo "Step 9: Desktop database updated."
else
    echo "Step 9: update-desktop-database not found, skipping."
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "📁 App location: $HOME/.config/mega-video"
echo -e "📥 Downloads folder: $HOME/Videos/Mega-Video-Downloads"
echo -e "🚀 Find 'Mega-Video' in your applications menu"
echo -e "${BLUE}════════════════════════════════════════${NC}"
