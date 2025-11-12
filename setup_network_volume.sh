#!/bin/bash
# Setup script for VibeVoice with RunPod network volume

echo "==================================="
echo "VibeVoice Network Volume Setup"
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

# Create cache directory on network volume
CACHE_DIR="$NETWORK_VOLUME/huggingface_cache"
mkdir -p "$CACHE_DIR"
echo "Created cache directory: $CACHE_DIR"

# Set environment variables
export HF_HOME="$CACHE_DIR"
export TRANSFORMERS_CACHE="$CACHE_DIR/transformers"

echo ""
echo "Environment variables set:"
echo "  HF_HOME=$HF_HOME"
echo "  TRANSFORMERS_CACHE=$TRANSFORMERS_CACHE"
echo ""

# Add to bashrc for persistence
if ! grep -q "HF_HOME=$CACHE_DIR" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# VibeVoice cache on network volume" >> ~/.bashrc
    echo "export HF_HOME=\"$CACHE_DIR\"" >> ~/.bashrc
    echo "export TRANSFORMERS_CACHE=\"$CACHE_DIR/transformers\"" >> ~/.bashrc
    echo "Added environment variables to ~/.bashrc"
else
    echo "Environment variables already in ~/.bashrc"
fi

echo ""
echo "==================================="
echo "Setup complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Run: source ~/.bashrc"
echo "2. Run: pip install -r requirements.txt"
echo "3. Run: python vibevoice.py"
echo ""
echo "Your models will be cached to: $CACHE_DIR"
echo "This directory will persist across pod restarts."
