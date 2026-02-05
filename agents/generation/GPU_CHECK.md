# GPU Availability Check

**Date:** Feb 4, 2026  
**Status:** PENDING - Need Zoro to Check

---

## System Info Needed:

**Hardware:**
- Mac mini model/year?
- CPU: Apple Silicon (M1/M2/M3) or Intel?
- GPU: Integrated or discrete?
- RAM: 8GB / 16GB / 32GB+?

---

## MusicGen Requirements:

**Minimum:**
- Python 3.9+
- 8GB RAM
- GPU: Metal (Apple Silicon) OR CUDA (NVIDIA)

**Recommended:**
- 16GB+ RAM
- Apple M1/M2/M3 OR RTX 3060+ GPU

---

## If GPU Available:

### Install Audiocraft (Hugging Face)
```bash
pip install audiocraft torch torchaudio
```

### Test Generation
```bash
python3 << EOF
from audiocraft.models import MusicGen
import torch

# Check if MPS (Metal) available (Apple Silicon)
device = "mps" if torch.backends.mps.is_available() else "cpu"
print(f"Using device: {device}")

# Load small model (1.5GB)
model = MusicGen.get_pretrained('small', device=device)
model.set_generation_params(duration=30)

# Test generation
output = model.generate(
    descriptions=["upbeat country instrumental with acoustic guitar"],
    progress=True
)

print("✅ MusicGen working!")
EOF
```

### Model Sizes:
- **small:** 1.5GB (fastest, good quality)
- **medium:** 3GB (better quality)
- **large:** 8GB (best quality, slower)

---

## If NO GPU:

**Stick with Suno API:**
- Free tier: 50 generations/month
- Paid tier: $10-30/mo for more credits
- Cloud-based, no local processing needed
- Better quality than local CPU generation

---

## Decision:

**Waiting on Zoro to confirm hardware specs!**

If Apple Silicon M1+ → Set up MusicGen (free unlimited generations!)  
If Intel/older Mac → Use Suno API only (faster, better quality)

---

**Next:** Once specs confirmed, install appropriate solution.
