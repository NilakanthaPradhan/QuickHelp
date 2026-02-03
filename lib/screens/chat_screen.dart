import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final messages = List.generate(6, (i) => {
          'name': i % 2 == 0 ? 'Support' : 'You',
          'msg': 'This is a sample message #${i + 1}',
        }).where((m) => _q.isEmpty || (m['msg'] as String).toLowerCase().contains(_q.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search messages'),
                      onChanged: (v) => setState(() => _q = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: messages.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final m = messages[i];
          final mine = m['name'] == 'You';
          return Row(
            mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!mine)
                CircleAvatar(child: Text((m['name'] as String)[0])),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mine ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(m['msg'] as String, style: TextStyle(color: mine ? Colors.white : null)),
                ),
              ),
            ],
          );
        },
      ),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: SafeArea(
        child: AnimatedPadding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Type a message', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent (dummy)'))), child: const Icon(Icons.send)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
