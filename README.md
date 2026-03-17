# 🎥 Mega-Video

<div align="center">
  <img src="static/images/icon.png" width="150" alt="Mega-Video Logo">
  <h3>A powerful video downloader with web interface</h3>
  <p>Beautiful, functional, and fully integrated with your desktop</p>
</div>

---

## 📸 Screenshot

<div align="center">
  <img src="screenshots/main.png" width="800" alt="Mega-Video Main Interface">
  <p><em>Mega-Video main interface</em></p>
</div>

---

## ✨ Features

| Category | Description |
|----------|-------------|
| 🎯 **Core Features** | YouTube, Vimeo, Dailymotion + 1000+ sites |
| 🎚️ **Quality Options** | 144p to 4K, MP4/WebM formats |
| 🔄 **Auto Merge** | Best video + best audio using ffmpeg |
| 📊 **Download Manager** | Progress bars, speed, ETA, pause/resume |
| 🖥️ **Desktop Integration** | Runs from applications menu, no terminal |
| 🎨 **Beautiful UI** | Animated particle background, modern design |
| 📁 **Organized Storage** | Videos saved to `~/Videos/Mega-Video-Downloads` |

---

## ⚠️ Requirements

- **Linux** (Tested on Arch, works on Debian/Ubuntu/Fedora)
- **Python 3.8+**
- **ffmpeg** (installed automatically)

---

## 🚀 Quick Installation

```bash
git clone https://github.com/sarok-exe/mega-video.git
cd mega-video
chmod +x install.sh
./install.sh


What the installer does:
📦 Checks requirements - Python, ffmpeg, git

📁 Creates directories - ~/.config/mega-video, ~/Videos/Mega-Video-Downloads, ~/.cache/mega-video

📥 Copies files - All application files to ~/.config/mega-video

🐍 Sets up Python - Creates virtual environment and installs dependencies

🖥️ Creates desktop entry - Adds Mega-Video to your applications menu

🖥️ How To Use
Step-by-Step Guide
Launch Mega-Video from your applications menu

Paste any video URL (YouTube, Vimeo, etc.)

Click "Get Info" to see available formats

Choose your quality from the list

Click "Download" and watch the progress

Find your video in ~/Videos/Mega-Video-Downloads

Download Manager Features
Real-time progress - See percentage, speed, ETA

Pause/Resume - Control your downloads

Cancel - Stop and delete incomplete downloads

Play directly - Watch videos from the manager

Open folder - Access your downloaded files

📁 File Locations
Item	Location
Application files	~/.config/mega-video/
Downloaded videos	~/Videos/Mega-Video-Downloads/
Temporary files	~/.cache/mega-video/
Logs	~/.config/mega-video/server.log
Desktop entry	~/.local/share/applications/Mega-Video.desktop
⌨️ Keyboard Shortcuts
Key	Action
Ctrl+V	Paste URL
Enter	Get video info
Esc	Clear URL field
Tab	Navigate quality options
🔧 Manual Installation
bash
# Create directories
mkdir -p ~/.config/mega-video
mkdir -p ~/Videos/Mega-Video-Downloads
mkdir -p ~/.cache/mega-video

# Copy files
cp -r * ~/.config/mega-video/
cd ~/.config/mega-video

# Setup Python
python -m venv venv
source venv/bin/activate
pip install flask yt-dlp psutil

# Create desktop entry
cat > ~/.local/share/applications/Mega-Video.desktop << EOF
[Desktop Entry]
Name=Mega-Video
Comment=Video Downloader
Exec=$HOME/.config/mega-video/run.sh
Icon=$HOME/.config/mega-video/static/images/icon.ico
Terminal=false
Type=Application
Categories=Utility;AudioVideo;
StartupNotify=true
EOF

# Update database
update-desktop-database ~/.local/share/applications/
🧹 Uninstall
bash
# Remove application files
rm -rf ~/.config/mega-video
rm -rf ~/.cache/mega-video

# Remove videos (optional)
rm -rf ~/Videos/Mega-Video-Downloads

# Remove desktop entry
rm ~/.local/share/applications/Mega-Video.desktop
update-desktop-database ~/.local/share/applications/
🐛 Troubleshooting
Issue	Solution
Port 5000 in use	fuser -k 5000/tcp then restart
ffmpeg not found	Run installer again or sudo pacman -S ffmpeg
No videos showing	Check internet connection
Download stuck	Cancel and try again
App not in menu	Run update-desktop-database ~/.local/share/applications/
🤝 Credits
yt-dlp - Video downloading engine

Flask - Web framework

tsParticles - Animated background

📝 To-Do
Basic video downloading

Download manager

Desktop integration

Audio-only downloads

Playlist support

More themes

📜 License
MIT License - Free to use, modify, and share

<div align="center"> <p>Made with ❤️ for the Linux community</p> <p>⭐ Star this repo if you find it useful! ⭐</p> <p> <a href="https://github.com/sarok-exe/mega-video/issues">Report Issue</a> · <a href="https://github.com/sarok-exe/mega-video">GitHub Repo</a> </p> </div>

