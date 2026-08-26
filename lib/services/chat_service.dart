import 'chat_context_builder.dart';
import 'chat_tools.dart';
import 'gemini_service.dart';

/// A single message shown in the chat UI.
class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

/// Owns the running conversation for the AI chat screen. Rebuilds the
/// app context on every message so the chat always reflects current
/// data, and can hand off to [ChatTools] when the user asks it to
/// actually do something rather than just answer a question.
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
    _history.add(GeminiChatTurn.user(trimmed));

    final systemInstruction = await ChatContextBuilder.build();

    var result = await GeminiService.instance.send(
      contents: _history,
      systemInstruction: systemInstruction,
      toolDeclarations: ChatTools.declarations,
    );

    // If Gemini wants to run an action, do it, tell Gemini what
    // happened, and ask it to continue. Capped so a misbehaving model
    // can't loop forever.
    var remainingSteps = 3;
    while (result.isFunctionCall && remainingSteps > 0) {
      remainingSteps--;

      final name = result.functionCallName!;
      final args = result.functionCallArgs!;

      _history.add(GeminiChatTurn.functionCall(name, args, thoughtSignature: result.thoughtSignature));

      final executionResult = await ChatTools.execute(name, args);
      _history.add(GeminiChatTurn.functionResponse(name, {'result': executionResult}));

      result = await GeminiService.instance.send(
        contents: _history,
        systemInstruction: systemInstruction,
        toolDeclarations: ChatTools.declarations,
      );
    }

    final replyText = result.text ?? 'Done!';
    _history.add(GeminiChatTurn.model(replyText));

    final reply = ChatMessage(text: replyText, isUser: false);
    messages.add(reply);
    return reply;
  }
}