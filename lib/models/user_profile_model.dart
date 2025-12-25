class UserProfileModel {
  final int? profileId;
  final int userId;
  final String upiId;
  final String fullName;
  final String city;
  final String bankName;
  final int honorScore;
  final DateTime? profileCreatedAt;
  final DateTime? lastUpdatedAt;

  UserProfileModel({
    this.profileId,
    required this.userId,
    required this.upiId,
    required this.fullName,
    required this.city,
    required this.bankName,
    this.honorScore = 100,
    this.profileCreatedAt,
    this.lastUpdatedAt,
  });

  // Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      if (profileId != null) 'profile_id': profileId,
      'user_id': userId,
      'upi_id': upiId,
      'full_name': fullName,
      'city': city,
      'bank_name': bankName,
      'honor_score': honorScore,
      if (profileCreatedAt != null)
        'profile_created_at': profileCreatedAt!.toIso8601String(),
      if (lastUpdatedAt != null)
        'last_updated_at': lastUpdatedAt!.toIso8601String(),
    };
  }

  // Create from Map (from Supabase)
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      profileId: map['profile_id'] as int?,
      userId: map['user_id'] as int,
      upiId: map['upi_id'] as String,
      fullName: map['full_name'] as String,
      city: map['city'] as String,
      bankName: map['bank_name'] as String,
      honorScore: map['honor_score'] as int? ?? 100,
      profileCreatedAt: map['profile_created_at'] != null
          ? DateTime.parse(map['profile_created_at'] as String)
          : null,
      lastUpdatedAt: map['last_updated_at'] != null
          ? DateTime.parse(map['last_updated_at'] as String)
          : null,
    );
  }

  // Validation
  static bool isValidHonorScore(int score) {
    return score >= 0 && score <= 100;
  }
}

