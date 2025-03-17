import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String _apiKey = "AIzaSyAx3IYOaj4W6kee6J9QdrYR7Q-XlpbkUIY"; // 🔹 Replace this with your new key
  final String _apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateText";

  Future<String> getResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse("$_apiUrl?key=$_apiKey"), // ✅ Uses the API key properly
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "prompt": {"text": userMessage}, // ✅ Correct request format for Gemini AI
          "max_tokens": 150,
        }),
      );

      print("🔹 API Response: ${response.body}"); // ✅ Debugging Line

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("🔹 Parsed Response: $jsonResponse"); // ✅ Debugging Line
        return jsonResponse["candidates"]?[0]["output"]?.trim() ?? "Hmm... I'm not sure how to respond to that.";
      } else {
        print("⚠️ Gemini API Error: ${response.body}");
        return "Sorry, I couldn't process that right now. Please try again!";
      }
    } catch (e) {
      print("❌ Error: $e");
      return "Error: Unable to connect to AI.";
    }
  }
}
