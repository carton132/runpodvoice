#!/bin/bash
# RunPod startup script for VibeVoice
# Clones fresh code to container disk, sets up venv, points to persistent models on network volume

set -e  # Exit on error

echo "==================================="
echo "VibeVoice RunPod Startup"
echo "==================================="
echo ""

# Configuration
NETWORK_VOLUME="/workspace"
APP_DIR="/app"
REPO_URL="https://github.com/carton132/runpodvoice.git"

# Step 1: Check network volume exists
echo "[1/5] Checking network volume..."
if [ ! -d "$NETWORK_VOLUME" ]; then
    echo "ERROR: Network volume not found at $NETWORK_VOLUME"
    echo "Make sure you've attached a network volume to your pod."
    exit 1
fi
echo "✓ Network volume found: $NETWORK_VOLUME"
echo ""

# Step 2: Clone latest code from GitHub
echo "[2/5] Cloning latest code from GitHub..."
if [ -d "$APP_DIR" ]; then
    echo "Removing old app directory..."
    rm -rf "$APP_DIR"
fi
git clone "$REPO_URL" "$APP_DIR"
cd "$APP_DIR"
echo "✓ Code cloned to: $APP_DIR"
echo ""

# Step 3: Create fresh virtual environment
echo "[3/5] Creating virtual environment..."
python -m venv venv
source venv/bin/activate
echo "✓ Virtual environment created and activated"
echo ""

# Step 4: Install Python dependencies
echo "[4/5] Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
echo "✓ Dependencies installed"
echo ""

# Step 5: Configure environment for persistent model storage
echo "[5/5] Configuring model cache on network volume..."
CACHE_DIR="$NETWORK_VOLUME/models"
mkdir -p "$CACHE_DIR"
mkdir -p "$CACHE_DIR/transformers"

export HF_HOME="$CACHE_DIR"
export TRANSFORMERS_CACHE="$CACHE_DIR/transformers"

echo "✓ Environment configured"
echo "  Cache directory: $CACHE_DIR"
echo "  HF_HOME=$HF_HOME"
echo "  TRANSFORMERS_CACHE=$TRANSFORMERS_CACHE"
echo ""

echo "==================================="
echo "✓ Setup Complete!"
echo "==================================="
echo ""
echo "Working directory: $APP_DIR"
echo "Virtual environment: ACTIVATED"
echo "Model cache: $CACHE_DIR"
echo ""

# Check if models exist
if [ -d "$CACHE_DIR/hub" ] && [ "$(ls -A $CACHE_DIR/hub 2>/dev/null)" ]; then
    echo "✓ Models found in cache - will load instantly"
else
    echo "⚠ No models in cache yet"
    echo "  First run will download ~11.6 GB to network volume"
    echo "  Subsequent runs will be instant"
fi
echo ""

echo "Ready to run:"
echo "  cd $APP_DIR"
echo "  source venv/bin/activate"
echo "  python vibevoice.py"
echo ""
