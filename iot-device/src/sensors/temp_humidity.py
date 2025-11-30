# drone/sensors/temp_humidity.py

import random

class TempHumiditySensor:
    """
    Simulated temperature and humidity sensor.
    """
    def __init__(self):
        self.temperature = 25.0  # Celsius
        self.humidity = 50.0     # Percentage

    def read(self):
        # Simulate readings
        self.temperature = round(20 + random.random() * 10, 2)
        self.humidity = round(40 + random.random() * 20, 2)
        return {
            "temperature": self.temperature,
            "humidity": self.humidity
        }
        
    def capture(self):
        """Return temperature and humidity info in a dict for unified access"""
        return {
            "temperature": self.temperature,
            "humidity": self.humidity
        }

__all__ = ['TempHumiditySensor']
