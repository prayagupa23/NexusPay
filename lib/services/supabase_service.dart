import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_device_name/flutter_device_name.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';
import '../models/transaction_model.dart';
import '../models/user_transaction_context_model.dart';
import 'phone_verification_service.dart';

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

  // Get user profile by UPI ID (for displaying honor scores)
  Future<UserProfileModel?> getUserProfileByUpiId(String upiId) async {
    try {
      final response = await _client
          .from('user_profile')
          .select('*, upi_user!inner(upi_id)')
          .eq('upi_user.upi_id', upiId)
          .maybeSingle();
          
      return response != null ? UserProfileModel.fromMap(response) : null;
    } catch (e) {
      debugPrint('Error fetching user profile by UPI ID: $e');
      return null;
    }
  }
  
  /// Updates a user's profile with the provided updates
  /// If [updates] is provided, it will do a partial update with the given fields
  /// If [profile] is provided, it will update all fields of the profile
  Future<UserProfileModel> updateUserProfile({
    String? userId,
    Map<String, dynamic>? updates,
    UserProfileModel? profile,
  }) async {
    try {
      if (updates != null && userId != null) {
        // Partial update with specific fields
        final response = await _client
            .from('user_profile')
            .update(updates)
            .eq('user_id', userId)
            .select()
            .single();
        return UserProfileModel.fromMap(response);
      } else if (profile != null) {
        // Full profile update
        final response = await _client
            .from('user_profile')
            .update(profile.toMap())
            .eq('user_id', profile.userId)
            .select()
            .single();
        return UserProfileModel.fromMap(response);
      } else {
        throw ArgumentError('Either userId with updates or profile must be provided');
      }
    } on PostgrestException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
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
  Future<UserProfileModel> updateBankBalance(
    int userId,
    double newBalance,
  ) async {
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
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
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
  Future<List<TransactionModel>> getUserTransactions(
    int userId, {
    int? limit,
  }) async {
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
  Future<UserTransactionContextModel> getOrCreateUserContext(
    int userId,
    String userUpiId,
  ) async {
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
      // Fetch device name silently
      String receiverDevice = 'Unknown Device';
      try {
        receiverDevice = await DeviceName().getName() ?? 'Unknown Device';
      } catch (e) {
        debugPrint('Error fetching device name: $e');
        // Continue with default device name
      }

      // Set default location to Mumbai if not provided
      location = location ?? 'Mumbai';

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

      // Check if receiver is a trusted contact
      bool isTrustedContact = false;
      bool isVerifiedContact = false;

      // Get receiver user
      final receiver = await getUserByUpiId(receiverUpi);

      if (receiver != null) {
        // Check if receiver is in trusted contacts (exists in our system)
        final allUsers = await getAllUsers();
        final currentUserPhone = user.phoneNumber;

        // Check if we've transacted with this user before
        final previousTransactions = await getUserTransactions(userId);
        isTrustedContact = previousTransactions.any(
          (tx) => tx.receiverUpi == receiverUpi,
        );

        // Verify phone number using Numlookup API
        try {
          final phoneVerificationService = PhoneVerificationService();
          final phoneNumber = '+91${receiver.phoneNumber}';
          final verificationResult = await phoneVerificationService
              .validatePhoneNumber(phoneNumber);

          if (verificationResult != null && verificationResult.valid) {
            isVerifiedContact = true;
            debugPrint(
              'Contact verified: ${receiver.fullName} - ${verificationResult.location}',
            );
          }
        } catch (e) {
          debugPrint('Phone verification error: $e');
          // Continue without verification if API fails
        }
      }

      // Generate UTR reference
      final utrReference = TransactionModel.generateUtrReference();

      // Create transaction with verification status and device info
      final transaction = TransactionModel(
        userId: userId,
        receiverUpi: receiverUpi,
        amount: amount,
        deviceId: deviceId,
        receiverDevice: receiverDevice,
        location: location,
        status: 'SUCCESS',
        utrReference: utrReference,
        createdAt: DateTime.now().toUtc().add(
          const Duration(hours: 5, minutes: 30),
        ), // IST timezone
        isTrustedContact: isTrustedContact,
        isVerifiedContact: isVerifiedContact,
      );

      final createdTransaction = await createTransaction(transaction);

      // Update sender's bank balance (deduct)
      final newBalance = currentBalance - amount;
      await updateBankBalance(userId, newBalance);

      // Update receiver's bank balance (add)
      if (receiver == null || receiver.userId == null) {
        debugPrint('Warning: Receiver with UPI ID $receiverUpi not found');
      } else {
        try {
          // Get receiver's current profile
          final receiverProfileResponse = await _client
              .from('user_profile')
              .select()
              .eq('user_id', receiver.userId!)
              .maybeSingle();

          if (receiverProfileResponse == null) {
            // Receiver profile doesn't exist, create it with initial balance
            debugPrint('Receiver profile not found, creating new profile');
            final newReceiverProfile = UserProfileModel(
              userId: receiver.userId!,
              upiId: receiver.upiId,
              fullName: receiver.fullName,
              city: receiver.city,
              bankName: receiver.bankName,
              honorScore: 100,
              bankBalance: amount, // Initial balance is the received amount
            );
            await createUserProfile(newReceiverProfile);
          } else {
            // Update existing receiver profile balance
            final receiverProfile = UserProfileModel.fromMap(
              receiverProfileResponse,
            );
            final receiverCurrentBalance = receiverProfile.bankBalance ?? 0.0;
            final receiverNewBalance = receiverCurrentBalance + amount;
            await updateBankBalance(receiver.userId!, receiverNewBalance);
            debugPrint(
              'Updated receiver balance: $receiverCurrentBalance + $amount = $receiverNewBalance',
            );
          }
        } catch (e) {
          // Log error but don't fail the transaction (sender already deducted)
          debugPrint('Error updating receiver balance: $e');
          // Don't rethrow - transaction is already recorded and sender balance updated
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
      final newReceivers = [
        receiverUpi,
        ...context.last5Receivers,
      ].take(5).toList();
      final newAmounts = [amount, ...context.last5Amounts].take(5).toList();
      final newTimestamps = [
        DateTime.now(),
        ...context.last5Timestamps,
      ].take(5).toList();
      final newDeviceIds = [
        deviceId,
        ...context.lastDeviceIds,
      ].take(5).toList();

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

  Future<void> syncRecipientHonorScores(String userId, List<Map<String, dynamic>> contacts) async {
    try {
      // First, get existing scores from Supabase to minimize updates
      final existingScores = await _client
          .from('recipient_honor_scores')
          .select('number_id, honor_score')
          .eq('user_id', userId);

      final existingScoresMap = <String, int>{};
      for (final score in existingScores) {
        existingScoresMap[score['number_id'] as String] = score['honor_score'] as int;
      }

      // Prepare batch operations
      final batch = <Map<String, dynamic>>[];
      
      for (final contact in contacts) {
        final numberId = contact['number_id'] as String?;
        if (numberId == null || numberId.isEmpty) continue;

        final existingScore = existingScoresMap[numberId];
        final honorScore = contact['honor_score'] as int? ?? 100;
        
        if (existingScore != null) {
          // Only update if score has changed
          if (existingScore != honorScore) {
            batch.add({
              'user_id': userId,
              'number_id': numberId,
              'honor_score': honorScore,
            });
          }
        } else {
          // New contact, add to batch
          batch.add({
            'user_id': userId,
            'number_id': numberId,
            'honor_score': honorScore,
          });
        }
      }

      // Process batch operations
      if (batch.isNotEmpty) {
        await _client
            .from('recipient_honor_scores')
            .upsert(
              batch,
              onConflict: 'user_id,number_id',
              ignoreDuplicates: false,
            )
            .select();
      }

      debugPrint('Successfully synced ${batch.length} contacts to Supabase');
    } catch (e) {
      debugPrint('Error syncing recipient honor scores: $e');
      rethrow;
    }
  }

  String _handleError(PostgrestException e) {
    debugPrint('Supabase Error: ${e.message}');
    debugPrint('Details: ${e.details}');
    debugPrint('Hint: ${e.hint}');
    debugPrint('Code: ${e.code}');
    
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
