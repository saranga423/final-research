# utils/config_loader.py
import json
import os

# Default config file path
from .constants import CONFIG_FILE

class ConfigLoader:
    def __init__(self, file_path=None):
        """
        Load configuration from JSON file.
        :param file_path: Path to the config file. Defaults to CONFIG_FILE from constants.py
        """
        self.file_path = file_path or CONFIG_FILE
        self.config = {}
        self.load_config()

    def load_config(self):
        """Read the JSON config file and store it in self.config."""
        if not os.path.exists(self.file_path):
            raise FileNotFoundError(f"Config file not found: {self.file_path}")
        with open(self.file_path, 'r') as f:
            self.config = json.load(f)

    def get(self, key, default=None):
        """
        Get a configuration value by key.
        Supports nested keys using dot notation, e.g., "camera.resolution"
        """
        keys = key.split(".")
        value = self.config
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k, default)
            else:
                return default
        return value

    def __getitem__(self, key):
        return self.get(key)

    def __str__(self):
        return json.dumps(self.config, indent=2)
