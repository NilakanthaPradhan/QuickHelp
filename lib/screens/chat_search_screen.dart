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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for people...',
                          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          filled: true,
                          fillColor: isDark ? theme.colorScheme.surfaceVariant : Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                        ),
                        onSubmitted: (_) => _search(),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    if (_searching)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                          setState(() => _searching = false);
                        },
                      )
                    else 
                      const SizedBox(width: 12),
                  ],
                ),
                if (!_searching) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/support'),
                      icon: const Icon(Icons.support_agent_rounded),
                      label: const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ]
              ],
            ),
          ),
          if (_loading) 
             LinearProgressIndicator(color: theme.colorScheme.primary, backgroundColor: theme.colorScheme.surface),
             
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              _searching ? 'Search Results' : 'Recent Conversations',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          
          Expanded(
            child: _buildList(theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme, bool isDark) {
    if (_searching) {
      if (_users.isEmpty && !_loading) {
         return Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
               const SizedBox(height: 16),
               Text('No users found', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
             ],
           )
         );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildItemCard(
            theme: theme,
            title: user.fullName,
            subtitle: '@${user.username}',
            icon: Icons.person_add_rounded,
            onTap: () => _openChat(user),
            isDark: isDark,
          );
        },
      );
    } else {
      if (_recentChats.isEmpty && !_loading) {
        return Center(
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(Icons.chat_bubble_outline_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
               const SizedBox(height: 16),
               Text('No recent chats', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
               const SizedBox(height: 8),
               Text('Search above to start a conversation', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4))),
             ],
           )
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _recentChats.length,
        itemBuilder: (context, index) {
          final chat = _recentChats[index];
          final displayName = chat['fullName'] ?? chat['username'] ?? 'Unknown';
          final lastMsg = chat['lastMessage'] ?? '';
          
          return _buildItemCard(
            theme: theme,
            title: displayName,
            subtitle: lastMsg,
            icon: Icons.history_rounded,
            trailingIcon: Icons.chevron_right_rounded,
            isDark: isDark,
            onTap: () {
              final user = User(
                id: chat['id'],
                username: chat['username'] ?? '',
                fullName: chat['fullName'] ?? '',
                role: 'USER', 
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
  
  Widget _buildItemCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    IconData? trailingIcon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: isDark ? Colors.white12 : Colors.transparent)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        trailing: trailingIcon != null ? Icon(trailingIcon, color: theme.colorScheme.primary.withOpacity(0.5)) : const Icon(Icons.chat_bubble_outline_rounded),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }

  void _openChat(User user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(receiver: user),
      ),
    );
    _fetchRecentChats();
  }
}
