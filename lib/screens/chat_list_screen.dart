import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Personal', 'Groups'];
  
  // Demo data
  final List<ChatItem> _demoChats = [
    ChatItem(
      name: 'Rahul Sharma',
      lastMessage: 'Hey! How are you doing?',
      time: '2:30 PM',
      unread: 2,
      isOnline: true,
      avatar: 'RS',
    ),
    ChatItem(
      name: 'Priya Patel',
      lastMessage: 'See you tomorrow!',
      time: '1:15 PM',
      unread: 0,
      isOnline: false,
      avatar: 'PP',
    ),
    ChatItem(
      name: 'Tech Team',
      lastMessage: 'John: Meeting at 3 PM',
      time: '12:45 PM',
      unread: 5,
      isOnline: false,
      avatar: 'TT',
      isGroup: true,
    ),
    ChatItem(
      name: 'Mom',
      lastMessage: 'Don\'t forget to call me',
      time: '11:30 AM',
      unread: 1,
      isOnline: true,
      avatar: 'M',
    ),
  ];

  List<ChatItem> get _filteredChats {
    if (_selectedTab == 0) return _demoChats;
    if (_selectedTab == 1) return _demoChats.where((chat) => !chat.isGroup).toList();
    return _demoChats.where((chat) => chat.isGroup).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZingifyColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ZingifyColors.primary, ZingifyColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // App Header
                    Row(
                      children: [
                        const ZingifyLogo(size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Zingify',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Premium Messaging',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search chats...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tabs
            Container(
              color: ZingifyColors.surface,
              child: Row(
                children: _tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  final isSelected = _selectedTab == index;
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? ZingifyColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          tab,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? ZingifyColors.primary : ZingifyColors.onSurface.withOpacity(0.6),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Chat List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = _filteredChats[index];
                  return ChatListItem(chat: chat)
                      .animate()
                      .fadeIn(delay: (index * 100).ms, duration: 300.ms)
                      .slideX(begin: -0.1, duration: 300.ms);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ZingifyColors.primary, ZingifyColors.secondary],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: ZingifyColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('New chat feature coming soon!'),
                backgroundColor: ZingifyColors.primary,
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.chat, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;
  final String avatar;
  final bool isGroup;

  ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isOnline,
    required this.avatar,
    this.isGroup = false,
  });
}

class ChatListItem extends StatelessWidget {
  final ChatItem chat;

  const ChatListItem({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ZingifyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZingifyColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: chat.isGroup ? ZingifyColors.secondary : ZingifyColors.primary,
              child: Text(
                chat.avatar,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (chat.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: ZingifyColors.accent,
                    border: Border.all(color: ZingifyColors.surface, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chat.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: ZingifyColors.onSurface,
          ),
        ),
        subtitle: Text(
          chat.lastMessage,
          style: TextStyle(
            color: ZingifyColors.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              chat.time,
              style: TextStyle(
                color: ZingifyColors.onSurface.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            if (chat.unread > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ZingifyColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chat.unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening chat with ${chat.name}...'),
              backgroundColor: ZingifyColors.primary,
            ),
          );
        },
      ),
    );
  }
}
