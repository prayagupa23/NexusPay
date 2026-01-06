
class RecipientHonorScore {
  int? id;
  String userId;
  String numberId; // phone number or UPI ID
  int honorScore;

  RecipientHonorScore({
    this.id,
    required this.userId,
    required this.numberId,
    this.honorScore = 50,
  });

  // For SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'number_id': numberId,
      'honor_score': honorScore,
    };
  }

  factory RecipientHonorScore.fromMap(Map<String, dynamic> map) {
    return RecipientHonorScore(
      id: map['id'],
      userId: map['user_id'],
      numberId: map['number_id'],
      honorScore: map['honor_score'],
    );
  }
}
