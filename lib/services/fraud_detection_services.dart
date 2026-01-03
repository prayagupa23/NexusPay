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
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
    );

    print(" Gemini initialized with gemini-1.5-flash");
  }

  Future<String> analyzeFraudRisk(String userInput) async {
    await _ensureInitialized();

    try {
      final prompt = '''
You are Fraud Guard AI, a cyber awareness bot helping Indian users stay safe online. Your role is to educate users about common scams and frauds, provide daily safety tips, and help them recognize suspicious messages or links.

User message: "$userInput"

Provide helpful, educational guidance about:
- Whether this is a common scam pattern (UPI fraud, KYC calls, job scams, electricity bill threats, etc.)
- What red flags to look for
- Clear, actionable advice on how to stay safe
- Daily safety tips when relevant

Be friendly, informative, and focus on user awareness and education. Keep responses conversational and helpful, under 5 sentences. Use emojis sparingly (🛡️ for safety, 🚨 for warnings).
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

