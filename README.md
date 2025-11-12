# VibeVoice on RunPod

Local setup for running VibeVoice-Large-Q8 text-to-speech model on RunPod.

## System Requirements

**GPU Requirements:**
- Minimum: 12 GB VRAM
- Recommended: 16+ GB VRAM (RTX 3090/4090, A5000+)
- Must be NVIDIA GPU with CUDA support

**Storage:**
- At least 11 GB for model files

## RunPod Setup Instructions

### 1. Create a Network Volume (Recommended)

**Why use a network volume?**
- Model files (~11.6 GB) persist across pod sessions
- Only download once, reuse forever
- Much faster pod startup times
- Significantly reduces costs

**Setup:**
1. Go to [RunPod.io](https://www.runpod.io/)
2. Navigate to **Storage** > **Network Volumes**
3. Click **+ New Network Volume**
4. Choose a datacenter and size (20 GB minimum recommended)
5. Name it (e.g., "vibevoice-models")

### 2. Deploy a Pod

1. Select a GPU instance:
   - **RTX 4090** (24 GB VRAM) - Recommended
   - **RTX 3090** (24 GB VRAM) - Good
   - **A5000** (24 GB VRAM) - Good
2. Choose a PyTorch template or Ubuntu with CUDA
3. **Important:** Attach your network volume under "Select Network Volume"
4. Deploy the pod

### 3. One-Command Setup

SSH into your pod and run:

```bash
# Clone and setup in one go
git clone https://github.com/carton132/runpodvoice.git
cd runpodvoice
chmod +x startup.sh
./startup.sh
```

**That's it!** The script automatically:
- ✓ Clones latest code from GitHub to /app
- ✓ Creates fresh virtual environment
- ✓ Installs all Python dependencies
- ✓ Configures model cache on network volume
- ✓ Uses persistent storage at /workspace for models

### 4. Run Your App

After the startup script completes, you're ready to go:

```bash
cd /app
source venv/bin/activate
python vibevoice.py
```

#### Advanced Usage

Generate speech (using network volume cache):
```bash
python vibevoice.py
```

Or explicitly specify cache directory:
```bash
python vibevoice.py --cache-dir /workspace/models
```

Generate speech from custom text:
```bash
python vibevoice.py --text "Your custom text here"
```

Specify output file:
```bash
python vibevoice.py --text "Hello world" --output my_audio.wav
```

#### Batch Processing

Use the included sample or create your own text file:
```bash
python vibevoice.py --batch sample_inputs.txt
```

Create a text file with multiple lines (e.g., `inputs.txt`):
```
Hello, this is the first sentence.
This is the second sentence.
And this is the third.
```

Process all lines:
```bash
python vibevoice.py --batch inputs.txt
```

### 5. Download Output Files

Audio files are saved in the `/app/outputs/` directory. Download them using:
- RunPod web interface
- SCP: `scp user@pod-ip:/app/outputs/*.wav ./local_folder/`

## Model Details

- **Model:** FabioSarracino/VibeVoice-Large-Q8
- **Size:** 11.6 GB (8-bit quantized)
- **Sample Rate:** 24,000 Hz
- **Format:** WAV output

## Network Volume vs Container Disk

### With Network Volume (Recommended)
**First run:**
1. Downloads ~11.6 GB to network volume
2. Caches persist forever

**Subsequent pod launches:**
1. Instant - models already cached
2. No re-downloading needed
3. Significant cost savings

### Without Network Volume
**Every pod launch:**
1. Re-downloads ~11.6 GB
2. 10-15 minute wait each time
3. Higher bandwidth costs
4. Container disk erased on termination

## First Run

**With network volume at /workspace (required):**
- First ever run: Downloads ~11.6 GB to /workspace/models (one time)
- All future pod restarts: Instant load from cache
- Code and venv rebuilt fresh each time from GitHub

**Without network volume:**
- Models re-download every pod restart (not recommended)

## GPU Memory Usage

Expected VRAM usage:
- Model: ~11.6 GB
- Inference overhead: ~2-3 GB
- **Total: ~14 GB VRAM**

## Troubleshooting

**CUDA out of memory:**
- Use a GPU with more VRAM (24 GB recommended)
- Close other GPU processes

**Model download fails:**
- Check internet connection
- Ensure sufficient disk space (15+ GB free)

**Slow generation:**
- This is normal for first run (downloading model)
- Subsequent runs should be much faster

## Cost Optimization

Tips for minimizing RunPod costs:
1. **Use a network volume** - Avoid re-downloading models every session
2. **Use spot instances** - Cheaper but can be interrupted (network volume persists!)
3. **Stop pod when not in use** - Only pay for active time
4. **Process multiple texts in one session** - Batch your work
5. **Share network volumes** - One volume can serve multiple projects

**Cost breakdown example:**
- Network volume (20 GB): ~$2/month
- RTX 4090 pod: ~$0.69/hour
- With network volume: Save 10-15 min per session = save ~$0.17 per launch

## Additional Resources

- [Model on Hugging Face](https://huggingface.co/FabioSarracino/VibeVoice-Large-Q8)
- [RunPod Documentation](https://docs.runpod.io/)
