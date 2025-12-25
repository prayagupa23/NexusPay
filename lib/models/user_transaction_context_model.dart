class UserTransactionContextModel {
  final int userId;
  final String userUpiId;
  final double avgLast5Amount;
  final List<String> last5Receivers;
  final List<double> last5Amounts;
  final List<DateTime> last5Timestamps;
  final List<String> lastDeviceIds;
  final int transactionVelocity;
  final bool newDeviceFlag;
  final bool locationChangeFlag;
  final bool highAmountFlag;
  final int failedTxnCount;
  final DateTime? contextUpdatedAt;

  UserTransactionContextModel({
    required this.userId,
    required this.userUpiId,
    required this.avgLast5Amount,
    required this.last5Receivers,
    required this.last5Amounts,
    required this.last5Timestamps,
    required this.lastDeviceIds,
    required this.transactionVelocity,
    this.newDeviceFlag = false,
    this.locationChangeFlag = false,
    this.highAmountFlag = false,
    this.failedTxnCount = 0,
    this.contextUpdatedAt,
  });

  // Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_upi_id': userUpiId,
      'avg_last_5_amount': avgLast5Amount.toString(),
      'last_5_receivers': last5Receivers,
      'last_5_amounts': last5Amounts.map((a) => a.toString()).toList(),
      'last_5_timestamps': last5Timestamps.map((t) => t.toIso8601String()).toList(),
      'last_device_ids': lastDeviceIds,
      'transaction_velocity': transactionVelocity,
      'new_device_flag': newDeviceFlag,
      'location_change_flag': locationChangeFlag,
      'high_amount_flag': highAmountFlag,
      'failed_txn_count': failedTxnCount,
      if (contextUpdatedAt != null)
        'context_updated_at': contextUpdatedAt!.toIso8601String(),
    };
  }

  // Create from Map (from Supabase)
  factory UserTransactionContextModel.fromMap(Map<String, dynamic> map) {
    return UserTransactionContextModel(
      userId: map['user_id'] as int,
      userUpiId: map['user_upi_id'] as String,
      avgLast5Amount: map['avg_last_5_amount'] is String
          ? double.parse(map['avg_last_5_amount'] as String)
          : (map['avg_last_5_amount'] as num).toDouble(),
      last5Receivers: List<String>.from(map['last_5_receivers'] as List),
      last5Amounts: (map['last_5_amounts'] as List)
          .map((a) => a is String ? double.parse(a) : (a as num).toDouble())
          .toList(),
      last5Timestamps: (map['last_5_timestamps'] as List)
          .map((t) => DateTime.parse(t as String))
          .toList(),
      lastDeviceIds: List<String>.from(map['last_device_ids'] as List),
      transactionVelocity: map['transaction_velocity'] as int,
      newDeviceFlag: map['new_device_flag'] as bool? ?? false,
      locationChangeFlag: map['location_change_flag'] as bool? ?? false,
      highAmountFlag: map['high_amount_flag'] as bool? ?? false,
      failedTxnCount: map['failed_txn_count'] as int? ?? 0,
      contextUpdatedAt: map['context_updated_at'] != null
          ? DateTime.parse(map['context_updated_at'] as String)
          : null,
    );
  }
}

