import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  late final GeminiChatSession _session;
  List<ChatMessage> get messages => _messages;

  ChatViewModel() {
    _session = GeminiService.createChatSession();
    _messages.add(ChatMessage(text: "Hello! I'm your AI Plant Expert. Ask me anything!", isUser: false));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();
    
    _messages.add(ChatMessage(text: "Thinking...", isUser: false));
    int botIndex = _messages.length - 1;
    notifyListeners();

    try {
      await for (final chunk in _session.sendMessageStream(text)) {
        _messages[botIndex] = ChatMessage(text: chunk, isUser: false);
        notifyListeners();
      }
    } catch (e) {
      _messages[botIndex] = ChatMessage(text: "Error connecting to expert.", isUser: false);
      notifyListeners();
    }
  }
}