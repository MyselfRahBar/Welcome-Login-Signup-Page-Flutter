import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NotifyApp());
}

/// Root app
class NotifyApp extends StatelessWidget {
  const NotifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FakeLoginPage(),
    );
  }
}

/// ===============
///  FAKE LOGIN
/// ===============
class FakeLoginPage extends StatefulWidget {
  const FakeLoginPage({super.key});

  @override
  State<FakeLoginPage> createState() => _FakeLoginPageState();
}

class _FakeLoginPageState extends State<FakeLoginPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _continue() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter name and phone')),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          currentUserName: name,
          currentUserPhone: phone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notify – Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Fake login (offline)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Your phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _continue,
              child: const Text('Continue'),
            ),
            const SizedBox(height: 8),
            const Text(
              'This is offline for now. Later we will replace with real phone OTP using Firebase.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============
///  MODELS
/// ===============
class Friend {
  Friend({
    required this.name,
    required this.phone,
    this.isFavorite = false,
    List<Message>? messages,
  }) : messages = messages ?? [];

  String name;
  String phone;
  bool isFavorite;
  List<Message> messages;
}

class Message {
  Message({
    required this.text,
    required this.isMe,
    required this.time,
  });

  String text;
  bool isMe; // true = sent by me, false = friend
  DateTime time;
}

/// ===============
///  HOME PAGE
/// ===============
class HomePage extends StatefulWidget {
  final String currentUserName;
  final String currentUserPhone;

  const HomePage({
    super.key,
    required this.currentUserName,
    required this.currentUserPhone,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Friend> _friends = [];

  void _addFriend(Friend f) {
    setState(() {
      _friends.add(f);
    });
  }

  void _toggleFavorite(Friend friend) {
    setState(() {
      friend.isFavorite = !friend.isFavorite;
    });
  }

  void _openAddFriend() async {
    final newFriend = await Navigator.of(context).push<Friend>(
      MaterialPageRoute(
        builder: (_) => const AddFriendPage(),
      ),
    );

    if (newFriend != null) {
      _addFriend(newFriend);
    }
  }

  void _openChat(Friend friend) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          currentUserName: widget.currentUserName,
          friend: friend,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _friends.where((f) => f.isFavorite).toList();
    final others = _friends.where((f) => !f.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notify – Friends'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddFriend,
        child: const Icon(Icons.person_add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: _friends.isEmpty
            ? const Center(
                child: Text(
                  'No friends yet.\nTap + to add by name & phone.\nLater this will be real users + notifications.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView(
                children: [
                  if (favorites.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Favorites',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ...favorites.map(
                      (f) => FriendTile(
                        friend: f,
                        onToggleFavorite: () => _toggleFavorite(f),
                        onOpenChat: () => _openChat(f),
                      ),
                    ),
                    const Divider(),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'All Friends',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  ...others.map(
                    (f) => FriendTile(
                      friend: f,
                      onToggleFavorite: () => _toggleFavorite(f),
                      onOpenChat: () => _openChat(f),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  final Friend friend;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenChat;

  const FriendTile({
    super.key,
    required this.friend,
    required this.onToggleFavorite,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onOpenChat,
        title: Text(friend.name),
        subtitle: Text(friend.phone),
        trailing: IconButton(
          icon: Icon(
            friend.isFavorite ? Icons.star : Icons.star_border,
          ),
          onPressed: onToggleFavorite,
        ),
      ),
    );
  }
}

/// ===============
///  ADD FRIEND
/// ===============
class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _save() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter name and phone')),
      );
      return;
    }

    final friend = Friend(name: name, phone: phone);
    Navigator.of(context).pop(friend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Friend name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Friend phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============
///  CHAT PAGE
/// ===============
class ChatPage extends StatefulWidget {
  final String currentUserName;
  final Friend friend;

  const ChatPage({
    super.key,
    required this.currentUserName,
    required this.friend,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      widget.friend.messages.add(
        Message(
          text: text,
          isMe: true,
          time: DateTime.now(),
        ),
      );
    });
    _messageController.clear();

    // In future: instead of just adding to list,
    // we will create Firestore document + send push notification.
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.friend.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friend.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.\nSend a 1-line message below.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final align = msg.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft;
                      final color =
                          msg.isMe ? Colors.blue[100] : Colors.grey[200];

                      return Align(
                        alignment: align,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg.text),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Type 1-line message…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}