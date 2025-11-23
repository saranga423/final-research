// utils/constants.dart

class AppConstants {
  // App Name
  static const String appName = "Pumpkin Pollination Assistant";

  // Colors (use in your theme)
  static const int primaryColor = 0xFF4CAF50;
  static const int secondaryColor = 0xFF2196F3;

  // Firestore Collections
  static const String flowersCollection = "flowers";
  static const String droneCollection = "drones";

  // API Endpoints (if backend used)
  static const String apiBaseUrl = "https://your-backend-url.com/api";

  // Drone Config
  static const double defaultDroneSpeed = 3.5;
  static const double maxAltitude = 50.0; // meters
  static const double minAltitude = 2.0; // meters

  // Location Settings
  static const int locationAccuracy = 1; // high accuracy
  static const int locationInterval = 5000; // ms

  // Pollination thresholds (example, modify based on ML model)
  static const double readinessThreshold = 0.7;
}
