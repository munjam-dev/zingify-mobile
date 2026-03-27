import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZingifyColors.background,
      appBar: AppBar(
        backgroundColor: ZingifyColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: ZingifyColors.onSurface),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: ZingifyColors.primary,
              child: const Text(
                'RS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rahul Sharma',
                  style: TextStyle(
                    color: ZingifyColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: ZingifyColors.accent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call, color: ZingifyColors.onSurface),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call, color: ZingifyColors.onSurface),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: ZingifyColors.onSurface),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/chat_bg.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.1,
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final isMe = index % 2 == 0;
                  return MessageBubble(
                    isMe: isMe,
                    message: isMe 
                        ? 'Hey! How are you doing? This is a test message from Zingify!'
                        : 'I\'m doing great! Zingify looks amazing with the glassmorphism UI!',
                    time: '2:${30 + index}0 PM',
                  ).animate().fadeIn(delay: (index * 100).ms, duration: 300.ms);
                },
              ),
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ZingifyColors.surface,
              border: Border(
                top: BorderSide(color: ZingifyColors.border),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.emoji_emotions, color: ZingifyColors.primary),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file, color: ZingifyColors.primary),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ZingifyColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: ZingifyColors.border),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: ZingifyColors.onSurface.withOpacity(0.5)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ZingifyColors.primary, ZingifyColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message sent!'),
                          backgroundColor: ZingifyColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
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

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: ZingifyColors.primary,
              child: const Text(
                'RS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [ZingifyColors.primary, ZingifyColors.secondary],
                          )
                        : null,
                    color: isMe ? null : ZingifyColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: isMe
                        ? null
                        : Border.all(color: ZingifyColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : ZingifyColors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: ZingifyColors.onSurface.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: ZingifyColors.secondary,
              child: const Text(
                'ME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
