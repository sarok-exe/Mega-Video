import os
import uuid
import subprocess
import threading
import time
import signal
from flask import Flask, render_template, request, jsonify, send_file
import yt_dlp

app = Flask(__name__, template_folder='.')

CONFIG_DIR = os.path.expanduser('~/.config/mega-video')
DOWNLOAD_FOLDER = os.path.expanduser('~/Videos/Mega-Video-Downloads')
CACHE_FOLDER = os.path.expanduser('~/.cache/mega-video')

os.makedirs(DOWNLOAD_FOLDER, exist_ok=True)
os.makedirs(CACHE_FOLDER, exist_ok=True)

downloads = {}

def progress_hook(downloads, task_id):
    def hook(d):
        if task_id not in downloads:
            return
        info = downloads[task_id]
        if d['status'] == 'downloading':
            downloaded = d.get('downloaded_bytes', 0)
            total = d.get('total_bytes') or d.get('total_bytes_estimate', 0)
            percent = (downloaded / total * 100) if total > 0 else 0
            speed = d.get('speed', 0)
            eta = d.get('eta', 0)
            info['progress'] = {
                'percent': round(percent, 1),
                'downloaded': downloaded,
                'total': total,
                'speed': speed,
                'eta': eta
            }
        elif d['status'] == 'finished':
            info['progress']['percent'] = 100
    return hook

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/get-info', methods=['POST'])
def get_info():
    url = request.json.get('url')
    ydl_opts = {'quiet': True, 'no_warnings': True}
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            merged, video_only, audio = [], [], []
            for f in info['formats']:
                if not f.get('height'):
                    continue
                quality = f"{f['height']}p"
                filesize = f.get('filesize', 0)
                ext = f.get('ext', 'unknown')
                has_video = f.get('vcodec') != 'none'
                has_audio = f.get('acodec') != 'none'
                format_data = {
                    'format_id': f['format_id'],
                    'ext': ext,
                    'quality': quality,
                    'filesize': filesize,
                    'has_audio': has_audio,
                    'has_video': has_video
                }
                if has_video and has_audio:
                    merged.append(format_data)
                elif has_video and not has_audio:
                    video_only.append(format_data)
                elif not has_video and has_audio and f.get('abr'):
                    audio.append({**format_data, 'quality': f"{f.get('abr', 0)}kbps"})
            merged.sort(key=lambda x: int(x['quality'][:-1]))
            video_only.sort(key=lambda x: int(x['quality'][:-1]))
            audio.sort(key=lambda x: int(x['quality'].replace('kbps', '')), reverse=True)
            return jsonify({
                'success': True,
                'title': info['title'],
                'thumbnail': info.get('thumbnail', ''),
                'merged_formats': merged,
                'video_only_formats': video_only,
                'audio_formats': audio
            })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/download', methods=['POST'])
def download():
    url = request.json.get('url')
    format_id = request.json.get('format_id')
    task_id = str(uuid.uuid4())

    downloads[task_id] = {
        'task_id': task_id,
        'url': url,
        'format_id': format_id,
        'status': 'starting',
        'progress': {'percent': 0, 'speed': 0, 'eta': 0},
        'filename': None,
        'process': None,
        'paused': False,
        'cancel': False,
        'phase': 'starting',
        'current_phase': 0,
        'total_phases': 1,
        'title': None,
        'error': None
    }

    thread = threading.Thread(target=process_download, args=(task_id,))
    thread.start()
    return jsonify({'success': True, 'task_id': task_id})

