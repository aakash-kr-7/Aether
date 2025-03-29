import 'package:flutter/material.dart';
import '../../services/chatbot_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();

  List<Map<String, dynamic>> messages = [];
  bool _isLoading = false;
  String? _selectedChatId;
  List<String> _chatSessions = [];

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  Future<void> _loadChatSessions() async {
    final snapshot = await FirebaseFirestore.instance.collection('chats').get();
    setState(() {
      _chatSessions = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _loadChatHistory(String chatId) async {
    final doc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    if (doc.exists) {
      setState(() {
        messages = (doc.data()?['messages'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _selectedChatId = chatId;
      });
    }
  }

  Future<void> _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"user": userMessage});
      messages.add({"bot": "Lily is thinking..."});
      _isLoading = true;
    });

    _controller.clear();

    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      String botResponse = await _chatbotService.getResponse(userMessage, _selectedChatId ?? '', userId);

      setState(() {
        messages.removeLast();
        messages.add({"bot": botResponse.isNotEmpty ? botResponse : "Hmm... I'm not sure how to respond to that."});
      });

      await _saveChat();
    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add({"bot": "Oops! Something went wrong."});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChat() async {
    if (_selectedChatId == null) {
      final newChat = await FirebaseFirestore.instance.collection('chats').add({"messages": messages});
      setState(() {
        _selectedChatId = newChat.id;
        _chatSessions.add(newChat.id);
      });
    } else {
      await FirebaseFirestore.instance.collection('chats').doc(_selectedChatId).update({"messages": messages});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lily - AI Chatbot", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        actions: [
          DropdownButton<String>(
            dropdownColor: Colors.blue[700],
            value: _selectedChatId,
            hint: Text("Chat History", style: TextStyle(color: Colors.white)),
            items: _chatSessions.map((chatId) {
              return DropdownMenuItem<String>(
                value: chatId,
                child: Text("Session: $chatId", style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) _loadChatHistory(value);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index].containsKey("user");
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[300] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      messages[index].values.first,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue[800]),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
