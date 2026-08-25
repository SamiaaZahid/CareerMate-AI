import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  Future<String> getResponse(String prompt) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) return "Error: API Key is missing!";

      
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final response = await model.generateContent([Content.text(prompt)]);
      
      return response.text ?? "I didn't understand this, please ask again.";
    } catch (e) {
      return "Network Error: $e";
    }
  }
}