import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  String _username = '';
  Map<String, dynamic>? _stats;
  String get username => _username;
  Map<String, dynamic>? get stats => _stats;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? 'Gardener';
    try {
      _stats = await ApiService.getStats();
    } catch (e) { /* ignore */ }
    notifyListeners();
  }
}