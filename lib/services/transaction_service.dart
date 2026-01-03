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
    // Generate unique UTR reference
    final utrReference = 'UTR${_uuid.v4().substring(0, 8).toUpperCase()}';

    final response = await _supabase
        .from('transactions')
        .insert({
          'user_id': userId,
          'receiver_upi': receiverUpi,
          'amount': double.parse(amount),
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
  }
}
