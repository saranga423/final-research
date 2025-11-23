# drone/flight_controller.py

class FlightController:
    """
    Basic drone flight control interface.
    """
    def __init__(self, drone_id: str):
        self.drone_id = drone_id
        self.altitude = 0.0
        self.speed = 0.0
        self.is_flying = False

    def takeoff(self, altitude: float):
        print(f"[{self.drone_id}] Taking off to {altitude} meters.")
        self.altitude = altitude
        self.is_flying = True

    def land(self):
        print(f"[{self.drone_id}] Landing.")
        self.altitude = 0.0
        self.is_flying = False

    def set_speed(self, speed: float):
        print(f"[{self.drone_id}] Setting speed to {speed} m/s.")
        self.speed = speed

    def status(self):
        return {
            "drone_id": self.drone_id,
            "altitude": self.altitude,
            "speed": self.speed,
            "is_flying": self.is_flying
        }
