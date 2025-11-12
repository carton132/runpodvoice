#!/bin/bash
# Lightweight update script - only updates if there are changes
# Use this when you want to check for repo updates without rebuilding everything

set -e

echo "==================================="
echo "VibeVoice Update Check"
echo "==================================="
echo ""

APP_DIR="/app"

# Check if app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo "ERROR: App directory not found at $APP_DIR"
    echo "Run startup.sh first to set up the app."
    exit 1
fi

cd "$APP_DIR"

# Check if it's a git repo
if [ ! -d .git ]; then
    echo "ERROR: Not a git repository"
    echo "Run startup.sh to set up properly."
    exit 1
fi

echo "[1/3] Checking for updates..."
git fetch origin main

# Check if there are any changes
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✓ Already up to date - no changes found"
    echo ""
    echo "Ready to run:"
    echo "  cd /app"
    echo "  source venv/bin/activate"
    echo "  python vibevoice.py"
    exit 0
fi

echo "⚠ Updates found - pulling changes..."
git pull origin main
echo "✓ Code updated"
echo ""

# Check if requirements.txt changed
echo "[2/3] Checking if dependencies changed..."
CHANGED_FILES=$(git diff --name-only HEAD@{1} HEAD)

if echo "$CHANGED_FILES" | grep -q "requirements.txt"; then
    echo "⚠ requirements.txt changed - updating dependencies..."
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    echo "✓ Dependencies updated"
else
    echo "✓ No dependency changes"
fi
echo ""

echo "[3/3] Verifying environment..."
if [ -d "venv" ]; then
    echo "✓ Virtual environment: OK"
else
    echo "⚠ Virtual environment missing - creating..."
    python -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    echo "✓ Virtual environment created"
fi
echo ""

echo "==================================="
echo "✓ Update Complete!"
echo "==================================="
echo ""
echo "Changes pulled and applied"
echo ""
echo "Ready to run:"
echo "  cd /app"
echo "  source venv/bin/activate"
echo "  python vibevoice.py"
echo ""
