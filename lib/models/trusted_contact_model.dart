class TrustedContact {
  final int userId;
  final String upiId;
  final String fullName;
  final int transactionCount;
  final DateTime lastTransactionDate;

  TrustedContact({
    required this.userId,
    required this.upiId,
    required this.fullName,
    required this.transactionCount,
    required this.lastTransactionDate,
  });

  factory TrustedContact.fromMap(Map<String, dynamic> map) {
    return TrustedContact(
      userId: map['user_id'] as int,
      upiId: map['upi_id'] as String,
      fullName: map['full_name'] as String? ?? 'Unknown',
      transactionCount: (map['transaction_count'] as num).toInt(),
      lastTransactionDate: DateTime.parse(map['last_transaction_date'].toString()),
    );
  }
}
