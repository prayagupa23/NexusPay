class LanguagePreference {
  final String code;
  final String name;
  final String flag;
  final String instruction;

  const LanguagePreference({
    required this.code,
    required this.name,
    required this.flag,
    required this.instruction,
  });

  static final List<LanguagePreference> supportedLanguages = [
    const LanguagePreference(
      code: 'en',
      name: 'English',
      flag: '🇬🇧',
      instruction: '',
    ),
    const LanguagePreference(
      code: 'mr',
      name: 'मराठी',
      flag: '🇮🇳',
      instruction: 'Give text in Marathi',
    ),
    const LanguagePreference(
      code: 'hi',
      name: 'हिंदी',
      flag: '🇮🇳',
      instruction: 'Give text in Hindi',
    ),
    const LanguagePreference(
      code: 'ta',
      name: 'தமிழ்',
      flag: '🇮🇳',
      instruction: 'Give text in Tamil',
    ),
    const LanguagePreference(
      code: 'te',
      name: 'తెలుగు',
      flag: '🇮🇳',
      instruction: 'Give text in Telugu',
    ),
    const LanguagePreference(
      code: 'kn',
      name: 'ಕನ್ನಡ',
      flag: '🇮🇳',
      instruction: 'Give text in Kannada',
    ),
    const LanguagePreference(
      code: 'ml',
      name: 'മലയാളം',
      flag: '🇮🇳',
      instruction: 'Give text in Malayalam',
    ),
    const LanguagePreference(
      code: 'bn',
      name: 'বাংলা',
      flag: '🇮🇳',
      instruction: 'Give text in Bengali',
    ),
    const LanguagePreference(
      code: 'gu',
      name: 'ગુજરાતી',
      flag: '🇮🇳',
      instruction: 'Give text in Gujarati',
    ),
  ];

  static LanguagePreference getDefault() => supportedLanguages.first;

  static LanguagePreference fromCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => getDefault(),
    );
  }
}
