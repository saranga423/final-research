# drone/mavlink_handler.py

class MavlinkHandler:
    """
    Simplified MAVLink communication handler.
    """
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
        self.connected = False

    def connect(self):
        print(f"Connecting to MAVLink at {self.connection_string}")
        self.connected = True

    def disconnect(self):
        print("Disconnecting MAVLink")
        self.connected = False

    def send_command(self, command: str):
        if self.connected:
            print(f"Sending command: {command}")
        else:
            print("MAVLink not connected. Cannot send command.")
