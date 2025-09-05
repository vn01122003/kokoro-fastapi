# Hướng dẫn Deploy Kokoro FastAPI

## Tổng quan
Hệ thống Kokoro FastAPI cung cấp API Text-to-Speech tương thích OpenAI với giao diện web và khả năng streaming.

## Yêu cầu hệ thống

### Tối thiểu
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 10GB (cho model và dependencies)
- **OS**: Linux/Windows/macOS với Docker

### Khuyến nghị
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: 20GB+ SSD
- **GPU**: NVIDIA GPU (tùy chọn, cho hiệu suất tốt hơn)

## Cài đặt nhanh

### 1. Clone repository
```bash
git clone <repository-url>
cd Kokoro-FastAPI
```

### 2. Deploy với script tự động
```bash
# Cấp quyền thực thi
chmod +x deploy.sh

# Khởi động hệ thống
./deploy.sh start

# Kiểm tra trạng thái
./deploy.sh status
```

### 3. Deploy thủ công với Docker Compose
```bash
# Khởi động tất cả services
docker-compose -f docker-compose.production.yml up -d

# Xem logs
docker-compose -f docker-compose.production.yml logs -f

# Dừng services
docker-compose -f docker-compose.production.yml down
```

## Cấu hình

### Environment Variables
Sao chép file `env.production` và chỉnh sửa theo nhu cầu:

```bash
cp env.production .env
nano .env
```

### Các cài đặt quan trọng:

#### Performance
```bash
# Số thread ONNX (nên = số CPU cores)
ONNX_NUM_THREADS=4

# Sử dụng GPU (nếu có)
USE_GPU=true
DEVICE=gpu
```

#### Security
```bash
# CORS origins (chỉ định domain cụ thể)
CORS_ORIGINS=["https://yourdomain.com"]

# API Key (tùy chọn)
API_KEY=your-secret-api-key
```

#### Rate Limiting
```bash
# Giới hạn request per minute
RATE_LIMIT_PER_MINUTE=60
TTS_RATE_LIMIT_PER_MINUTE=10
```

## Triển khai trên Cloud

### AWS EC2
1. **Tạo EC2 instance** (t3.medium trở lên)
2. **Cài đặt Docker**:
   ```bash
   sudo yum update -y
   sudo yum install -y docker
   sudo systemctl start docker
   sudo usermod -a -G docker ec2-user
   ```
3. **Deploy**:
   ```bash
   git clone <repo>
   cd Kokoro-FastAPI
   ./deploy.sh start
   ```

### Google Cloud Platform
1. **Tạo Compute Engine instance**
2. **Cài đặt Docker**:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```
3. **Deploy** như trên

### DigitalOcean Droplet
1. **Tạo Droplet** (2GB RAM trở lên)
2. **Cài đặt Docker**:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```
3. **Deploy** như trên

### Azure Container Instances
```bash
# Build và push image
docker build -f Dockerfile.production -t your-registry/kokoro-fastapi .
docker push your-registry/kokoro-fastapi

# Deploy với Azure CLI
az container create \
  --resource-group myResourceGroup \
  --name kokoro-tts \
  --image your-registry/kokoro-fastapi \
  --ports 8880 \
  --memory 4 \
  --cpu 2
```

## SSL/HTTPS

### Với Let's Encrypt
```bash
# Cài đặt certbot
sudo apt install certbot

# Tạo certificate
sudo certbot certonly --standalone -d yourdomain.com

# Cập nhật nginx.conf với SSL paths
# /etc/letsencrypt/live/yourdomain.com/fullchain.pem
# /etc/letsencrypt/live/yourdomain.com/privkey.pem
```

### Với Cloudflare
1. Thêm domain vào Cloudflare
2. Bật "Full (strict)" SSL mode
3. Cấu hình DNS A record trỏ đến server IP

## Monitoring và Logs

### Xem logs
```bash
# Tất cả services
./deploy.sh logs

# Service cụ thể
docker-compose -f docker-compose.production.yml logs kokoro-tts

# Logs real-time
docker-compose -f docker-compose.production.yml logs -f --tail=100
```

### Health Check
```bash
# Kiểm tra API
curl http://localhost:8880/health

# Kiểm tra qua nginx
curl http://localhost/health
```

### Monitoring với Prometheus (tùy chọn)
Thêm vào `docker-compose.production.yml`:
```yaml
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

## Backup và Recovery

### Backup
```bash
# Tự động backup trước khi update
./deploy.sh update

# Backup thủ công
./deploy.sh backup
```

### Recovery
```bash
# Restore từ backup
tar -xzf backups/kokoro_backup_YYYYMMDD_HHMMSS.tar.gz
docker-compose -f docker-compose.production.yml up -d
```

## Troubleshooting

### Lỗi thường gặp

#### 1. Out of Memory
```bash
# Tăng memory limit trong docker-compose.production.yml
deploy:
  resources:
    limits:
      memory: 8G
```

#### 2. Model download fails
```bash
# Download model thủ công
docker run --rm -v $(pwd)/api/src/models:/models \
  your-registry/kokoro-fastapi \
  python scripts/download_model.py --output /models/v1_0
```

#### 3. Port conflicts
```bash
# Thay đổi port trong docker-compose.production.yml
ports:
  - "8881:8880"  # External:Internal
```

#### 4. Permission issues
```bash
# Fix permissions
sudo chown -R 1000:1000 api/
sudo chmod -R 755 api/
```

### Debug mode
```bash
# Chạy với debug logs
docker-compose -f docker-compose.production.yml up --build
```

## Scaling

### Horizontal Scaling
```yaml
# Trong docker-compose.production.yml
services:
  kokoro-tts:
    deploy:
      replicas: 3
```

### Load Balancer
Sử dụng nginx upstream với multiple instances:
```nginx
upstream kokoro_backend {
    server kokoro-tts-1:8880;
    server kokoro-tts-2:8880;
    server kokoro-tts-3:8880;
}
```

## Security Best Practices

1. **Firewall**: Chỉ mở ports cần thiết (80, 443, 22)
2. **API Keys**: Sử dụng authentication cho production
3. **Rate Limiting**: Cấu hình phù hợp với tài nguyên
4. **Updates**: Thường xuyên cập nhật base images
5. **Monitoring**: Theo dõi logs và metrics

## Support

- **Documentation**: Xem README.md
- **Issues**: Tạo issue trên GitHub
- **API Docs**: http://your-domain/docs sau khi deploy
