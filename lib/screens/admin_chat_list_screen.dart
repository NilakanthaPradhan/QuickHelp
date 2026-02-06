import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  List<dynamic> _recentChats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentChats();
  }

  void _fetchRecentChats() async {
    final chats = await ApiService.getRecentChats();
    if (mounted) {
      setState(() {
        _recentChats = chats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _fetchRecentChats();
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recentChats.isEmpty
              ? const Center(child: Text('No messages yet.'))
              : ListView.builder(
                  itemCount: _recentChats.length,
                  itemBuilder: (context, index) {
                    final chat = _recentChats[index];
                    // chat object: {id, fullName, username, lastMessage, timestamp}
                    final otherUser = User(
                      id: chat['id'],
                      username: chat['username'],
                      fullName: chat['fullName'],
                      email: '', // Not needed for list
                      phone: '',
                      address: '',
                      role: 'USER', 
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(otherUser.fullName[0].toUpperCase()),
                      ),
                      title: Text(otherUser.fullName),
                      subtitle: Text(
                        chat['lastMessage'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(receiver: otherUser),
                          ),
                        );
                        _fetchRecentChats(); // Refresh on return
                      },
                    );
                  },
                ),
    );
  }
}
