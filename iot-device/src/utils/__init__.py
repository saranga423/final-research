# utils/__init__.py
"""
Utils package for reusable helper functions, constants, and services.

You can import modules like:
from utils import DRONE_ID, DEFAULT_TAKEOFF_ALTITUDE, CAMERA_RESOLUTION
"""

# Import constants to expose them at the package level
from .constants import DEFAULT_TAKEOFF_ALTITUDE, DRONE_ID, CAMERA_RESOLUTION, \
    DEFAULT_SPEED_MPS, MAVLINK_URL, TEMP_HUMIDITY_UPDATE_INTERVAL, MAX_FLIGHT_TIME_MIN, \
    LOW_BATTERY_THRESHOLD, CONFIG_FILE, LOG_FILE

# Optional: define __all__ for explicit exports
__all__ = [
    "DEFAULT_TAKEOFF_ALTITUDE",
    "DRONE_ID",
    "CAMERA_RESOLUTION",
    "DEFAULT_SPEED_MPS",
    "MAVLINK_URL",
    "TEMP_HUMIDITY_UPDATE_INTERVAL",
    "MAX_FLIGHT_TIME_MIN",
    "LOW_BATTERY_THRESHOLD",
    "CONFIG_FILE",
    "LOG_FILE"
]
