@echo off
REM Setup script for ML training environment (Windows)

echo ================================
echo ML Training Environment Setup
echo ================================

REM Create virtual environment
echo.
echo 1. Creating Python virtual environment...
python -m venv venv

REM Activate virtual environment
echo.
echo 2. Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo.
echo 3. Upgrading pip...
python -m pip install --upgrade pip

REM Install requirements
echo.
echo 4. Installing dependencies...
pip install -r requirements.txt

REM Create directories
echo.
echo 5. Creating project directories...
if not exist "data\detection\images\train" mkdir data\detection\images\train
if not exist "data\detection\images\val" mkdir data\detection\images\val
if not exist "data\detection\labels\train" mkdir data\detection\labels\train
if not exist "data\detection\labels\val" mkdir data\detection\labels\val
if not exist "data\classification\train\bud" mkdir data\classification\train\bud
if not exist "data\classification\train\open" mkdir data\classification\train\open
if not exist "data\classification\train\post-pollination" mkdir data\classification\train\post-pollination
if not exist "data\classification\val\bud" mkdir data\classification\val\bud
if not exist "data\classification\val\open" mkdir data\classification\val\open
if not exist "data\classification\val\post-pollination" mkdir data\classification\val\post-pollination
if not exist "models\detector" mkdir models\detector
if not exist "models\classifier" mkdir models\classifier
if not exist "models\exported" mkdir models\exported

REM Setup Jupyter
echo.
echo 6. Setting up Jupyter kernel...
python -m ipykernel install --user --name ml_training --display-name "ML Training"

echo.
echo ✓ Setup completed successfully!
echo.
echo Next steps:
echo   1. Prepare your dataset in data/ directory
echo   2. Run: jupyter notebook notebooks/
echo   3. Open 'model_training.ipynb' to start training
echo.
pause
