import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _msgScrollCtrl = ScrollController();
  bool _otherTyping = false;

  final List<_Conversation> _conversations = [
    _Conversation(
      id: '1',
      name: 'Alice Johnson',
      lastMessage: 'See you at 3 PM!',
      avatarColor: Colors.pink,
      messages: [
        _Message(text: 'Hey there! 👋', isMe: false, time: DateTime.now()),
        _Message(text: 'Hi Alice, how are you?', isMe: true, time: DateTime.now()),
        _Message(text: 'All good! Meeting at 3 PM?', isMe: false, time: DateTime.now()),
        _Message(text: 'Yep, see you then.', isMe: true, time: DateTime.now()),
      ],
    ),
    _Conversation(
      id: '2',
      name: 'Design Team',
      lastMessage: 'Pushed new components.',
      avatarColor: Colors.blue,
      messages: [
        _Message(text: 'Uploaded latest Figma file.', isMe: false, time: DateTime.now()),
        _Message(text: 'Looks great 🎨', isMe: true, time: DateTime.now()),
      ],
    ),
    _Conversation(
      id: '3',
      name: 'Support',
      lastMessage: 'Ticket #142 resolved.',
      avatarColor: Colors.green,
      messages: [
        _Message(text: 'Issue with login fixed.', isMe: false, time: DateTime.now()),
        _Message(text: 'Thanks for the quick turnaround!', isMe: true, time: DateTime.now()),
      ],
    ),
  ];

  String _selectedId = '1';

  _Conversation get _selectedConv =>
      _conversations.firstWhere((c) => c.id == _selectedId);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = Divider(
      height: 1,
      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
    );

    return Row(
      children: [
        // Conversations list
        SizedBox(
          width: 300,
          child: Column(
            children: [
              _buildSearchBar(isDark),
              divider,
              Expanded(child: _buildConversationList(isDark)),
            ],
          ),
        ),

        // Vertical divider
        Container(width: 1, color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),

        // Chat area
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildChatHeader(isDark),
              divider,
              Expanded(child: _buildMessages(isDark)),
              if (_otherTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const _TypingDots(),
                    ],
                  ),
                ),
              divider,
              _buildInputBar(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Search chats...',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildConversationList(bool isDark) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final items = _conversations.where((c) =>
        c.name.toLowerCase().contains(query) || c.lastMessage.toLowerCase().contains(query));

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final conv = items.elementAt(index);
        final selected = conv.id == _selectedId;
        return Material(
          color: selected
              ? AppTheme.primaryColor.withValues(alpha: 0.08)
              : Colors.transparent,
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: CircleAvatar(
              backgroundColor: conv.avatarColor.withValues(alpha: 0.15),
              child: Icon(Icons.person_rounded, color: conv.avatarColor),
            ),
            title: Text(
              conv.name,
              style: AppTheme.customTextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              conv.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.customTextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
            trailing: conv.unreadCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${conv.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  )
                : null,
            onTap: () => setState(() {
              _selectedId = conv.id;
              conv.unreadCount = 0;
            }),
          ),
        );
      },
    );
  }

  Widget _buildChatHeader(bool isDark) {
    final conv = _selectedConv;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: conv.avatarColor.withValues(alpha: 0.15),
            child: Icon(Icons.person_rounded, color: conv.avatarColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conv.name,
                  style: AppTheme.customTextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Online',
                  style: AppTheme.customTextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () {},
            tooltip: 'Voice Call',
          ),
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () {},
            tooltip: 'Video Call',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(bool isDark) {
    final msgs = _selectedConv.messages;
    return ListView.builder(
      controller: _msgScrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: msgs.length,
      itemBuilder: (context, index) {
        final m = msgs[index];
        final align = m.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
        final bubbleColor = m.isMe
            ? AppTheme.primaryColor
            : (isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05));
        final textColor = m.isMe ? Colors.white : (isDark ? Colors.white : Colors.black87);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(m.text, style: TextStyle(color: textColor, fontSize: 14)),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(context, m.time),
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Attach',
          ),
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type a message',
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded),
            color: AppTheme.primaryColor,
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _selectedConv.messages.add(
        _Message(text: text, isMe: true, time: DateTime.now()),
      );
      _selectedConv.lastMessage = text;
      _msgCtrl.clear();
    });
    _scrollToBottom();
    _simulateOtherTypingAndReply();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_msgScrollCtrl.hasClients) {
        _msgScrollCtrl.animateTo(
          _msgScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _simulateOtherTypingAndReply() async {
    setState(() => _otherTyping = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _otherTyping = false);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      final reply = 'Got it!';
      _selectedConv.messages.add(
        _Message(text: reply, isMe: false, time: DateTime.now()),
      );
      _selectedConv.lastMessage = reply;
      _selectedConv.unreadCount += 1;
    });
    _scrollToBottom();
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final t = TimeOfDay.fromDateTime(dt);
    two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }
}

class _Conversation {
  final String id;
  final String name;
  String lastMessage;
  final Color avatarColor;
  final List<_Message> messages;
  int unreadCount = 0;

  _Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatarColor,
    required this.messages,
  });
}

class _Message {
  final String text;
  final bool isMe;
  final DateTime time;

  _Message({required this.text, required this.isMe, required this.time});
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotBase = isDark ? Colors.white70 : Colors.black54;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value; // 0..1
        final o1 = _opacityAt(t, 0.0);
        final o2 = _opacityAt(t, 0.2);
        final o3 = _opacityAt(t, 0.4);
        return Row(
          children: [
            _dot(dotBase.withValues(alpha: o1)),
            const SizedBox(width: 4),
            _dot(dotBase.withValues(alpha: o2)),
            const SizedBox(width: 4),
            _dot(dotBase.withValues(alpha: o3)),
          ],
        );
      },
    );
  }

  double _opacityAt(double t, double phase) {
    final v = (t + phase) % 1.0;
    final tri = v < 0.5 ? (v * 2) : (2 - v * 2);
    return 0.3 + 0.7 * tri; // 0.3..1.0
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
