import 'package:uuid/uuid.dart';

class TransactionModel {
  final String? id;
  final int userId;
  final String receiverUpi;
  final double amount;
  final String deviceId;
  final String? location;
  final String status; // 'SUCCESS', 'PENDING', 'CANCELLED'
  final String? utrReference;
  final DateTime? createdAt;
  final bool? isTrustedContact; // Whether the receiver is a trusted contact
  final bool? isVerifiedContact; // Whether the contact was verified via phone API

  TransactionModel({
    this.id,
    required this.userId,
    required this.receiverUpi,
    required this.amount,
    required this.deviceId,
    this.location,
    required this.status,
    this.utrReference,
    this.createdAt,
    this.isTrustedContact,
    this.isVerifiedContact,
  });

  // Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'receiver_upi': receiverUpi,
      'amount': amount.toString(),
      'device_id': deviceId,
      if (location != null) 'location': location,
      'status': status,
      if (utrReference != null) 'utr_reference': utrReference,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (isTrustedContact != null) 'is_trusted_contact': isTrustedContact,
      if (isVerifiedContact != null) 'is_verified_contact': isVerifiedContact,
    };
  }

  // Create from Map (from Supabase)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String?,
      userId: map['user_id'] as int,
      receiverUpi: map['receiver_upi'] as String,
      amount: map['amount'] is String
          ? double.parse(map['amount'] as String)
          : (map['amount'] as num).toDouble(),
      deviceId: map['device_id'] as String,
      location: map['location'] as String?,
      status: map['status'] as String,
      utrReference: map['utr_reference'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      isTrustedContact: map['is_trusted_contact'] as bool?,
      isVerifiedContact: map['is_verified_contact'] as bool?,
    );
  }

  // Generate UTR Reference
  static String generateUtrReference() {
    return 'UTR${DateTime.now().millisecondsSinceEpoch}${const Uuid().v4().substring(0, 8).toUpperCase()}';
  }
}

