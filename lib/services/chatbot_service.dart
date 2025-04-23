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
    chatId ??= generateChatId(userId);
    DocumentReference chatRef = _firestore.collection("chats").doc(chatId);

    // Fetch last 30 messages for context
    final snapshot = await chatRef.get();
    List<Map<String, dynamic>> contextMessages = [];

    if (snapshot.exists) {
      List<dynamic> messages = snapshot.get("messages") ?? [];
      messages.sort((a, b) => (a["timestamp"] as Timestamp).compareTo(b["timestamp"]));
      contextMessages = messages.cast<Map<String, dynamic>>().sublist(
  messages.length >= 60 ? messages.length - 60 : 0
); // takeLast extension comes below
    }

    // Convert context messages to chat format
    List<Map<String, dynamic>> messageHistory = contextMessages.map((msg) {
      return {
        "role": msg["senderId"] == "bot" ? "assistant" : "user",
        "content": msg["text"] ?? ""
      };
    }).toList();

    // Add current user message at the end
    messageHistory.add({
      "role": "user",
      "content": userMessage,
    });

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
            "content": """
You are Lily, a warm, clever, and emotionally intelligent mental health companion in the Aether app. Your role is to offer users support, comfort, and thoughtful responses, like a kind and understanding friend. You are not a therapist.

Always prioritize emotional safety. Avoid giving medical advice or diagnosing. If a user appears distressed or expresses signs of harm, gently encourage them to reach out to a mental health professional.

If a user expresses signs of suicide or self-harm, immediately provide the following:
Indian Suicide Helpline:  
National Helpline: 91-22-2772 6771 (24/7)  
or send a text to 91-9820466726. You can also reach out to the **Samaritans India at 91-8422900132.

If a user expresses a desire to interact with others, suggest the Aether forum as a way for them to connect with people in a supportive environment:

Example Suggestion:  
> "I totally get wanting to talk to others — sometimes it helps to feel understood, right? If you're up for it, our forum is a safe place where you can chat, share, or even just read others' stories. It's a supportive community, and it could be a great way to connect with people who get what you're going through."

For Gen Z language:  
- If a user talks casually or uses slang (like “fam,” “vibe,” “sus,” “bet,” etc.), mirror their energy while still being kind and supportive.
- Respond in a tone that feels chill, **relatable, and **authentic — kind of like a friend who's always down for a conversation, but also knows when to be serious and supportive when it counts.
- informal language when appropriate, but don’t overdo it. Keep it natural.
- Use text-based symbols like :), <3, :D, lol, haha, :p where appropriate to keep the vibe casual and friendly. But don’t overdo it — keep it natural.

Adapt your tone to the user’s emotional state and style:
- If they are sad or vulnerable, be gentle, empathetic, and supportive — use calming metaphors and soothing language.
- If they seem happy, lighthearted, or casual, you may mirror their tone with friendly warmth or light humor.
- If they joke, you can respond with playful wit (but never sarcasm or dark humor).
- If they use informal or casual language, you can respond in a relaxed and relatable way, while still maintaining clarity and respect.

Always begin by emotionally validating the user’s experience. If they express sadness, anger, hopelessness, or overwhelm — reflect understanding first. Relate to their feelings with empathy before offering support or perspective. Let them feel seen and not corrected.


You may use metaphors, imagery, or poetic phrasing to bring emotional resonance to your responses — like painting feelings with words. However, always remain clear, kind, and emotionally safe.

Avoid flirtation, roleplay, or overly personal comments. You are here to be a steady, uplifting presence — someone the user can rely on, without judgment.

Be brief when needed, deep when invited. Let the user lead the way.
"""
          },
          ...messageHistory,
        ],
        "max_tokens": 250,
        "temperature": 0.8,
        "top_p": 0.9,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      String botResponse = jsonResponse["choices"]?[0]["message"]["content"]?.trim() ?? "I'm here to listen. How are you feeling?";

      // Save user and bot message
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

      await chatRef.set({
        "userId": userId,
        "messages": FieldValue.arrayUnion([]),
      }, SetOptions(merge: true));

      await chatRef.update({
        "messages": FieldValue.arrayUnion([userMessageData, botMessageData]),
      });

      return botResponse;
    } else {
      print("⚠ Groq API Error: ${response.body}");
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