import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../models/user_model.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;
  const ChatScreen({super.key, required this.receiver});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  Timer? _timer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    _fetchMessages();
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      _fetchMessages(refresh: true); 
    } else if (state == AppLifecycleState.paused) {
      _stopPolling();
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMessages(refresh: true);
    });
  }

  void _stopPolling() {
    _timer?.cancel();
  }

  void _fetchMessages({bool refresh = false}) async {
    try {
      final msgs = await ApiService.getChatHistory(widget.receiver.id);
      if (mounted) {
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
    } catch (e) {
      debugPrint("Error in chat poll: $e");
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
    
    final result = await ApiService.sendMessage(widget.receiver.id, text);
    
    if (mounted) {
      if (result != null) {
        setState(() {
           _messages.remove(tempMsg);
           _msgController.text = text; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Send Failed: $result'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        _fetchMessages(refresh: true);
      }
    }
  }

  String _simpleTime(String? isoString) {
     if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('h:mm a').format(dt); 
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<User?>(
      valueListenable: ApiService.userNotifier,
      builder: (context, currentUser, child) {
        if (currentUser == null) {
          return const Scaffold(body: Center(child: Text('Please log in to chat')));
        }
        
        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            elevation: 1,
            backgroundColor: theme.colorScheme.surface,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.receiver.fullName, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                    Text(
                      '@${widget.receiver.username}', 
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: _loading 
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)) 
                : _messages.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mark_chat_unread_rounded, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('Say hi to ${widget.receiver.fullName}! 👋', 
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 16)
                          ),
                        ]
                      )
                    )
                  : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      // FORCE STRING COMPARISON
                      final isMe = msg['senderId'].toString() == currentUser.id.toString();
                      final timestamp = _simpleTime(msg['timestamp']);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                                child: Text(widget.receiver.fullName[0].toUpperCase(), style: TextStyle(fontSize: 10, color: theme.colorScheme.secondary)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: isMe ? LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ) : null,
                                  color: isMe ? null : (isDark ? theme.colorScheme.surfaceVariant : Colors.grey[200]),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isMe ? theme.colorScheme.primary.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg['content'] ?? '',
                                      style: TextStyle(
                                        color: isMe ? Colors.white : theme.colorScheme.onSurface,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timestamp, 
                                      style: TextStyle(
                                        color: isMe ? Colors.white.withOpacity(0.7) : theme.colorScheme.onSurface.withOpacity(0.5),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
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
                  ),
              ),
              
              // Input Area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), 
                      blurRadius: 10, 
                      offset: const Offset(0, -4)
                    )
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? theme.colorScheme.surfaceVariant : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add, color: theme.colorScheme.primary),
                          onPressed: () {}, 
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            filled: true,
                            fillColor: isDark ? theme.colorScheme.surfaceVariant : Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
