#!/bin/bash
# Mega-Video Installer

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Mega-Video Installer         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ git not found. Please install git first.${NC}"
    exit 1
fi

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 not found. Please install Python 3.8+${NC}"
    exit 1
fi

# Install ffmpeg if needed
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${YELLOW}📦 Installing ffmpeg...${NC}"
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm ffmpeg
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y ffmpeg
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y ffmpeg
    else
        echo -e "${RED}Please install ffmpeg manually${NC}"
        exit 1
    fi
fi

# Create directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "$HOME/.config/mega-video"
mkdir -p "$HOME/Videos/Mega-Video-Downloads"
mkdir -p "$HOME/.cache/mega-video"

# Copy files
echo -e "${YELLOW}📋 Copying files...${NC}"
cp -r * "$HOME/.config/mega-video/"
cd "$HOME/.config/mega-video"

# Setup Python virtual environment
echo -e "${YELLOW}🐍 Setting up Python environment...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install flask yt-dlp psutil

# Make run.sh executable
chmod +x run.sh

# Create desktop entry
echo -e "${YELLOW}🖥️ Creating desktop entry...${NC}"
cat > "$HOME/.local/share/applications/Mega-Video.desktop" << EOF
[Desktop Entry]
Name=Mega-Video
Comment=Video Downloader - YouTube & more
Exec=$HOME/.config/mega-video/run.sh
Icon=$HOME/.config/mega-video/static/images/icon.ico
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
echo -e "📁 App: $HOME/.config/mega-video"
echo -e "📥 Downloads: $HOME/Videos/Mega-Video-Downloads"
echo -e "\n🚀 Find Mega-Video in your applications menu"
echo -e "${BLUE}════════════════════════════════════════${NC}"