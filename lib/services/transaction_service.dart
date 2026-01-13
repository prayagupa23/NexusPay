import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class TransactionService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final Uuid _uuid = const Uuid();

  static Future<String> createPendingTransaction({
    required int userId,
    required String receiverUpi,
    required String amount,
    required String deviceId,
    required String senderDevice,
  }) async {
    // Clean and validate the amount
    String cleanAmount = amount
        .replaceAll(RegExp(r'[^0-9.]'), '') // Remove all non-numeric characters except decimal point
        .replaceAll(RegExp(r'\.+'), '.') // Replace multiple decimal points with a single one
        .replaceFirst(RegExp(r'^\.'), '0.') // Add leading zero if amount starts with decimal point
        .replaceAll(RegExp(r'\.'), 'x') // Temporarily replace decimal point
        .replaceAll(RegExp(r'\D'), '') // Remove any remaining non-digits
        .replaceFirst('x', '.'); // Put back the first decimal point

    // If no decimal point, add .00 for consistency
    if (!cleanAmount.contains('.')) {
      cleanAmount = '$cleanAmount.00';
    }

    // Parse the cleaned amount to double
    final parsedAmount = double.tryParse(cleanAmount) ?? 0.0;

    // Generate unique UTR reference
    final utrReference = 'UTR${_uuid.v4().substring(0, 8).toUpperCase()}';

    try {
      final response = await _supabase
          .from('transactions')
          .insert({
            'user_id': userId,
            'receiver_upi': receiverUpi,
            'amount': parsedAmount,
            'device_id': deviceId,
            'receiver_device': senderDevice,
            'status': 'PENDING',
            'location': 'Mumbai',
            'utr_reference': utrReference, // Unique UTR reference
            'note': '',
            'is_trusted_contact': false,
            'is_verified_contact': false,
            'risk_acknowledged': false,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error creating pending transaction: $e');
      rethrow; // Re-throw to be handled by the caller
    }
  }
}
