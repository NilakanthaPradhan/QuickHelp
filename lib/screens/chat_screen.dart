import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this for formatting
import '../models/user_model.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;
  const ChatScreen({super.key, required this.receiver});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  Timer? _timer;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchMessages(refresh: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchMessages({bool refresh = false}) async {
    final msgs = await ApiService.getChatHistory(widget.receiver.id);
    if (mounted) {
      // CRITICAL FIX: If msgs is null (network error), DO NOT clear existing messages.
      if (msgs == null) {
         if (!refresh && _loading) setState(() => _loading = false); 
         return; 
      }

      if (!refresh || msgs.length != _messages.length) {
         setState(() {
          _messages = msgs;
          _loading = false;
        });
        if (!refresh || _shouldAutoScroll()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    }
  }

  bool _shouldAutoScroll() {
    if (!_scrollController.hasClients) return true;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return (maxScroll - currentScroll) < 200; 
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ApiService.currentUser;
    if (currentUser == null) return;

    // OPTIMISTIC UPDATE: Show message immediately
    final tempMsg = {
      'senderId': currentUser.id,
      'receiverId': widget.receiver.id,
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.add(tempMsg);
      _msgController.clear();
    });
    _scrollToBottom();
    
    // Send to backend
    // Send to backend
    final result = await ApiService.sendMessage(widget.receiver.id, text);
    
    if (mounted) {
      if (result != null) {
        // If failed, remove the temp message and show error
        setState(() {
           _messages.remove(tempMsg);
           _msgController.text = text; // Restore text
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Send Failed: $result'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        // Success: Refresh to get the real message ID/timestamp from server
        _fetchMessages(refresh: true);
      }
    }
  }

  String _formatTimestamp(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('h:mm a').format(dt); // Requires intl package, or manual
    } catch (e) {
      return '';
    }
  }
  
  // Manual formatter if intl not available
  String _simpleTime(String? isoString) {
     if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      String hour = dt.hour > 12 ? '${dt.hour - 12}' : '${dt.hour == 0 ? 12 : dt.hour}';
      String minute = dt.minute.toString().padLeft(2, '0');
      String period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<User?>(
      valueListenable: ApiService.userNotifier,
      builder: (context, currentUser, child) {
        if (currentUser == null) {
          return const Scaffold(body: Center(child: Text('Please log in to chat')));
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.receiver.fullName, style: const TextStyle(fontSize: 16)),
                    Text('@${widget.receiver.username}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: _loading 
                ? const Center(child: CircularProgressIndicator()) 
                : _messages.isEmpty 
                  ? Center(child: Text('Say hi to ${widget.receiver.fullName}! 👋', style: const TextStyle(color: Colors.grey)))
                  : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['senderId'] == currentUser.id;
                      final timestamp = _simpleTime(msg['timestamp']);

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['content'] ?? '',
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timestamp, 
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.black45,
                                  fontSize: 10
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _send,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
