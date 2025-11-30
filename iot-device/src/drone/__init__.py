# drone/__init__.py
"""
Drone module package
Contains:
- Flight controller
- MAVLink communication
- Sensors (camera, temperature/humidity)
"""

from drone.flight_controller import FlightController
from drone.mavlink_handler import MavlinkHandler
from sensors.camera import CameraSensor
from sensors.temp_humidity import TempHumiditySensor

__all__ = [
    "FlightController",
    "MavlinkHandler",
    "CameraSensor",
    "TempHumiditySensor",
]


