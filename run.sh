#!/bin/bash
cd "$(dirname "$0")"

# قتل أي عملية سابقة على نفس المنفذ أو نفس المشروع
echo "🔧 Cleaning up previous instances..."
pkill -f "python main.py" 2>/dev/null
fuser -k 5000/tcp 2>/dev/null

# تفعيل البيئة الافتراضية (إنشاء إذا لم تكن موجودة)
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi
source venv/bin/activate

# التأكد من تثبيت المتطلبات
pip install --quiet --upgrade pip
pip install --quiet flask yt-dlp psutil

# تشغيل السيرفر في الخلفية
echo "🚀 Starting server..."
python main.py > server.log 2>&1 &

# انتظر حتى يبدأ السيرفر
sleep 3
echo "🌐 Opening browser..."
xdg-open http://127.0.0.1:5000
