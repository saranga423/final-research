# IoT Device/ src/ __init__.py
# src/__init__.py
"""
src package for the IoT-device project.

Contains:
- flight_controller.py
- mavlink_handler.py
- sensors/
"""

# Optional: Export main modules for easier imports
from drone.flight_controller import FlightController
from drone.mavlink_handler import MavlinkHandler
from .sensors.camera import CameraSensor
from .sensors.temp_humidity import TempHumiditySensor

__all__ = [
    "FlightController",
    "MavlinkHandler",
    "CameraSensor",
    "TempHumiditySensor"
]


