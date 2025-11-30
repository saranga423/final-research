"""
Drone sensors package
Contains camera and temperature/humidity sensors
Provides a unified interface to access all sensors on the drone.
"""

from .camera import CameraSensor
from .temp_humidity import TempHumiditySensor

# Optional: convenience class to access all sensors at once
class DroneSensors:
    def __init__(self):
        self.camera = CameraSensor()
        self.temp_humidity = TempHumiditySensor()

    def read_all(self):
        """Return all sensor data in a dict"""
        data = {}
        data.update(self.camera.capture())           # returns image info or path
        data.update(self.temp_humidity.read())      # returns temp & humidity
        return data
__all__ = ['CameraSensor', 'TempHumiditySensor', 'DroneSensors']

    

