#!/bin/bash
set -e

echo "🚀 Starting Kokoro TTS build for Render..."

# Install system dependencies
echo "📦 Installing system dependencies..."
apt-get update -y
apt-get install -y espeak-ng espeak-ng-data libsndfile1 ffmpeg g++ curl

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p /opt/render/project/api/src/models/v1_0
mkdir -p /opt/render/project/api/src/voices/v1_0
mkdir -p /tmp/kokoro_temp

# Set up espeak-ng data
echo "🔧 Setting up espeak-ng..."
mkdir -p /usr/share/espeak-ng-data
ln -sf /usr/lib/*/espeak-ng-data/* /usr/share/espeak-ng-data/ || true

# Install Python dependencies
echo "🐍 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Download spaCy model
echo "📚 Downloading spaCy model..."
python -m spacy download en_core_web_sm

# Set permissions
echo "🔐 Setting permissions..."
chmod -R 755 /opt/render/project/api/src/models/v1_0
chmod -R 755 /opt/render/project/api/src/voices/v1_0
chmod -R 755 /tmp/kokoro_temp

echo "✅ Build completed successfully!"
echo "🎯 Ready to start Kokoro TTS on Render!"
