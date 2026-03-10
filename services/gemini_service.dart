import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
 
  static const String _apiKey = 'AIzaSyCe9XUMHs1EUQ0rvzuC4VDFB2_TTWI0NNo'; 

  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash-lite', 
    apiKey: _apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.4,
      topK: 32,
      topP: 0.9,
      maxOutputTokens: 1024,
    ),
  );

  static final Map<String, String> _responseCache = {};

  // --- 2. ERROR HANDLING ---
  static String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('api key')) return 'Invalid API Key.';
    if (errorStr.contains('quota') || errorStr.contains('429')) return 'Rate limit reached.';
    if (errorStr.contains('network') || errorStr.contains('socket')) return 'Check internet connection.';
    return 'An error occurred. Please try again.';
  }

  // --- 3. REMEDY SEARCH ---
  static Future<String> searchRemedy({
    required String plantType,
    required String diseaseName,
    required String description,
    required String severity,
    String? userLocation,
    String? season,
    bool isOrganicPreferred = true,
  }) async {
    final cacheKey = 'remedy_${plantType}_${diseaseName}_$severity'.toLowerCase();
    
    // Cache check
    if (_responseCache.containsKey(cacheKey)) return _responseCache[cacheKey]!;
    final cached = await _getFromCache(cacheKey);
    if (cached != null) {
      _responseCache[cacheKey] = cached;
      return cached;
    }

    try {
      String context = (userLocation != null ? "Location: $userLocation. " : "") +
                       (season != null ? "Season: $season. " : "");
      String pref = isOrganicPreferred ? "Organic preferred." : "Chemicals allowed.";

      final prompt = """
      Act as a plant pathologist. Provide a remedy for:
      Plant: $plantType | Disease: $diseaseName | Severity: $severity
      Context: $context $pref
      
      Format:
      **Immediate Treatment:** [Steps]
      **Prevention:** [Methods]
      **Remedies:** [List]
      """;

      final response = await _model.generateContent([Content.text(prompt)]);
      final result = response.text ?? 'No remedy generated.';
      
      _responseCache[cacheKey] = result;
      await _saveToCache(cacheKey, result);
      return result;
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // --- 4. LIVE EXPERT CHAT (Single Question) ---
  static Future<String> askPlantExpertLive(String question) async {
    try {
      final response = await _model.generateContent([Content.text(question)]);
      return response.text ?? 'No response.';
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // --- 5. CREATE CHAT SESSION ---
  static GeminiChatSession createChatSession() {
    return GeminiChatSession(_apiKey);
  }

  // --- 6. CACHE HELPERS ---
  static Future<void> _saveToCache(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode({'value': value, 'ts': DateTime.now().millisecondsSinceEpoch});
      await prefs.setString('gemini_cache_$key', data);
    } catch (e) { /* ignore */ }
  }
  
  static Future<String?> _getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('gemini_cache_$key');
      if (raw != null) {
        final data = jsonDecode(raw);
        if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(data['ts'])).inDays < 7) {
          return data['value'];
        }
      }
    } catch (e) { /* ignore */ }
    return null;
  }
}

// ==========================================
// ✅ THE FIX IS HERE (GeminiChatSession)
// ==========================================
class GeminiChatSession {
  final GenerativeModel _model;
  ChatSession? _chatSession;
  
  GeminiChatSession(String apiKey) : _model = GenerativeModel(
    model: 'gemini-2.5-flash-lite', 
    apiKey: apiKey,
    // FIX: System instructions go HERE, not in history
    systemInstruction: Content.system('''You are a friendly Indian gardening expert. 
    Expertise: Organic remedies, Indian seasons, local soil.
    Tone: Encouraging and practical.'''),
  );

  void _ensureSession() {
    // FIX: Start chat with empty history (System instruction is already set above)
    _chatSession ??= _model.startChat(history: []);
  }

  Future<String> sendMessage(String message) async {
    try {
      _ensureSession();
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'No response.';
    } catch (e) {
      return "Connection error. Please try again.";
    }
  }

  Stream<String> sendMessageStream(String message) async* {
    try {
      _ensureSession();
      final stream = _chatSession!.sendMessageStream(Content.text(message));
      
      String accumulator = '';
      await for (final chunk in stream) {
        if (chunk.text != null) {
          accumulator += chunk.text!;
          yield accumulator; 
        }
      }
    } catch (e) {
      yield "Error connecting to expert.";
    }
  }
}