# 🚀 Hướng dẫn Deploy Kokoro-FastAPI lên Render

## ✅ Đã tối ưu hóa cho Render

### Files đã được tạo/cập nhật:
- ✅ `render.yaml` - Cấu hình Render service
- ✅ `requirements.txt` - Dependencies tối ưu cho Render
- ✅ `runtime.txt` - Python version
- ✅ `build.sh` - Build script
- ✅ `api/src/core/config.py` - Cấu hình Render paths
- ✅ `api/src/main.py` - Tối ưu cho Render deployment

## 🎯 Các bước Deploy

### Bước 1: Chuẩn bị Repository
```bash
# Đảm bảo tất cả files đã được commit
git add .
git commit -m "Optimize for Render deployment"
git push origin main
```

### Bước 2: Deploy lên Render

1. **Truy cập Render**: https://render.com
2. **Đăng ký/Login** tài khoản
3. **Connect GitHub** repository
4. **Tạo New Web Service**:
   - **Repository**: Chọn repo Kokoro-FastAPI
   - **Branch**: main
   - **Runtime**: Python 3
   - **Build Command**: `chmod +x build.sh && ./build.sh`
   - **Start Command**: `python -m uvicorn api.src.main:app --host 0.0.0.0 --port $PORT`

### Bước 3: Cấu hình Environment Variables

Trong Render Dashboard, thêm các environment variables:

```
USE_GPU=false
DEVICE=cpu
DOWNLOAD_MODEL=true
PHONEMIZER_ESPEAK_PATH=/usr/bin
PHONEMIZER_ESPEAK_DATA=/usr/share/espeak-ng-data
ESPEAK_DATA_PATH=/usr/share/espeak-ng-data
PYTHONPATH=/opt/render/project/src:/opt/render/project
HOST=0.0.0.0
PORT=10000
MODEL_DIR=/opt/render/project/api/src/models/v1_0
VOICES_DIR=/opt/render/project/api/src/voices/v1_0
TEMP_FILE_DIR=/tmp/kokoro_temp
```

### Bước 4: Deploy và chờ

- **Build time**: 10-15 phút (download model)
- **Memory usage**: ~2GB
- **Free tier**: 750 giờ/tháng

## 🔧 Troubleshooting

### Lỗi Build
```bash
# Kiểm tra logs trong Render dashboard
# Thường gặp:
# 1. Memory không đủ -> Upgrade plan
# 2. Dependencies conflict -> Check requirements.txt
# 3. Model download timeout -> Tăng timeout
```

### Lỗi Runtime
```bash
# Kiểm tra environment variables
# Kiểm tra port configuration
# Kiểm tra model path
```

### Lỗi 502 Bad Gateway
```bash
# Kiểm tra start command
# Kiểm tra port binding
# Kiểm tra health check endpoint
```

## 🎯 Test sau khi Deploy

### Health Check
```bash
curl https://your-app-name.onrender.com/health
```

### API Test
```python
import requests

# Test TTS
response = requests.post(
    "https://your-app-name.onrender.com/v1/audio/speech",
    json={
        "model": "kokoro",
        "input": "Hello from Render!",
        "voice": "af_bella",
        "response_format": "mp3"
    }
)

with open("test.mp3", "wb") as f:
    f.write(response.content)
```

### Web UI
- **URL**: `https://your-app-name.onrender.com/web`
- **Features**: Text input, voice selection, audio generation

## 📊 Monitoring

- **Render Dashboard**: Monitor CPU, Memory, Requests
- **Logs**: Real-time logs trong Render dashboard
- **Health Check**: `/health` endpoint

## 🚀 Performance Tips

1. **Cold Start**: Lần đầu có thể mất 30-60 giây
2. **Memory**: Cần ít nhất 2GB RAM
3. **Timeout**: Render free có timeout 15 phút
4. **Scaling**: Auto-scale dựa trên traffic

## 💰 Cost

- **Free Tier**: 750 giờ/tháng
- **Paid Plans**: Từ $7/tháng
- **Custom Domain**: Có sẵn

## 🎉 Kết quả

Sau khi deploy thành công, bạn sẽ có:
- ✅ HTTPS API endpoint
- ✅ Web UI đẹp mắt
- ✅ OpenAI-compatible API
- ✅ Multiple voice support
- ✅ Streaming audio
- ✅ Custom domain (tùy chọn)
