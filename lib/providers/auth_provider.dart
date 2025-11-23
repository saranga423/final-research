import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/auth_api.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _api = AuthApi();
  final Logger _logger = Logger();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Login method
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.login(email, password);
      if (response['status'] == 'success') {
        // Save token or user info if needed
        return true;
      } else {
        _logger.e("Login failed: ${response['message']}");
        return false;
      }
    } catch (e) {
      _logger.e("Login error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register method
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.register(email, password);
      if (response['status'] == 'success') {
        return true;
      } else {
        _logger.e("Registration failed: ${response['message']}");
        return false;
      }
    } catch (e) {
      _logger.e("Registration error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
