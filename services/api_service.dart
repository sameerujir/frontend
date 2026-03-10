import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction_result.dart';
import '../models/history_item.dart';

class ApiService {
  // --- SMART URL DETECTION ---
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000'; 
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';  
    } else {
      return 'http://127.0.0.1:8000'; // iOS / Fallback
    }
  }

  // --- 1. Auth ---
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Login failed: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> register(String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password, 'email': email}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 201 || response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Registration failed: ${response.statusCode}');
  }

  // --- 2. Prediction (With Note Support) ---
  static Future<PredictionResult> predict(XFile imageFile, {String? note}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) throw Exception('Not authenticated.');

    // ✅ FIXED: Added trailing slash to /predict/
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict/'));
    request.headers['Authorization'] = 'Bearer $token';

    // Add Note if exists
    if (note != null && note.isNotEmpty) {
      request.fields['symptoms'] = note;
    }

    // Add File (Web vs Mobile handling)
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'file', await imageFile.readAsBytes(), filename: imageFile.name,
        contentType: http.MediaType.parse('image/jpeg')
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return PredictionResult.fromJson(jsonDecode(response.body), imageFile);
    }
    
    // ✅ ENHANCED: Better error message
    final errorBody = response.body.isNotEmpty ? response.body : 'No error details';
    throw Exception('Prediction failed: ${response.statusCode} - $errorBody');
  }

  // --- 3. History ---
  static Future<List<HistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      // ✅ FIXED: Added trailing slash for consistency
      final response = await http.get(
        Uri.parse('$baseUrl/history/'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => HistoryItem.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("History Error: $e");
    }
    return [];
  }

  // --- 4. Stats ---
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final response = await http.get(
        Uri.parse('$baseUrl/history/stats'), 
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Stats Error: $e");
    }
    return {};
  }

  // --- 5. TEST CONNECTION (NEW - for debugging) ---
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        debugPrint('✅ Backend connection successful!');
        debugPrint('Backend response: ${response.body}');
        return true;
      } else {
        debugPrint('❌ Backend returned: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Cannot connect to backend: $e');
      debugPrint('Trying to connect to: $baseUrl');
      return false;
    }
  }
}