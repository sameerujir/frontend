import 'package:flutter/foundation.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';

class HistoryViewModel extends ChangeNotifier {
  List<HistoryItem> _history = [];
  bool _isLoading = false;
  List<HistoryItem> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await ApiService.getHistory();
    } catch (e) { /* ignore */ }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}