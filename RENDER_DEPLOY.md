# Hướng dẫn Deploy Kokoro FastAPI lên Render

## 🚀 Deploy nhanh với Docker

### Bước 1: Chuẩn bị Repository
```bash
# Đảm bảo code đã được push lên GitHub
git add .
git commit -m "Add Render deployment configuration"
git push origin master
```

### Bước 2: Deploy trên Render

#### Cách 1: Sử dụng render.yaml (Khuyến nghị)
1. Vào [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** → **"Blueprint"**
3. Connect GitHub repository
4. Render sẽ tự động detect `render.yaml` và deploy

#### Cách 2: Deploy thủ công
1. Vào [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect GitHub repository
4. Cấu hình:
   - **Name**: `kokoro-fastapi`
   - **Environment**: `Docker`
   - **Dockerfile Path**: `./Dockerfile.render`
   - **Branch**: `master`
   - **Region**: `Oregon (US West)`
   - **Plan**: `Free`

### Bước 3: Environment Variables
Thêm các biến môi trường sau trong Render dashboard:

```
PYTHONPATH=/app:/app/api
USE_GPU=false
DEVICE=cpu
DOWNLOAD_MODEL=true
PHONEMIZER_ESPEAK_PATH=/usr/bin
PHONEMIZER_ESPEAK_DATA=/usr/share/espeak-ng-data
ESPEAK_DATA_PATH=/usr/share/espeak-ng-data
ONNX_NUM_THREADS=2
ONNX_INTER_OP_THREADS=1
ONNX_EXECUTION_MODE=parallel
ONNX_OPTIMIZATION_LEVEL=all
```

## ⚙️ Cấu hình chi tiết

### Service Settings
- **Language**: Docker
- **Dockerfile Path**: `./Dockerfile.render`
- **Build Command**: (để trống)
- **Start Command**: (để trống)
- **Health Check Path**: `/health`

### Performance Settings
- **ONNX_NUM_THREADS**: 2 (phù hợp với free tier)
- **ONNX_INTER_OP_THREADS**: 1
- **ONNX_EXECUTION_MODE**: parallel
- **ONNX_OPTIMIZATION_LEVEL**: all

## 🔍 Troubleshooting

### Lỗi thường gặp

#### 1. Build fails - espeak-ng not found
**Giải pháp**: Đã được fix trong `Dockerfile.render`

#### 2. Out of memory
**Giải pháp**: 
- Giảm `ONNX_NUM_THREADS` xuống 1
- Upgrade lên paid plan

#### 3. Model download fails
**Giải pháp**:
- Kiểm tra internet connection
- Tăng timeout trong Render settings

#### 4. Port binding error
**Giải pháp**: 
- Đảm bảo sử dụng `$PORT` thay vì hardcode port
- Kiểm tra `Dockerfile.render` đã đúng

### Debug Commands

#### Xem logs
```bash
# Trong Render dashboard
# Vào tab "Logs" để xem real-time logs
```

#### Test local
```bash
# Test Dockerfile locally
docker build -f Dockerfile.render -t kokoro-test .
docker run -p 10000:10000 -e PORT=10000 kokoro-test
```

## 📊 Monitoring

### Health Check
- **Endpoint**: `https://your-app.onrender.com/health`
- **Expected Response**: `{"status": "healthy"}`

### API Endpoints
- **Main API**: `https://your-app.onrender.com/v1/`
- **Web UI**: `https://your-app.onrender.com/web/`
- **API Docs**: `https://your-app.onrender.com/docs`

## 💰 Cost Optimization

### Free Tier Limits
- **Memory**: 512MB RAM
- **CPU**: Shared
- **Bandwidth**: 100GB/month
- **Sleep**: 15 minutes idle → sleep

### Upgrade Options
- **Starter Plan**: $7/month
  - 512MB RAM
  - Always on
  - Custom domains

- **Standard Plan**: $25/month
  - 2GB RAM
  - Always on
  - Custom domains
  - Better performance

## 🔄 Auto Deploy

### GitHub Integration
- Render tự động deploy khi push code lên branch `master`
- Có thể cấu hình deploy từ branch khác

### Manual Deploy
- Vào Render dashboard
- Click **"Manual Deploy"**
- Chọn branch/commit

## 🛡️ Security

### Environment Variables
- Không commit sensitive data vào code
- Sử dụng Render's environment variables

### CORS
- Cấu hình `CORS_ORIGINS` phù hợp
- Không dùng `["*"]` trong production

## 📈 Scaling

### Horizontal Scaling
- Render không hỗ trợ horizontal scaling trên free tier
- Cần upgrade lên paid plan

### Vertical Scaling
- Tăng memory/CPU trong Render dashboard
- Monitor usage để tối ưu

## 🆘 Support

### Render Support
- [Render Documentation](https://render.com/docs)
- [Render Community](https://community.render.com)

### Project Issues
- Tạo issue trên GitHub repository
- Check logs trong Render dashboard
