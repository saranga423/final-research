import os
import cv2
import zipfile
import random
import numpy as np
import pandas as pd
from tqdm import tqdm # type: ignore

BASE_DIR = "pollination_readiness_dataset"
IMG_SIZE = 224
TOTAL_IMAGES = 3000

SPLITS = {
    "train": 0.7,
    "val": 0.15,
    "test": 0.15
}

CLASSES = {
    0: "not_ready",
    1: "ready"
}

def make_dirs():
    for split in SPLITS:
        for cls in CLASSES.values():
            os.makedirs(f"{BASE_DIR}/images/{split}/{cls}", exist_ok=True)
    os.makedirs(f"{BASE_DIR}/annotations", exist_ok=True)

def generate_dummy_image(label):
    img = np.zeros((IMG_SIZE, IMG_SIZE, 3), dtype=np.uint8)

    color = (0, 255, 0) if label == 1 else (0, 0, 255)
    cv2.circle(
        img,
        (IMG_SIZE // 2, IMG_SIZE // 2),
        random.randint(40, 80),
        color,
        -1
    )

    noise = np.random.randint(0, 50, (IMG_SIZE, IMG_SIZE, 3), dtype=np.uint8)
    img = cv2.add(img, noise)

    return img

def split_selector(idx):
    r = random.random()
    if r < SPLITS["train"]:
        return "train"
    elif r < SPLITS["train"] + SPLITS["val"]:
        return "val"
    return "test"

def main():
    make_dirs()
    records = []

    for i in tqdm(range(TOTAL_IMAGES), desc="Generating images"):
        label = random.choice([0, 1])
        split = split_selector(i)
        cls_name = CLASSES[label]

        img = generate_dummy_image(label)
        fname = f"img_{i:05d}.jpg"

        path = f"{BASE_DIR}/images/{split}/{cls_name}/{fname}"
        cv2.imwrite(path, img)

        records.append([
            fname,
            random.choice(["male", "female"]),
            random.choice(["stigma", "pollen"]),
            random.choice(["morning", "afternoon"]),
            label,
            split
        ])

    df = pd.DataFrame(records, columns=[
        "image_name",
        "flower_type",
        "visible_part",
        "lighting",
        "label",
        "split"
    ])
    df.to_csv(f"{BASE_DIR}/annotations/metadata.csv", index=False)

    with open(f"{BASE_DIR}/dataset.yaml", "w") as f:
        f.write(
            f"""path: {BASE_DIR}
train: images/train
val: images/val
test: images/test

names:
  0: not_ready
  1: ready
"""
        )

    zipf = zipfile.ZipFile("pollination_dataset.zip", "w", zipfile.ZIP_DEFLATED)
    for root, _, files in os.walk(BASE_DIR):
        for file in files:
            zipf.write(
                os.path.join(root, file),
                arcname=os.path.relpath(os.path.join(root, file), BASE_DIR)
            )
    zipf.close()

    print("DONE: pollination_dataset.zip created")

if __name__ == "__main__":
    main()
