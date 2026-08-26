import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../services/chat_service.dart';

class BouncingDotsTypingIndicator extends StatefulWidget {
  const BouncingDotsTypingIndicator({super.key, required this.color});
  final Color color;

  @override
  State<BouncingDotsTypingIndicator> createState() => _BouncingDotsTypingIndicatorState();
}

class _BouncingDotsTypingIndicatorState extends State<BouncingDotsTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final delay = index * 0.2;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = (_controller.value - delay) % 1.0;
            final bounce = math.sin(value * math.pi);
            final opacity = (bounce < 0 ? 0.3 : 0.3 + 0.7 * bounce).clamp(0.3, 1.0);
            final offset = (bounce < 0 ? 0.0 : -4.0 * bounce);

            return Transform.translate(
              offset: Offset(0, offset),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 4),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color _primaryColor = Color(0xFF54309C);
  static const Color _userBubbleColor = Color(0xFF54309C);

  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSending = false;

  TextStyle get _titleStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  TextStyle get _bubbleTextStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      );

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    _inputController.clear();
    setState(() => _isSending = true);
    _scrollToBottom();

    await _chatService.sendMessage(text);

    if (!mounted) return;
    setState(() => _isSending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF9D7BEE) : _primaryColor;
    final messages = _chatService.messages;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : _primaryColor,
        title: Text('CareerMate Assistant', style: _titleStyle),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => _buildBubble(messages[index], primaryColor),
                  ),
          ),
          if (_isSending) _buildTypingIndicator(primaryColor),
          _buildInputBar(primaryColor),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Ask me anything about your internships, scholarships, '
          'or your profile — I\'ll always use your latest info.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontFamilyFallback: const ['sans-serif'],
            fontSize: 14,
            color: isDark ? const Color(0xFF9A9AA6) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage message, Color primaryColor) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userBubble = isDark ? const Color(0xFF6B45BA) : _userBubbleColor;
    final aiBubble = Theme.of(context).cardColor;
    final borderColor = isDark ? const Color(0xFF2C2C35) : const Color(0xFFE8E1F5);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? userBubble : aiBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: borderColor),
        ),
        child: isUser
            ? Text(
                message.text,
                style: _bubbleTextStyle.copyWith(color: Colors.white),
              )
            : MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: _bubbleTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  listBullet: _bubbleTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  strong: _bubbleTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  h1: _bubbleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  h2: _bubbleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  h3: _bubbleTextStyle.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }

  Widget _buildTypingIndicator(Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aiBubble = Theme.of(context).cardColor;
    final borderColor = isDark ? const Color(0xFF2C2C35) : const Color(0xFFE8E1F5);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: aiBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: borderColor),
        ),
        child: BouncingDotsTypingIndicator(
          color: isDark ? const Color(0xFF9A9AA6) : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildInputBar(Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2C2C35) : const Color(0xFFE8E1F5);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onSubmitted: (_) => _handleSend(),
                decoration: InputDecoration(
                  hintText: 'Ask about internships, scholarships, your profile...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    color: Color(0xFF9A9AA6),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isSending ? null : _handleSend,
              icon: const Icon(Icons.send_rounded),
              color: primaryColor,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}