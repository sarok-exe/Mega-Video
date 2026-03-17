#!/bin/bash
<<<<<<< HEAD
# Mega-Video Installer - Clean version
=======
# Mega-Video Auto Installer - Enhanced version
>>>>>>> 85256138ea2dc972a2ee43ffbdb6d84b065bf868

set -e  # Exit on any error

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

# Create necessary directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "$HOME/.config/mega-video"
mkdir -p "$HOME/Videos/Mega-Video-Downloads"
mkdir -p "$HOME/.cache/mega-video"

<<<<<<< HEAD
# Copy files
echo -e "${YELLOW}📋 Copying files to ~/.config/mega-video...${NC}"
=======
# Copy files (excluding unnecessary ones)
echo -e "${YELLOW}📋 Copying files to ~/.config/mega-video...${NC}"
# Remove old destination first to avoid conflicts
>>>>>>> 85256138ea2dc972a2ee43ffbdb6d84b065bf868
rm -rf "$HOME/.config/mega-video"
mkdir -p "$HOME/.config/mega-video"
cp -r . "$HOME/.config/mega-video/"

cd "$HOME/.config/mega-video"

# Setup Python virtual environment
echo -e "${YELLOW}🐍 Setting up Python virtual environment...${NC}"
python3 -m venv venv
source venv/bin/activate

# Upgrade pip and install dependencies
echo -e "${YELLOW}📦 Installing Python packages...${NC}"
pip install --upgrade pip
pip install flask yt-dlp psutil

# Make run.sh executable
chmod +x run.sh

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

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications/"
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "📁 App location: $HOME/.config/mega-video"
echo -e "📥 Downloads folder: $HOME/Videos/Mega-Video-Downloads"
echo -e "🚀 Find 'Mega-Video' in your applications menu"
echo -e "${BLUE}════════════════════════════════════════${NC}"
