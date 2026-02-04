import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  final List<Map<String, dynamic>> _contacts = const [
    {'name': 'Support Team', 'role': 'Help & Support', 'image': 'https://i.pravatar.cc/150?u=support'},
    {'name': 'Ramesh Kumar', 'role': 'Plumber', 'image': 'https://i.pravatar.cc/150?u=ramesh'},
    {'name': 'Sunita Devi', 'role': 'Maid Services', 'image': 'https://i.pravatar.cc/150?u=sunita'},
    {'name': 'House Owner', 'role': 'Property Manager', 'image': 'https://i.pravatar.cc/150?u=owner'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView.separated(
        itemCount: _contacts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final c = _contacts[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(c['image'] as String),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
            title: Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(c['role'] as String),
            trailing: const Text('12:30 PM', style: TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatDetailScreen(contact: c))),
          );
        },
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> contact;
  const ChatDetailScreen({super.key, required this.contact});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    // simple dummy initial messages for context
    if (_messages.isEmpty) {
      _messages.add('Hello! How can I help you today?');
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.contact['image'] as String),
              radius: 16,
            ),
            const SizedBox(width: 10),
            Text(widget.contact['name'] as String, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final isMe = i % 2 != 0; // dummy logic: odd messages are 'me'
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? ThemeService.instance.seedColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                        bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                      ),
                    ),
                    child: Text(
                      _messages[i],
                      style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))]),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    elevation: 0,
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        setState(() {
                          _messages.add(_controller.text.trim());
                          _controller.clear();
                        });
                      }
                    },
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
