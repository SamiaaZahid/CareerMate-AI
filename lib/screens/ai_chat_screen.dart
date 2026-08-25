import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Chat messages list
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': "Hello! I'm your AI Career Assistant. How can I help you today?"
    },
  ];

  bool _isLoading = false;
  late GenerativeModel _model;
  late ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  void _initializeGemini() {
    // Fetching API key from .env file securely
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    // Initializing the Gemini model with gemini-1.5-flash
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    
    // Starting a chat session to maintain conversation history
    _chatSession = _model.startChat(
      history: [
        Content.text("You are an AI Career Assistant for a career guidance app named CareerMate AI. Help users with resumes, internships, job search strategies, and professional development in a friendly, concise, and structured way.")
      ],
    );
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Sending message to Gemini API
      final response = await _chatSession.sendMessage(Content.text(userMessage));
      final aiResponse = response.text ?? "I couldn't generate a response. Please try again.";

      setState(() {
        _messages.add({'sender': 'ai', 'text': aiResponse});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': "Network Error: Could not connect to AI. Please check your internet connection or API key."
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF54309C), // Primary Purple Theme matching your app
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('AI Career Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Messages ListView
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment:
                        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        const CircleAvatar(
                          backgroundColor: Color(0xFF54309C),
                          radius: 14,
                          child: Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF54309C) : const Color(0xFFF2EDFC),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
          ),

          // Loading indicator when AI is typing
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF54309C)),
                  ),
                  SizedBox(width: 12),
                  Text("AI is typing...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

          // Bottom Input Bar matching reference image
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask AI Career Assistant...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF54309C),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}