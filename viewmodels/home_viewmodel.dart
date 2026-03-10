import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/prediction_result.dart';
import '../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  PredictionResult? _lastPrediction;
  String? _error;

  bool get isLoading => _isLoading;
  PredictionResult? get lastPrediction => _lastPrediction;
  String? get error => _error;

  Future<PredictionResult?> scanPlant(ImageSource source, {String? userNote}) async {
    if (_isLoading) return null;
    
    _setLoading(true);
    _clearError();

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      
      if (picked != null) {
        final result = await ApiService.predict(picked, note: userNote); 
        _lastPrediction = result;
        _setLoading(false);
        return result;
      }
    } catch (e) {
      _error = "Could not connect. Please check backend.";
      debugPrint("Error: $e");
    } finally {
      _setLoading(false);
    }
    return null;
  }

  void clearLastPrediction() {
    _lastPrediction = null;
    notifyListeners();
  }

  void _setLoading(bool val) { _isLoading = val; notifyListeners(); }
  void _clearError() { _error = null; notifyListeners(); }
}