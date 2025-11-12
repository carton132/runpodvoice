"""
VibeVoice Text-to-Speech Generator
Generates audio from text using the VibeVoice-Large-Q8 model
"""

from transformers import AutoModelForCausalLM, AutoProcessor
import torch
import scipy.io.wavfile as wavfile
import argparse
import os
from datetime import datetime


def setup_cache_directory(cache_dir=None):
    """Set up the cache directory for model storage"""
    if cache_dir:
        # User specified cache directory
        os.environ['HF_HOME'] = cache_dir
        os.environ['TRANSFORMERS_CACHE'] = os.path.join(cache_dir, 'transformers')
        print(f"Using custom cache directory: {cache_dir}")
    elif 'HF_HOME' in os.environ:
        # Environment variable already set
        print(f"Using HF_HOME from environment: {os.environ['HF_HOME']}")
    else:
        # Default cache location
        default_cache = os.path.expanduser('~/.cache/huggingface')
        print(f"Using default cache directory: {default_cache}")

    return os.environ.get('HF_HOME', os.path.expanduser('~/.cache/huggingface'))


def load_model(cache_dir=None):
    """Load the VibeVoice model and processor"""
    print("Loading VibeVoice-Large-Q8 model...")

    # Set up cache directory
    actual_cache = setup_cache_directory(cache_dir)

    # Check if model is already cached
    cache_path = os.path.join(actual_cache, 'hub')
    if os.path.exists(cache_path) and any('VibeVoice' in d for d in os.listdir(cache_path) if os.path.isdir(os.path.join(cache_path, d))):
        print("Model found in cache - loading from disk...")
    else:
        print("Model not in cache - downloading ~11.6 GB (this may take several minutes)...")

    model = AutoModelForCausalLM.from_pretrained(
        "FabioSarracino/VibeVoice-Large-Q8",
        device_map="auto",
        trust_remote_code=True,
        torch_dtype=torch.bfloat16,
        cache_dir=cache_dir,
    )

    processor = AutoProcessor.from_pretrained(
        "FabioSarracino/VibeVoice-Large-Q8",
        trust_remote_code=True,
        cache_dir=cache_dir,
    )

    print(f"Model loaded successfully on device: {model.device}")
    return model, processor


def generate_speech(model, processor, text, output_path="output.wav"):
    """Generate speech from text and save to file"""
    print(f"Generating speech for: '{text}'")

    # Process input text
    inputs = processor(text, return_tensors="pt").to(model.device)

    # Generate audio
    with torch.no_grad():
        output = model.generate(**inputs, max_new_tokens=None)

    # Extract audio and save
    audio = output.speech_outputs[0].cpu().numpy()
    wavfile.write(output_path, 24000, audio)

    print(f"Audio saved to: {output_path}")
    return output_path


def main():
    parser = argparse.ArgumentParser(description="Generate speech using VibeVoice")
    parser.add_argument(
        "--text",
        type=str,
        default="Hello, this is VibeVoice speaking. I'm a text-to-speech model running on a powerful GPU.",
        help="Text to convert to speech"
    )
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="Output WAV file path (default: output_TIMESTAMP.wav)"
    )
    parser.add_argument(
        "--batch",
        type=str,
        default=None,
        help="Path to text file with multiple lines to process"
    )
    parser.add_argument(
        "--cache-dir",
        type=str,
        default=None,
        help="Directory to cache models (default: ~/.cache/huggingface). Use network volume path for persistent storage."
    )

    args = parser.parse_args()

    # Check GPU availability
    if not torch.cuda.is_available():
        print("WARNING: CUDA not available. This model requires an NVIDIA GPU!")
        return

    print(f"Using GPU: {torch.cuda.get_device_name(0)}")
    print(f"GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1e9:.2f} GB")
    print()

    # Load model
    model, processor = load_model(cache_dir=args.cache_dir)

    # Create output directory
    os.makedirs("outputs", exist_ok=True)

    # Process batch file or single text
    if args.batch:
        print(f"Processing batch file: {args.batch}")
        with open(args.batch, 'r') as f:
            texts = [line.strip() for line in f if line.strip()]

        for i, text in enumerate(texts):
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = f"outputs/output_{i+1}_{timestamp}.wav"
            generate_speech(model, processor, text, output_path)
    else:
        # Single text generation
        if args.output is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = f"outputs/output_{timestamp}.wav"
        else:
            output_path = args.output

        generate_speech(model, processor, args.text, output_path)

    print("\nDone!")


if __name__ == "__main__":
    main()
