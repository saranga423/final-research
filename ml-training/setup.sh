#!/bin/bash
# Setup script for ML training environment

echo "================================"
echo "ML Training Environment Setup"
echo "================================"

# Create virtual environment
echo -e "\n1. Creating Python virtual environment..."
python -m venv venv

# Activate virtual environment
echo -e "\n2. Activating virtual environment..."
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# Upgrade pip
echo -e "\n3. Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo -e "\n4. Installing dependencies..."
pip install -r requirements.txt

# Create directories
echo -e "\n5. Creating project directories..."
mkdir -p data/{detection,classification}/{images,labels}/{train,val}
mkdir -p models/{detector,classifier,exported}
mkdir -p notebooks
mkdir -p configs

# Download sample data instruction
echo -e "\n6. Data preparation instructions..."
echo "   Please prepare your dataset with the following structure:"
echo ""
echo "   data/detection/"
echo "   ├── images/"
echo "   │   ├── train/  (training images)"
echo "   │   └── val/    (validation images)"
echo "   └── labels/"
echo "       ├── train/  (YOLO format .txt files)"
echo "       └── val/    (YOLO format .txt files)"
echo ""
echo "   data/classification/"
echo "   ├── train/"
echo "   │   ├── bud/"
echo "   │   ├── open/"
echo "   │   └── post-pollination/"
echo "   └── val/"
echo "       ├── bud/"
echo "       ├── open/"
echo "       └── post-pollination/"
echo ""

# Setup Jupyter
echo -e "\n7. Setting up Jupyter kernel..."
python -m ipykernel install --user --name ml_training --display-name "ML Training"

echo -e "\n✓ Setup completed successfully!"
echo -e "\nNext steps:"
echo "  1. Prepare your dataset"
echo "  2. Run: jupyter notebook notebooks/"
echo "  3. Open 'model_training.ipynb' to start training"
echo ""
