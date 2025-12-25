import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';
import '../models/transaction_model.dart';
import '../models/user_transaction_context_model.dart';

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

  // Get user by UPI ID
  Future<UserModel?> getUserByUpiId(String upiId) async {
    try {
      final response = await _client
          .from('upi_user')
          .select()
          .eq('upi_id', upiId)
          .maybeSingle();

      return response != null ? UserModel.fromMap(response) : null;
    } catch (e) {
      throw 'Error fetching user by UPI ID: ${e.toString()}';
    }
  }

  // Create user profile
  Future<UserProfileModel> createUserProfile(UserProfileModel profile) async {
    try {
      final response = await _client
          .from('user_profile')
          .insert(profile.toMap())
          .select()
          .single();

      return UserProfileModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user profile by user_id
  Future<UserProfileModel?> getUserProfile(int userId) async {
    try {
      final response = await _client
          .from('user_profile')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response != null ? UserProfileModel.fromMap(response) : null;
    } catch (e) {
      throw 'Error fetching user profile: ${e.toString()}';
    }
  }

  // Get user profile by phone number (convenience method)
  Future<UserProfileModel?> getUserProfileByPhone(String phoneNumber) async {
    try {
      // First get the user
      final user = await getUserByPhone(phoneNumber);
      if (user == null || user.userId == null) return null;

      // Then get the profile
      return await getUserProfile(user.userId!);
    } catch (e) {
      throw 'Error fetching user profile: ${e.toString()}';
    }
  }

  // Update user profile
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      if (profile.profileId == null) {
        throw 'Profile ID is required for update';
      }

      final updateData = profile.toMap();
      // Remove profile_id and timestamps from update (they're auto-managed)
      updateData.remove('profile_id');
      updateData.remove('profile_created_at');
      updateData['last_updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('user_profile')
          .update(updateData)
          .eq('profile_id', profile.profileId!)
          .select()
          .single();

      return UserProfileModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    }
  }

  // Update honor score
  Future<UserProfileModel> updateHonorScore(int userId, int newScore) async {
    try {
      if (!UserProfileModel.isValidHonorScore(newScore)) {
        throw 'Honor score must be between 0 and 100';
      }

      final response = await _client
          .from('user_profile')
          .update({
            'honor_score': newScore,
            'last_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select()
          .single();

      return UserProfileModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    }
  }

  // Update bank balance
  Future<UserProfileModel> updateBankBalance(int userId, double newBalance) async {
    try {
      final response = await _client
          .from('user_profile')
          .update({
            'bank_balance': newBalance.toString(),
            'last_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select()
          .single();

      return UserProfileModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    }
  }

  // Get all users (for trusted contacts)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client
          .from('upi_user')
          .select()
          .order('full_name');

      return (response as List)
          .map((item) => UserModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error fetching users: ${e.toString()}';
    }
  }

  // Create transaction
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final response = await _client
          .from('transactions')
          .insert(transaction.toMap())
          .select()
          .single();

      return TransactionModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user transactions
  Future<List<TransactionModel>> getUserTransactions(int userId, {int? limit}) async {
    try {
      var query = _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((item) => TransactionModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error fetching transactions: ${e.toString()}';
    }
  }

  // Get or create user transaction context
  Future<UserTransactionContextModel> getOrCreateUserContext(int userId, String userUpiId) async {
    try {
      final response = await _client
          .from('user_transaction_context')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return UserTransactionContextModel.fromMap(response);
      } else {
        // Create new context
        final newContext = UserTransactionContextModel(
          userId: userId,
          userUpiId: userUpiId,
          avgLast5Amount: 0,
          last5Receivers: [],
          last5Amounts: [],
          last5Timestamps: [],
          lastDeviceIds: [],
          transactionVelocity: 0,
        );

        await _client
            .from('user_transaction_context')
            .insert(newContext.toMap());

        return newContext;
      }
    } catch (e) {
      throw 'Error fetching user context: ${e.toString()}';
    }
  }

  // Update user transaction context
  Future<UserTransactionContextModel> updateUserContext(
    UserTransactionContextModel context,
  ) async {
    try {
      final updateData = context.toMap();
      updateData['context_updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('user_transaction_context')
          .update(updateData)
          .eq('user_id', context.userId)
          .select()
          .single();

      return UserTransactionContextModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    }
  }

  // Process payment transaction
  Future<TransactionModel> processPayment({
    required int userId,
    required String receiverUpi,
    required double amount,
    required String deviceId,
    String? location,
  }) async {
    try {
      // Get user to check balance and get UPI ID
      final userResponse = await _client
          .from('upi_user')
          .select()
          .eq('user_id', userId)
          .single();

      final user = UserModel.fromMap(userResponse);

      // Get user profile to check balance
      final profileResponse = await _client
          .from('user_profile')
          .select()
          .eq('user_id', userId)
          .single();

      final profile = UserProfileModel.fromMap(profileResponse);
      final currentBalance = profile.bankBalance ?? 0.0;

      if (currentBalance < amount) {
        throw 'Insufficient balance';
      }

      // Generate UTR reference
      final utrReference = TransactionModel.generateUtrReference();

      // Create transaction
      final transaction = TransactionModel(
        userId: userId,
        receiverUpi: receiverUpi,
        amount: amount,
        deviceId: deviceId,
        location: location,
        status: 'SUCCESS',
        utrReference: utrReference,
      );

      final createdTransaction = await createTransaction(transaction);

      // Update sender's bank balance (deduct)
      final newBalance = currentBalance - amount;
      await updateBankBalance(userId, newBalance);

      // Update receiver's bank balance (add)
      final receiver = await getUserByUpiId(receiverUpi);
      if (receiver != null && receiver.userId != null) {
        try {
          // Get receiver's current profile
          final receiverProfileResponse = await _client
              .from('user_profile')
              .select()
              .eq('user_id', receiver.userId!)
              .maybeSingle();

          if (receiverProfileResponse != null) {
            final receiverProfile = UserProfileModel.fromMap(receiverProfileResponse);
            final receiverCurrentBalance = receiverProfile.bankBalance ?? 0.0;
            final receiverNewBalance = receiverCurrentBalance + amount;
            await updateBankBalance(receiver.userId!, receiverNewBalance);
          }
        } catch (e) {
          // Log error but don't fail the transaction
          debugPrint('Error updating receiver balance: $e');
        }
      }

      // Update user transaction context
      await _updateTransactionContext(
        userId: userId,
        userUpiId: user.upiId,
        receiverUpi: receiverUpi,
        amount: amount,
        deviceId: deviceId,
        location: location,
      );

      return createdTransaction;
    } on PostgrestException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _updateTransactionContext({
    required int userId,
    required String userUpiId,
    required String receiverUpi,
    required double amount,
    required String deviceId,
    String? location,
  }) async {
    try {
      final context = await getOrCreateUserContext(userId, userUpiId);

      // Update last 5 transactions (keep only last 5)
      final newReceivers = [receiverUpi, ...context.last5Receivers].take(5).toList();
      final newAmounts = [amount, ...context.last5Amounts].take(5).toList();
      final newTimestamps = [DateTime.now(), ...context.last5Timestamps].take(5).toList();
      final newDeviceIds = [deviceId, ...context.lastDeviceIds].take(5).toList();

      // Calculate average
      final avgAmount = newAmounts.isNotEmpty
          ? newAmounts.reduce((a, b) => a + b) / newAmounts.length
          : amount;

      // Check flags (simplified logic)
      final newDeviceFlag = !context.lastDeviceIds.contains(deviceId);
      final highAmountFlag = amount > (avgAmount * 2); // More than 2x average

      final updatedContext = UserTransactionContextModel(
        userId: userId,
        userUpiId: userUpiId,
        avgLast5Amount: avgAmount,
        last5Receivers: newReceivers,
        last5Amounts: newAmounts,
        last5Timestamps: newTimestamps,
        lastDeviceIds: newDeviceIds,
        transactionVelocity: context.transactionVelocity + 1,
        newDeviceFlag: newDeviceFlag,
        locationChangeFlag: context.locationChangeFlag, // Can be enhanced
        highAmountFlag: highAmountFlag,
        failedTxnCount: context.failedTxnCount,
      );

      await updateUserContext(updatedContext);
    } catch (e) {
      // Log error but don't fail transaction
      debugPrint('Error updating transaction context: $e');
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

