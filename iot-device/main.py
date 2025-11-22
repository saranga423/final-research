# Import modules from src
from src.drone.flight_controller import FlightController
from src.drone.mavlink_handler import MavlinkHandler
from src.sensors.camera import CameraSensor
from src.sensors.temp_humidity import TempHumiditySensor

def main():
    # Initialize Flight Controller
    fc = FlightController("drone_001")
    print("=== Flight Controller Status ===")
    fc.takeoff(10)  # Take off to 10 meters
    fc.set_speed(3)  # Set speed to 3 m/s
    print(fc.status())

    # Initialize MAVLink Handler
    mav = MavlinkHandler("udp://127.0.0.1:14550")
    mav.connect()
    mav.send_command("ARM")
    mav.send_command("TAKEOFF 10")
    mav.disconnect()

    # Initialize Camera
    camera = CameraSensor()
    camera.start()
    image_data = camera.capture_image()
    print("Captured image data:", image_data)
    camera.stop()

    # Initialize Temp/Humidity Sensor
    sensor = TempHumiditySensor()
    for i in range(3):
        readings = sensor.read()
        print(f"Sensor reading {i+1}: {readings}")

    # Land the drone
    fc.land()
    print("Drone landed:", fc.status())

if __name__ == "__main__":
    main()