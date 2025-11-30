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
        return {"image_data": "image_data_placeholder"}
    def capture(self):
        """Return image info in a dict for unified access"""
        image_data = self.capture_image()
        return {"camera_image": image_data}
    
__all__ = ['CameraSensor']

