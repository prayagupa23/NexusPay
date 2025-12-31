import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class FraudDetectionService {
  GenerativeModel? _model;

  Future<void> _ensureInitialized() async {
    if (_model != null) return;

    await dotenv.load(fileName: ".env");

    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("GEMINI_API_KEY missing");
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    print("✅ Gemini initialized with gemini-1.5-flash");
  }

  Future<String> analyzeFraudRisk(String userInput) async {
    await _ensureInitialized();

    try {
      final prompt = '''
You are FraudGuard AI, a cyber security assistant for Indian users.

User message: "$userInput"

Analyze scam or fraud risk.
Mention:
- Risk level (Safe / Suspicious / Dangerous)
- Red flags
- Clear advice

Focus on Indian scams like UPI fraud, KYC calls, job scams, electricity threats.
Keep response under 4 sentences.
''';

      final response =
      await _model!.generateContent([Content.text(prompt)]);

      return response.text?.trim() ??
          "I couldn't analyze this. Please try again.";
    } catch (e) {
      print("❌ Gemini error: $e");
      return "AI service error. Please try again.";
    }
  }
}

