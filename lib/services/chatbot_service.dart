import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ChatbotService {
  final String _apiKey = "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";
  final String _apiUrl = "https://openrouter.ai/api/v1/chat/completions";
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
          "model": "openai/gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": "You are Lily, a warm and cheerful support chatbot. Always provide kind, supportive, and uplifting responses."
            },
            {
              "role": "user",
              "content": userMessage,
            }
          ],
          "max_tokens": 150,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String botResponse = jsonResponse["choices"]?[0]["message"]["content"]?.trim() ?? "Hmm... I'm not sure how to respond to that.";

        // Ensure chatId exists
        chatId ??= generateChatId(userId);
        DocumentReference chatRef = _firestore.collection("chats").doc(chatId);

        // Ensure chat document exists
        await chatRef.set({
          "userId": userId,
          "messages": FieldValue.arrayUnion([]),
        }, SetOptions(merge: true));

        // Use DateTime.now() for timestamps
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

        // Store messages in Firestore under the correct chat document
        await chatRef.update({
          "messages": FieldValue.arrayUnion([userMessageData, botMessageData]),
        });

        return botResponse;
      } else {
        print("⚠️ OpenRouter API Error: ${response.body}");
        return "Sorry, I couldn't process that right now. Please try again!";
      }
    } catch (e) {
      print("❌ Error: $e");
      return "Error: Unable to connect to AI.";
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
