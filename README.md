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
```
---
##  🧹 Uninstall 

# Remove application files
```
rm -rf ~/.config/mega-video
rm -rf ~/.cache/mega-video
```

# Remove videos (optional)
```
rm -rf ~/Videos/Mega-Video-Downloads
```

# Remove desktop entry
```
rm ~/.local/share/applications/Mega-Video.desktop
update-desktop-database ~/.local/share/applications/
```
