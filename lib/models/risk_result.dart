enum RiskVerdict {
  allow,
  warning,
  highAlert,
}

enum RiskLevel {
  low,
  medium,
  high,
}

class RiskResult {
  final double riskScore;
  final RiskLevel riskLevel;
  final RiskVerdict verdict;
  final List<String> reasons;
  final double mlProbability;
  final int heuristicScore;

  RiskResult({
    required this.riskScore,
    required this.riskLevel,
    required this.verdict,
    required this.reasons,
    required this.mlProbability,
    required this.heuristicScore,
  });

  /// Factory constructor to parse backend JSON safely
  factory RiskResult.fromJson(Map<String, dynamic> json) {
    return RiskResult(
      riskScore: (json['risk_score'] as num).toDouble(),
      mlProbability: (json['ml_probability'] as num).toDouble(),
      heuristicScore: (json['heuristic_score'] as num).toInt(),
      reasons: List<String>.from(json['reasons']),
      verdict: _parseVerdict(json['verdict']),
      riskLevel: _parseRiskLevel(json['risk_level']),
    );
  }

  // -------------------------
  // Parsing helpers
  // -------------------------

  static RiskVerdict _parseVerdict(String value) {
    switch (value.toLowerCase()) {
      case 'allow':
        return RiskVerdict.allow;
      case 'warning':
        return RiskVerdict.warning;
      case 'high alert':
        return RiskVerdict.highAlert;
      default:
        throw Exception('Unknown verdict: $value');
    }
  }

  static RiskLevel _parseRiskLevel(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('low')) return RiskLevel.low;
    if (lower.contains('medium')) return RiskLevel.medium;
    if (lower.contains('high')) return RiskLevel.high;
    throw Exception('Unknown risk level: $value');
  }

  // -------------------------
  // UI-friendly labels
  // -------------------------

  /// Display label for verdict (for UI only)
  String get verdictLabel {
    switch (verdict) {
      case RiskVerdict.allow:
        return 'Allow';
      case RiskVerdict.warning:
        return 'Warning';
      case RiskVerdict.highAlert:
        return 'High Alert';
    }
  }

  /// Short display label for risk level (Low / Medium / High)
  String get riskLevelLabel {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }

  /// Optional: user-friendly summary sentence
  String get summaryText {
    switch (verdict) {
      case RiskVerdict.allow:
        return 'This transaction looks safe.';
      case RiskVerdict.warning:
        return 'This transaction looks unusual.';
      case RiskVerdict.highAlert:
        return 'This transaction is high risk.';
    }
  }
}
