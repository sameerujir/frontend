import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  String? _token;
  String? _username;
  bool _isLoading = false;
  String? _error;
  bool _isRegisterMode = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isRegisterMode => _isRegisterMode;
  String? get username => _username;

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await ApiService.login(username, password);
      await _saveAuth(result);
      return true;
    } catch (e) {
      _error = "Invalid credentials";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String username, String password, String email) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await ApiService.register(username, password, email);
      await _saveAuth(result);
      return true;
    } catch (e) {
      _error = "Registration failed.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveAuth(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    _token = data['access_token'];
    _username = data['username'] ?? 'User';
    await prefs.setString('jwt_token', _token!);
    await prefs.setString('username', _username!);
    await prefs.setString('userId', data['user_id'] ?? '');
    notifyListeners();
  }
  
  Future<void> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _username = prefs.getString('username');
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    _username = null;
    notifyListeners();
  }

  void toggleRegisterMode() {
    _isRegisterMode = !_isRegisterMode;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool val) { _isLoading = val; notifyListeners(); }
  void _clearError() { _error = null; notifyListeners(); }
}