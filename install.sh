#!/bin/bash
# Mega-Video Auto Installer

set -e

# الألوان
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Mega-Video Installer         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"

# قتل أي عمليات سابقة
echo -e "${YELLOW}🔧 Cleaning up old processes...${NC}"
pkill -f "python main.py" 2>/dev/null
fuser -k 5000/tcp 2>/dev/null

# إنشاء المجلدات
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "$HOME/.config/mega-video"
mkdir -p "$HOME/Videos/Mega-Video-Downloads"
mkdir -p "$HOME/.cache/mega-video"

# نسخ الملفات (باستثناء مجلد venv)
echo -e "${YELLOW}📋 Copying files...${NC}"
rsync -av --exclude='venv' --exclude='__pycache__' --exclude='*.log' ./ "$HOME/.config/mega-video/"

cd "$HOME/.config/mega-video"

# إنشاء البيئة الافتراضية وتثبيت المتطلبات
echo -e "${YELLOW}🐍 Setting up Python environment...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install flask yt-dlp psutil

# جعل run.sh قابلاً للتنفيذ
chmod +x run.sh

# إنشاء ملف سطح المكتب
echo -e "${YELLOW}🖥️ Creating desktop entry...${NC}"
cat > "$HOME/.local/share/applications/Mega-Video.desktop" << EOF
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

# تحديث قاعدة بيانات التطبيقات
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "📁 App: $HOME/.config/mega-video"
echo -e "📥 Downloads: $HOME/Videos/Mega-Video-Downloads"
echo -e "🚀 Find 'Mega-Video' in your applications menu"
echo -e "${BLUE}════════════════════════════════════════${NC}"
