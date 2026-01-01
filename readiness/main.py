from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime
import random

app = Flask(__name__)
CORS(app)

@app.route('/api/readiness-check', methods=['POST'])
def readiness_check():
    """Process flower image and return readiness result with CNN model inference"""
    
    # Get image file from request (would normally process actual image)
    # For now, simulate the CNN model inference result
    image_file = request.files.get('image')
    
    # Simulated CNN model inference result
    flower_type = random.choice(['Male', 'Female'])
    is_ready = random.choice([True, False])
    confidence_score = round(random.uniform(0.65, 0.98), 2)
    
    # Sensor fusion data (combining image analysis with sensor readings)
    sensor_data = {
        "temperature": round(random.uniform(25, 32), 1),
        "humidity": round(random.uniform(60, 90), 1),
        "light": round(random.uniform(700, 900), 0),
        "soilMoisture": round(random.uniform(25, 45), 1),
    }
    
    # Combined result from CNN + Sensor fusion
    result = {
        "flowerType": flower_type,
        "isReady": is_ready,
        "confidenceScore": confidence_score,
        "status": "Ready" if is_ready else "Not Ready",
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "sensorData": sensor_data,
        "recommendation": _get_recommendation(is_ready, confidence_score, sensor_data)
    }
    
    return jsonify(result)

@app.route('/api/readiness-check', methods=['GET'])
def readiness_check_get():
    """Get readiness result (for testing without image upload)"""
    
    # Simulated result
    flower_type = random.choice(['Male', 'Female'])
    is_ready = random.choice([True, False])
    confidence_score = round(random.uniform(0.65, 0.98), 2)
    
    sensor_data = {
        "temperature": round(random.uniform(25, 32), 1),
        "humidity": round(random.uniform(60, 90), 1),
        "light": round(random.uniform(700, 900), 0),
        "soilMoisture": round(random.uniform(25, 45), 1),
    }
    
    result = {
        "flowerType": flower_type,
        "isReady": is_ready,
        "confidenceScore": confidence_score,
        "status": "Ready" if is_ready else "Not Ready",
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "sensorData": sensor_data,
        "recommendation": _get_recommendation(is_ready, confidence_score, sensor_data)
    }
    
    return jsonify(result)

def _get_recommendation(is_ready, confidence_score, sensor_data):
    """Generate recommendation based on readiness status, confidence, and sensor data"""
    if is_ready and confidence_score > 0.8:
        return "Flower is ready for pollination. Optimal conditions detected."
    elif is_ready and confidence_score > 0.7:
        return "Flower appears ready, but verify conditions before pollination."
    elif not is_ready:
        return "Flower is not ready for pollination. Wait for optimal maturity."
    else:
        return "Low confidence score. Please retake image for better analysis."

@app.route('/api/sensor-fusion', methods=['GET'])
def sensor_fusion():
    """Get sensor fusion results combined with image analysis"""
    return jsonify({
        "status": "operational",
        "sensors": ["temperature", "humidity", "light", "soilMoisture"],
        "lastFusion": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "imageAnalysis": True,
        "cnnModelVersion": "v1.2"
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)

