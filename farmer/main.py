from flask import Flask, jsonify
from flask_cors import CORS
from datetime import datetime
import random

app = Flask(__name__)
CORS(app)

@app.route('/api/farmer-dashboard', methods=['GET'])
def get_farmer_dashboard():
    """Get farmer dashboard data including weather, pollination readiness, and sensor data"""
    
    # Simulated data matching the UI requirements
    data = {
        "farm": {
            "name": "Green Valley Pumpkin Farm",
            "location": "Central Valley, CA",
            "lastUpdated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        },
        "pollinationStatus": "warning",  # ready, not_ready, warning
        "weather": {
            "alert": True,
            "alertType": "high_humidity",
            "message": "High Humidity Detected!",
            "humidity": 89,
            "temperature": 30,
            "recommendation": "Pollination not recommended due to high humidity"
        },
        "pollinationReadiness": {
            "femaleFlowersReady": 8,
            "maleFlowersReady": 12,
            "status": "ready"  # ready, not_ready, warning
        },
        "fieldSensors": {
            "soilMoisture": 28,  # percentage
            "temperature": 30,  # celsius
            "light": 750,  # lux
            "recommendation": "Pollinate Tomorrow"
        }
    }
    
    return jsonify(data)

@app.route('/api/sensor-fusion', methods=['GET'])
def get_sensor_fusion():
    """Get sensor fusion results from multiple sensors"""
    return jsonify({
        "status": "operational",
        "sensors": ["soil", "temperature", "humidity", "light"],
        "lastFusion": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    })

@app.route('/api/ml-prediction', methods=['GET'])
def get_ml_prediction():
    """Get ML model prediction output for pollination readiness"""
    return jsonify({
        "prediction": "not_recommended",
        "confidence": 0.87,
        "reason": "High humidity conditions detected",
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

