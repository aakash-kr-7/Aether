import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<void> _saveChat() async {
    if (_selectedChatId == null) {
      final newDoc = await FirebaseFirestore.instance.collection('chats').add({
        'messages': messages,
      });
      setState(() {
        _selectedChatId = newDoc.id;
        _chatSessions.add(newDoc.id);
      });
    } else {
      await FirebaseFirestore.instance.collection('chats').doc(_selectedChatId).update({
        'messages': messages,
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
        _isLoading = false;
      });

      await _saveChat();
    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add({"bot": "Oops! Something went wrong."});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/images/lily_icon.png'),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Lily",
                      style: GoogleFonts.dancingScript(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.containsKey('user');
                    final message = msg.values.first;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blueAccent : const Color.fromARGB(255, 156, 230, 240),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isUser
                            ? Text(
                                message,
                                style: TextStyle(color: Colors.white),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundImage: AssetImage('assets/images/lily_icon.png'),
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      message,
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                        onSubmitted: (value) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
