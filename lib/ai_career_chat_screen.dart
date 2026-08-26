import 'package:flutter/material.dart';

import 'services/theme_service.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'analysis_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AICareerChatScreen extends StatefulWidget {
  const AICareerChatScreen({super.key});

  @override
  State<AICareerChatScreen> createState() => _AICareerChatScreenState();
}

class _AICareerChatScreenState extends State<AICareerChatScreen> {
  int _selectedIndex = 0;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hello! I'm your AI Career Assistant. How can I help you today with your resume, internships, interview prep, or career goals?",
      isUser: false,
    ),
  ];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _handleSubmitted(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: trimmedText, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final aiReply = _generateAIResponse(trimmedText);
      setState(() {
        _messages.add(ChatMessage(text: aiReply, isUser: false));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _generateAIResponse(String userInput) {
    final query = userInput.toLowerCase();

    if (query.contains('resume') || query.contains('cv')) {
      return "Here are 3 key resume tips:\n\n"
          "1. Action Verbs: Start bullet points with strong action verbs (e.g. 'Engineered', 'Optimized', 'Designed').\n"
          "2. Quantify Results: Add metrics whenever possible (e.g. 'Boosted app speed by 30%').\n"
          "3. Relevance: Tailor your key skills to match the job description requirements.";
    } else if (query.contains('internship') ||
        query.contains('job') ||
        query.contains('apply')) {
      return "To land top internships:\n\n"
          "1. Apply early before deadlines close.\n"
          "2. Check the Analysis tab to see programs matching your profile skills.\n"
          "3. Include links to your active GitHub or portfolio projects.";
    } else if (query.contains('skill') ||
        query.contains('roadmap') ||
        query.contains('learn')) {
      return "Building relevant skills is crucial! Check out the Skill Roadmap feature from the Home Screen to follow step-by-step milestones (e.g. Excel → SQL → Python → Projects).";
    } else if (query.contains('interview') || query.contains('prep')) {
      return "For tech interviews:\n\n"
          "1. Practice coding & system design concepts.\n"
          "2. Use the STAR method (Situation, Task, Action, Result) for behavioral questions.\n"
          "3. Research the company's tech stack and mission prior to your call.";
    } else if (query.contains('scholarship') || query.contains('grant')) {
      return "For scholarship applications:\n\n"
          "1. Maintain a strong GPA and highlight your STEM leadership.\n"
          "2. Request recommendation letters early.\n"
          "3. Explore active opportunities in the Scholarships tab!";
    } else if (query.contains('hello') ||
        query.contains('hi') ||
        query.contains('hey')) {
      return "Hello! Feel free to ask me anything about your resume, internship search, skill roadmap, or career development!";
    } else {
      return "That's a great topic! I recommend keeping your profile skills updated on CareerMate AI so our Analysis tool can match you with the best internships and learning paths.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, themeMode, _) {
        final colors = ThemeService.instance.colors;

        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: colors.appBarBackground,
            elevation: 0,
            foregroundColor: Colors.white,
            title: Row(
              children: const [
                Icon(Icons.auto_awesome, size: 20),
                SizedBox(width: 8),
                Text(
                  'AI Career Chat',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _ChatMessageBubble(message: message, colors: colors);
                    },
                  ),
                ),
                if (_isTyping)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.chipBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome,
                                  size: 14,
                                  color: colors.primaryPurple),
                              const SizedBox(width: 6),
                              Text(
                                'AI Assistant is typing...',
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: colors.primaryPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    border: Border(top: BorderSide(color: colors.borderColor)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 14,
                            color: colors.primaryText,
                          ),
                          onSubmitted: _handleSubmitted,
                          decoration: InputDecoration(
                            hintText: 'Ask AI Career Assistant...',
                            hintStyle: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 14,
                              color: colors.subtitleText,
                            ),
                            filled: true,
                            fillColor: colors.inputFillColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: colors.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: colors.borderColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: colors.primaryPurple,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () => _handleSubmitted(_textController.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: colors.bottomNavBg,
            selectedItemColor: colors.primaryPurple,
            unselectedItemColor: colors.subtitleText,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: ['sans-serif'],
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: ['sans-serif'],
              fontWeight: FontWeight.w600,
            ),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalysisScreen()),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics_rounded),
                label: 'Analysis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({
    required this.message,
    required this.colors,
  });

  final ChatMessage message;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.chipBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 18,
                color: colors.primaryPurple,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? colors.primaryPurple
                    : colors.surfaceCard,
                border: isUser ? null : Border.all(color: colors.borderColor),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 14,
                  height: 1.4,
                  color: isUser ? Colors.white : colors.primaryText,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
