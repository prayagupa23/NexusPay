import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  // Create a new user
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await _client
          .from('upi_user')
          .insert(user.toMap())
          .select()
          .single();

      return UserModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    }
  }

  // Check if UPI ID exists
  Future<bool> checkUpiIdExists(String upiId) async {
    try {
      final response = await _client
          .from('upi_user')
          .select('upi_id')
          .eq('upi_id', upiId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw 'Error checking UPI ID: ${e.toString()}';
    }
  }

  // Check if phone number exists
  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final response = await _client
          .from('upi_user')
          .select('phone_number')
          .eq('phone_number', phoneNumber)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw 'Error checking phone number: ${e.toString()}';
    }
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _client
          .from('upi_user')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw 'Error checking email: ${e.toString()}';
    }
  }

  // Check if bank account exists
  Future<bool> checkBankAccountExists(String accountNumber) async {
    try {
      final response = await _client
          .from('upi_user')
          .select('bank_account_number')
          .eq('bank_account_number', accountNumber)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw 'Error checking bank account: ${e.toString()}';
    }
  }

  // Check if Aadhaar exists
  Future<bool> checkAadhaarExists(String aadhaar) async {
    try {
      final response = await _client
          .from('upi_user')
          .select('aadhaar_number')
          .eq('aadhaar_number', aadhaar)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw 'Error checking Aadhaar: ${e.toString()}';
    }
  }

  // Get user by phone number (for login)
  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      final response = await _client
          .from('upi_user')
          .select()
          .eq('phone_number', phoneNumber)
          .maybeSingle();

      return response != null ? UserModel.fromMap(response) : null;
    } catch (e) {
      throw 'Error fetching user: ${e.toString()}';
    }
  }

  String _handleError(PostgrestException e) {
    // Handle specific database constraint errors
    if (e.code == '23505') {
      // Unique constraint violation
      if (e.message.contains('upi_id')) {
        return 'This UPI ID is already taken. Please choose another.';
      } else if (e.message.contains('phone_number')) {
        return 'This phone number is already registered.';
      } else if (e.message.contains('email')) {
        return 'This email is already registered.';
      } else if (e.message.contains('bank_account_number')) {
        return 'This bank account is already linked.';
      } else if (e.message.contains('aadhaar_number')) {
        return 'This Aadhaar number is already registered.';
      }
      return 'This information is already registered.';
    } else if (e.code == '23514') {
      // Check constraint violation
      return 'Invalid data. Please check your input.';
    }
    return e.message;
  }
}

