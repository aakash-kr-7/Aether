import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ChatbotService {
  final String _apiKey = "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"; // Replace with your Groq API key
  final String _apiUrl = "https://api.groq.com/openai/v1/chat/completions";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  String generateChatId(String userId) {
    return "${userId}_${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<String> getResponse(String userMessage, String userId, String? chatId) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama3-8b-8192",
          "messages": [
            {
              "role": "system",
              "content": "You are Lily, a warm, clever, and empathetic mental health companion on the Aether app. Your goal is to make users feel safe, heard, and supported. Be thoughtful, clear, and professional. Avoid flirtatious or inappropriate language. You are a kind, understanding friend who offers support through conversations, reflecting emotional depth while maintaining healthy boundaries."
            },
            {
              "role": "user",
              "content": userMessage,
            }
          ],
          "max_tokens": 250,
          "temperature": 0.8,
          "top_p": 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String botResponse = jsonResponse["choices"]?[0]["message"]["content"]?.trim() ?? "I'm here to listen. How are you feeling?";

        chatId ??= generateChatId(userId);
        DocumentReference chatRef = _firestore.collection("chats").doc(chatId);

        await chatRef.set({
          "userId": userId,
          "messages": FieldValue.arrayUnion([]),
        }, SetOptions(merge: true));

        Map<String, dynamic> userMessageData = {
          "messageId": _uuid.v4(),
          "senderId": userId,
          "senderName": "User",
          "text": userMessage,
          "timestamp": DateTime.now(),
        };

        Map<String, dynamic> botMessageData = {
          "messageId": _uuid.v4(),
          "senderId": "bot",
          "senderName": "Lily",
          "text": botResponse,
          "timestamp": DateTime.now(),
        };

        await chatRef.update({
          "messages": FieldValue.arrayUnion([userMessageData, botMessageData]),
        });

        return botResponse;
      } else {
        print("⚠️ Groq API Error: ${response.body}");
        return "I'm here for you, but I'm having trouble responding right now. Please try again soon.";
      }
    } catch (e) {
      print("❌ Error: $e");
      return "Error: Unable to connect to Lily.";
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory(String chatId) async {
    DocumentSnapshot snapshot = await _firestore.collection("chats").doc(chatId).get();

    if (snapshot.exists) {
      List<dynamic> messages = snapshot.get("messages") ?? [];
      return messages.cast<Map<String, dynamic>>()..sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));
    }
    return [];
  }
}
