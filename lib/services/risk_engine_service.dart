//risk_engine_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:heisenbug/models/risk_result.dart';

class RiskEngineService {
  static const String _baseUrl = 'http://51.20.65.223:5000';

  static Future<RiskResult> evaluateRisk({
    required int userId,
    required String transactionId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/evaluate_risk_score');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'transaction_id': transactionId}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return RiskResult.fromJson(json);
      } else {
        throw Exception(
          'Risk engine failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      // Fallback to default risk assessment when API fails
      return RiskResult(
        riskScore: 50.0,
        riskLevel: RiskLevel.medium,
        verdict: RiskVerdict.warning,
        reasons: ['Unable to verify transaction risk due to network issues'],
        mlProbability: 0.5,
        heuristicScore: 50,
      );
    }
  }
}
