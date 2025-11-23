# utils/constants.py
"""
Constants for IoT Drone project.
Includes drone, camera, and sensor settings.
"""

# --- Drone settings ---
DRONE_ID = "drone_001"
DEFAULT_TAKEOFF_ALTITUDE = 10      # meters
DEFAULT_SPEED_MPS = 3              # meters per second

# --- MAVLink settings ---
MAVLINK_URL = "udp://127.0.0.1:14550"

# --- Camera settings ---
CAMERA_RESOLUTION = "1080p"
CAMERA_FPS = 30

# --- Temperature/Humidity Sensor settings ---
TEMP_HUMIDITY_UPDATE_INTERVAL = 2  # seconds

# --- General settings ---
MAX_FLIGHT_TIME_MIN = 15
LOW_BATTERY_THRESHOLD = 20  # percent

# --- File paths ---
CONFIG_FILE = "config.json"
LOG_FILE = "drone.log"
