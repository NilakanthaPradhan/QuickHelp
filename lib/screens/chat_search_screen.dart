import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  List<dynamic> _recentChats = [];
  bool _loading = false;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _fetchRecentChats();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searching = false;
        _users = [];
      });
    }
  }

  void _fetchRecentChats() async {
    setState(() => _loading = true);
    final chats = await ApiService.getRecentChats();
    if (mounted) {
      setState(() {
        _recentChats = chats;
        _loading = false;
      });
    }
  }

  void _search() async {
    if (_searchController.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _searching = true;
    });
    try {
      final users = await ApiService.searchUsers(_searchController.text.trim());
      if (mounted) {
        setState(() {
          _users = users;
          _loading = false;
        });
        if (users.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No users found')));
        }
      }
    } catch (e) {
      debugPrint('Search Exception: $e');
      if (mounted) {
        setState(() { _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Search Failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search user by name...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    if (_searching)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                          setState(() => _searching = false);
                        },
                      ),
                  ],
                ),
                if (!_searching) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/support'),
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Chat with Support'),
                    ),
                  ),
                ]
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_searching) {
      return ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user.fullName),
            subtitle: Text('@${user.username}'),
            trailing: const Icon(Icons.message),
            onTap: () => _openChat(user),
          );
        },
      );
    } else {
      if (_recentChats.isEmpty) {
        return const Center(
          child: Text('No recent chats. Search to start one!'),
        );
      }
      return ListView.builder(
        itemCount: _recentChats.length,
        itemBuilder: (context, index) {
          final chat = _recentChats[index];
          // Determine title (Full Name or Username)
          final displayName = chat['fullName'] ?? chat['username'] ?? 'Unknown';
          final lastMsg = chat['lastMessage'] ?? '';
          
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.history)),
            title: Text(displayName),
            subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
             onTap: () {
              // Construct a User object from the map
              final user = User(
                id: chat['id'],
                username: chat['username'] ?? '',
                fullName: chat['fullName'] ?? '',
                role: 'USER', // Default, doesn't matter for chat
                email: '', 
                phone: '', 
                address: '',
                 photoData: null
              );
              _openChat(user);
            },
          );
        },
      );
    }
  }

  void _openChat(User user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(receiver: user),
      ),
    );
    // Refresh recent chats when returning
    _fetchRecentChats();
  }
}
