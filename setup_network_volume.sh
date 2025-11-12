#!/bin/bash
# Complete setup script for VibeVoice on RunPod with network volume

set -e  # Exit on error

echo "==================================="
echo "VibeVoice Complete Setup"
echo "==================================="
echo ""

# Default network volume path on RunPod
NETWORK_VOLUME="/workspace"

# Check if network volume is mounted
if [ ! -d "$NETWORK_VOLUME" ]; then
    echo "WARNING: Network volume not found at $NETWORK_VOLUME"
    echo "Make sure you've attached a network volume to your pod."
    echo ""
    echo "Common RunPod network volume paths:"
    echo "  - /workspace (standard)"
    echo "  - /runpod-volume (alternative)"
    echo ""
    read -p "Enter custom network volume path (or press Enter to skip): " CUSTOM_PATH
    if [ -n "$CUSTOM_PATH" ]; then
        NETWORK_VOLUME="$CUSTOM_PATH"
    else
        echo "Skipping network volume setup."
        exit 1
    fi
fi

echo "Using network volume: $NETWORK_VOLUME"
echo ""

# Step 1: Create cache directory on network volume
echo "[1/5] Setting up cache directory..."
CACHE_DIR="$NETWORK_VOLUME/huggingface_cache"
mkdir -p "$CACHE_DIR"
echo "✓ Cache directory created: $CACHE_DIR"
echo ""

# Step 2: Create virtual environment on network volume
echo "[2/5] Creating virtual environment on network volume..."
VENV_DIR="$NETWORK_VOLUME/venv"
if [ ! -d "$VENV_DIR" ]; then
    python -m venv "$VENV_DIR"
    echo "✓ Virtual environment created: $VENV_DIR"
else
    echo "✓ Virtual environment already exists: $VENV_DIR"
fi
echo ""

# Step 3: Set environment variables
echo "[3/5] Configuring environment variables..."
export HF_HOME="$CACHE_DIR"
export TRANSFORMERS_CACHE="$CACHE_DIR/transformers"
echo "✓ Environment variables set"
echo "  HF_HOME=$HF_HOME"
echo "  TRANSFORMERS_CACHE=$TRANSFORMERS_CACHE"
echo ""

# Step 4: Add to bashrc for persistence
echo "[4/5] Persisting configuration to ~/.bashrc..."
if ! grep -q "VibeVoice environment" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'

# VibeVoice environment
export HF_HOME="/workspace/huggingface_cache"
export TRANSFORMERS_CACHE="/workspace/huggingface_cache/transformers"
source /workspace/venv/bin/activate
EOF
    echo "✓ Configuration added to ~/.bashrc"
else
    echo "✓ Configuration already in ~/.bashrc"
fi
echo ""

# Step 5: Activate venv and install dependencies
echo "[5/5] Installing dependencies..."
source "$VENV_DIR/bin/activate"

if [ -f "requirements.txt" ]; then
    echo "Installing from requirements.txt..."
    pip install --upgrade pip
    pip install -r requirements.txt
    echo "✓ All dependencies installed"
else
    echo "⚠ requirements.txt not found in current directory"
    echo "Make sure you're running this from the project directory"
fi
echo ""

echo "==================================="
echo "✓ Setup Complete!"
echo "==================================="
echo ""
echo "Configuration:"
echo "  • Virtual environment: $VENV_DIR"
echo "  • Model cache: $CACHE_DIR"
echo "  • Python: $(which python)"
echo ""
echo "Next steps:"
echo "  1. Close and reopen your terminal, OR run:"
echo "     source ~/.bashrc"
echo ""
echo "  2. Generate your first audio:"
echo "     python vibevoice.py"
echo ""
echo "  3. Custom text generation:"
echo "     python vibevoice.py --text \"Your custom text\""
echo ""
echo "Everything persists on the network volume!"
echo "Future pod sessions will start instantly."
echo ""
