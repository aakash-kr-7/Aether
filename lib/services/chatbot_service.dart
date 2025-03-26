import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String _apiKey = "AIzaSyAx3IYOaj4W6kee6J9QdrYR7Q-XlpbkUIY";
  final String _apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent";

  Future<String> getResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse("$_apiUrl?key=$_apiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {"parts": [{"text": userMessage}]}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse["candidates"]?[0]["content"]?["parts"]?[0]["text"]?.trim() ?? "I'm not sure how to respond to that.";
      } else {
        return "Sorry, I couldn't process that right now. Please try again!";
      }
    } catch (e) {
      return "Error: Unable to connect to AI.";
    }
  }
}
