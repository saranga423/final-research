import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Check and request permissions
  static Future<bool> checkPermissions() async {
    // Check location services (GPS)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  /// Get single current location
  static Future<Position?> getCurrentLocation() async {
    bool permissionGranted = await checkPermissions();

    if (!permissionGranted) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Continuous location stream
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  /// Check if GPS is enabled
  static Future<bool> isGPSEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open location settings (use when GPS disabled)
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (use when permission denied forever)
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
