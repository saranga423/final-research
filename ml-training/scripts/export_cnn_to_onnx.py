import torch
import torch.nn as nn
from torchvision import models

# ---------------- CONFIG ----------------
MODEL_PATH = "pollination_readiness_cnn.pth"
ONNX_PATH = "pollination_readiness_cnn.onnx"
IMG_SIZE = 224
NUM_CLASSES = 2
# ---------------------------------------

device = torch.device("cpu")  # ONNX export should be on CPU

# Load model architecture
model = models.resnet18(pretrained=False)
model.fc = nn.Linear(model.fc.in_features, NUM_CLASSES)

# Load trained weights
state_dict = torch.load(MODEL_PATH, map_location=device)
model.load_state_dict(state_dict)
model.eval()
model.to(device)

# Dummy input (batch_size=1, RGB, 224x224)
dummy_input = torch.randn(1, 3, IMG_SIZE, IMG_SIZE, device=device)

# Export to ONNX
torch.onnx.export(
    model,
    dummy_input, # type: ignore
    ONNX_PATH,
    export_params=True,
    opset_version=12,
    do_constant_folding=True,
    input_names=["input_image"],
    output_names=["pollination_output"],
    dynamic_axes={
        "input_image": {0: "batch_size"},
        "pollination_output": {0: "batch_size"}
    }
)

print(f"ONNX model exported successfully → {ONNX_PATH}")
