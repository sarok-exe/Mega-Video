#!/bin/bash
cd "$(dirname "$0")"

# قتل أي عملية سابقة
pkill -f "python main.py" 2>/dev/null

# تفعيل البيئة وتشغيل السيرفر في الخلفية
source venv/bin/activate
python main.py &

# انتظر 3 ثواني ثم افتح المتصفح
sleep 3
xdg-open http://192.168.1.13:5000

# احتفظ بالعملية في الخلفية
wait
