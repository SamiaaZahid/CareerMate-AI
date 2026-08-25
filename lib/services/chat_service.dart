import 'chat_context_builder.dart';
import 'gemini_service.dart';

/// A single message shown in the chat UI.
class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

/// Owns the running conversation for the AI chat screen. Rebuilds the
/// app context on every message so the chat always reflects current data.
class ChatService {
  ChatService();

  final List<ChatMessage> messages = [];
  final List<GeminiChatTurn> _history = [];

  Future<ChatMessage> sendMessage(String userText) async {
    final trimmed = userText.trim();
    if (trimmed.isEmpty) {
      return const ChatMessage(text: '', isUser: false);
    }

    messages.add(ChatMessage(text: trimmed, isUser: true));

    final systemInstruction = await ChatContextBuilder.build();

    final replyText = await GeminiService.instance.sendMessage(
      userMessage: trimmed,
      systemInstruction: systemInstruction,
      history: _history,
    );

    _history.add(GeminiChatTurn(role: 'user', text: trimmed));
    _history.add(GeminiChatTurn(role: 'model', text: replyText));

    final reply = ChatMessage(text: replyText, isUser: false);
    messages.add(reply);
    return reply;
  }
}