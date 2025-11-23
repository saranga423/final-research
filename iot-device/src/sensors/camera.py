# drone/sensors/camera.py

class CameraSensor:
    """
    Simulated camera sensor interface.
    """
    def __init__(self):
        self.active = False

    def start(self):
        print("Camera started")
        self.active = True

    def stop(self):
        print("Camera stopped")
        self.active = False

    def capture_image(self):
        if not self.active:
            print("Camera is not active!")
            return None
        print("Capturing image...")
        # Here, return a simulated image path or data
        return "image_data_placeholder"