def process_download(task_id):
    info = downloads[task_id]
    url = info['url']
    format_id = info['format_id']

    try:
        with yt_dlp.YoutubeDL({'quiet': True}) as ydl:
            full_info = ydl.extract_info(url, download=False)
            selected = next((f for f in full_info['formats'] if f['format_id'] == format_id), None)
            if not selected:
                info['status'] = 'error'
                info['error'] = 'Format not found'
                return

            info['title'] = full_info.get('title', 'Unknown')

            need_merge = selected.get('acodec') == 'none' and selected.get('vcodec') != 'none'
            best_audio = None
            if need_merge:
                audio_formats = [f for f in full_info['formats'] if f.get('acodec') != 'none' and f.get('vcodec') == 'none']
                if audio_formats:
                    best_audio = max(audio_formats, key=lambda x: x.get('abr', 0))

        total_phases = 3 if need_merge else 1
        info['total_phases'] = total_phases
        info['current_phase'] = 0
        info['phase'] = 'starting'

        if need_merge and best_audio:
            info['phase'] = 'downloading_video'
            info['current_phase'] = 1
            info['status'] = 'downloading'

            video_filename = f"{uuid.uuid4()}_video.%(ext)s"
            video_path_template = os.path.join(CACHE_FOLDER, video_filename)
            ydl_video = yt_dlp.YoutubeDL({
                'format': selected['format_id'],
                'outtmpl': video_path_template,
                'quiet': True,
                'progress_hooks': [progress_hook(downloads, task_id)]
            })
            ydl_video.download([url])
            
            video_files = [f for f in os.listdir(CACHE_FOLDER) if f.endswith(selected.get('ext', 'mp4')) and f.startswith(video_filename.split('.')[0])]
            if not video_files:
                raise Exception("Video file not found after download")
            video_path = os.path.join(CACHE_FOLDER, video_files[0])

            info['phase'] = 'downloading_audio'
            info['current_phase'] = 2
            info['progress'] = {'percent': 0, 'speed': 0, 'eta': 0}

            audio_filename = f"{uuid.uuid4()}_audio.%(ext)s"
            audio_path_template = os.path.join(CACHE_FOLDER, audio_filename)
            ydl_audio = yt_dlp.YoutubeDL({
                'format': best_audio['format_id'],
                'outtmpl': audio_path_template,
                'quiet': True,
                'progress_hooks': [progress_hook(downloads, task_id)]
            })
            ydl_audio.download([url])
            
            audio_files = [f for f in os.listdir(CACHE_FOLDER) if f.endswith(best_audio.get('ext', 'm4a')) and f.startswith(audio_filename.split('.')[0])]
            if not audio_files:
                raise Exception("Audio file not found after download")
            audio_path = os.path.join(CACHE_FOLDER, audio_files[0])

            info['phase'] = 'merging'
            info['current_phase'] = 3
            info['progress'] = {'percent': 0, 'speed': 0, 'eta': 0}
            output_filename = f"{uuid.uuid4()}.mp4"
            output_path = os.path.join(DOWNLOAD_FOLDER, output_filename)

            cmd = ['ffmpeg', '-i', video_path, '-i', audio_path, '-c:v', 'copy', '-c:a', 'aac', '-map', '0:v:0', '-map', '1:a:0', '-shortest', output_path, '-y']
            info['progress']['percent'] = 50
            time.sleep(1)
            subprocess.run(cmd, capture_output=True)
            info['progress']['percent'] = 100

            os.remove(video_path)
            os.remove(audio_path)

            info['filename'] = output_filename
            info['phase'] = 'completed'
            info['status'] = 'completed'
            info['progress']['percent'] = 100

        else:
            info['phase'] = 'downloading_video'
            info['current_phase'] = 1
            info['total_phases'] = 1
            info['status'] = 'downloading'

            filename = f"{uuid.uuid4()}.{selected.get('ext', 'mp4')}"
            filepath = os.path.join(DOWNLOAD_FOLDER, filename)
            ydl = yt_dlp.YoutubeDL({
                'format': format_id,
                'outtmpl': filepath,
                'quiet': True,
                'progress_hooks': [progress_hook(downloads, task_id)]
            })
            ydl.download([url])

            info['filename'] = filename
            info['phase'] = 'completed'
            info['status'] = 'completed'
            info['progress']['percent'] = 100

    except Exception as e:
        info['status'] = 'error'
        info['error'] = str(e)
        info['phase'] = 'error'

@app.route('/download-status/<task_id>')
def download_status_route(task_id):
    if task_id not in downloads:
        return jsonify({'status': 'not_found'})
    return jsonify(downloads[task_id])

@app.route('/downloads/<filename>')
def download_file(filename):
    return send_file(os.path.join(DOWNLOAD_FOLDER, filename), as_attachment=True)

@app.route('/play/<filename>')
def play_file(filename):
    return send_file(os.path.join(DOWNLOAD_FOLDER, filename))

@app.route('/control', methods=['POST'])
def control_download():
    task_id = request.json.get('task_id')
    action = request.json.get('action')
    if task_id not in downloads:
        return jsonify({'success': False, 'error': 'Task not found'})

    info = downloads[task_id]
    if action == 'pause':
        info['paused'] = True
        info['status'] = 'paused'
    elif action == 'resume':
        info['paused'] = False
        info['status'] = info.get('phase', 'downloading')
    elif action == 'cancel':
        info['status'] = 'cancelled'
        info['phase'] = 'cancelled'
        if info.get('filename') and os.path.exists(os.path.join(DOWNLOAD_FOLDER, info['filename'])):
            os.remove(os.path.join(DOWNLOAD_FOLDER, info['filename']))
    return jsonify({'success': True})

@app.route('/downloads-list')
def downloads_list():
    active = {}
    completed = {}
    for tid, info in downloads.items():
        if info['status'] in ('downloading', 'starting', 'paused'):
            active[tid] = info
        else:
            completed[tid] = info
    return jsonify({'active': active, 'completed': completed})

@app.route('/delete/<task_id>', methods=['DELETE'])
def delete_download(task_id):
    if task_id not in downloads:
        return jsonify({'success': False})
    info = downloads[task_id]
    if info.get('filename'):
        try:
            os.remove(os.path.join(DOWNLOAD_FOLDER, info['filename']))
        except:
            pass
    del downloads[task_id]
    return jsonify({'success': True})

# مسار إيقاف الخادم
@app.route('/shutdown', methods=['POST'])
def shutdown():
    # إيقاف الخادم بطريقة آمنة
    func = request.environ.get('werkzeug.server.shutdown')
    if func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    func()
    return 'Server shutting down...'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
