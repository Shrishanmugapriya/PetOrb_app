import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import '../core/services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  List<types.Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<types.Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final _uuid = const Uuid();

  Future<void> fetchHistory(String petId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await ApiService.get('/ai/chat?petId=$petId');
      if (res.statusCode == 200) {
        final List parsed = jsonDecode(res.body);
        
        // Map backend history to flutter_chat_ui messages
        // Show newest messages first for the Chat UI
        _messages = parsed.map<types.Message>((msg) {
          final isUser = msg['sender'] == 'user';
          return types.TextMessage(
            author: types.User(
              id: isUser ? 'user' : 'ai',
              firstName: isUser ? 'You' : 'PetOrb AI',
              imageUrl: isUser ? null : 'assets/logo.png',
            ),
            id: msg['_id'] ?? msg['id'] ?? _uuid.v4(),
            text: msg['content'] ?? '',
            createdAt: msg['timestamp'] != null 
                ? DateTime.parse(msg['timestamp']).millisecondsSinceEpoch 
                : DateTime.now().millisecondsSinceEpoch,
          );
        }).toList().reversed.toList();
      }
    } catch (e) {
      print("Fetch chat history error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String petId, String content) async {
    // Add user message immediately to the UI
    final userMessage = types.TextMessage(
      author: const types.User(id: 'user', firstName: 'You'),
      id: _uuid.v4(),
      text: content,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _messages.insert(0, userMessage);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.post('/ai/ask', {
        'petId': petId,
        'question': content,
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final String reply = data['reply'] ?? 'Empty response';
        
        final aiMessage = types.TextMessage(
          author: const types.User(
            id: 'ai',
            firstName: 'PetOrb AI',
          ),
          id: _uuid.v4(),
          text: reply,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        _messages.insert(0, aiMessage);
      } else {
        final err = jsonDecode(res.body);
        _errorMessage = err['message'] ?? 'Failed to communicate with AI Assistant.';
        
        // Insert error notice message
        final errorMsg = types.TextMessage(
          author: const types.User(id: 'ai', firstName: 'System Alert'),
          id: _uuid.v4(),
          text: "❌ Error: $_errorMessage",
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        _messages.insert(0, errorMsg);
      }
    } catch (e) {
      _errorMessage = "Network connection failed. Please check your backend connection.";
      final errorMsg = types.TextMessage(
        author: const types.User(id: 'ai', firstName: 'System Alert'),
        id: _uuid.v4(),
        text: "❌ Error: $_errorMessage",
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _messages.insert(0, errorMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory(String petId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/ai/clear', {'petId': petId});
      if (res.statusCode == 200) {
        _messages.clear();
      }
    } catch (e) {
      print("Clear history error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
