import 'package:flutter/material.dart';
import 'package:heisenbug/services/supabase_service.dart';
import 'package:heisenbug/models/user_profile_model.dart';
import 'dart:async';

class HonorScoreService {
  final SupabaseService _supabaseService;
  
  HonorScoreService(this._supabaseService);

  // Constants
  static const int _firstPaymentBonus = 15;
  static const int _successfulPaymentIncrement = 5;
  static const int _paymentConfirmationIncrement = 5;
  static const int _paymentAbortPenalty = -10;
  static const int _paymentFailurePenalty = -5;
  static const int _suspiciousMarkPenalty = -30;
  static const int _lateNightPenalty = -5;
  static const int _highAmountPenalty = -5;
  
  static const double _highAmountThreshold = 5000.0;
  static const int _lateNightStartHour = 0;  // 12 AM
  static const int _lateNightEndHour = 5;     // 5 AM
  
  // Thresholds for restrictions
  static const int _blockPaymentsThreshold = 30;
  static const int _removeFromTrustedThreshold = 50;
  static const int _warningThreshold = 70;

  /// Updates the honor score based on transaction result and behavioral factors
  /// Returns the new honor score and any restrictions that apply
  /// Tracks payment processing state
  final Map<String, Timer> _pendingPayments = {};
  
  /// Updates the honor score based on payment status and behavior
  /// Returns a Future that completes when all updates are done
  Future<Map<String, dynamic>> updateHonorScore({
    required String recipientUpiId,
    required String transactionId,
    required bool isFirstPayment,
    required bool isSuccessful,
    bool isReversed = false,
    bool isAborted = false,
    bool isBankError = false,
    bool isMarkedSuspicious = false,
    required double amount,
    required DateTime transactionTime,
    Duration confirmationWindow = const Duration(minutes: 5),
  }) async {
    final scoreUpdate = <String, dynamic>{};
    int scoreChange = 0;
    final restrictions = <String>[];
    
    // Get current score
    final currentProfile = await _supabaseService.getUserProfileByUpiId(recipientUpiId);
    if (currentProfile == null) {
      throw Exception('Recipient profile not found');
    }
    
    int currentScore = currentProfile.honorScore;
    
    // Check for high amount transaction (₹5000+)
    if (amount > _highAmountThreshold) {
      scoreChange += _highAmountPenalty;
      scoreUpdate['highAmountPenalty'] = _highAmountPenalty;
    }
    
    // Check for late night transaction (12 AM - 4 AM IST)
    final istHour = transactionTime.toUtc().add(const Duration(hours: 5, minutes: 30)).hour;
    if (istHour >= 0 && istHour < 4) {
      scoreChange += _lateNightPenalty;
      scoreUpdate['lateNightPenalty'] = _lateNightPenalty;
    }
    
    // Handle payment status
    if (isSuccessful) {
      // First payment bonus
      if (isFirstPayment) {
        scoreChange += _firstPaymentBonus;
        scoreUpdate['firstPaymentBonus'] = _firstPaymentBonus;
      } else {
        scoreChange += _successfulPaymentIncrement;
        scoreUpdate['successfulPayment'] = _successfulPaymentIncrement;
      }
      
      // Schedule confirmation check
      _scheduleConfirmationCheck(
        transactionId: transactionId,
        recipientUpiId: recipientUpiId,
        currentScore: currentScore + scoreChange,
        confirmationWindow: confirmationWindow,
      );
      
    } else if (isAborted) {
      scoreChange += _paymentAbortPenalty;
      scoreUpdate['abortPenalty'] = _paymentAbortPenalty;
      
    } else if (isBankError) {
      scoreChange += _paymentFailurePenalty;
      scoreUpdate['bankErrorPenalty'] = _paymentFailurePenalty;
    }
    
    // Apply suspicious mark penalty if needed
    if (isMarkedSuspicious) {
      scoreChange += _suspiciousMarkPenalty;
      scoreUpdate['suspiciousMarkPenalty'] = _suspiciousMarkPenalty;
    }
    
    // Calculate new score (0-100 range)
    int newScore = (currentScore + scoreChange).clamp(0, 100);
    scoreUpdate['immediateScoreChange'] = scoreChange;
    scoreUpdate['newImmediateScore'] = newScore;
    
    // Determine restrictions based on new score
    if (newScore < _blockPaymentsThreshold) {
      restrictions.add('block_payments');
    } else if (newScore < _removeFromTrustedThreshold) {
      restrictions.add('remove_from_trusted');
    } else if (newScore < _warningThreshold) {
      restrictions.add('show_warning');
    }
    
    // Update the score in Supabase
    await _supabaseService.updateUserProfile(
      userId: currentProfile.userId.toString(),
      updates: {'honor_score': newScore},
    );
    
    // Return detailed score update information
    final result = {
      'transactionId': transactionId,
      'recipientUpiId': recipientUpiId,
      'previousScore': currentScore,
      'newScore': newScore,
      'scoreChange': scoreChange,
      'restrictions': restrictions,
      'updates': scoreUpdate,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    debugPrint('Honor score updated: $result');
    return result;
  }
  
  /// Schedules a check for payment confirmation after the specified window
  void _scheduleConfirmationCheck({
    required String transactionId,
    required String recipientUpiId,
    required int currentScore,
    required Duration confirmationWindow,
  }) {
    // Cancel any existing timer for this transaction
    _pendingPayments[transactionId]?.cancel();
    
    // Schedule new confirmation check
    _pendingPayments[transactionId] = Timer(confirmationWindow, () async {
      try {
        // In a real app, you would verify with your payment processor
        // that the transaction was not reversed
        final isConfirmed = await _verifyTransactionConfirmation(transactionId);
        
        if (isConfirmed) {
          final newScore = (currentScore + _paymentConfirmationIncrement).clamp(0, 100);
          
          // Update the score with confirmation bonus
          await _supabaseService.updateUserProfile(
            userId: (await _supabaseService.getUserProfileByUpiId(recipientUpiId))!.userId.toString(),
            updates: {'honor_score': newScore},
          );
          
          debugPrint('Applied confirmation bonus to $recipientUpiId. New score: $newScore');
        }
      } catch (e) {
        debugPrint('Error processing confirmation for $transactionId: $e');
      } finally {
        _pendingPayments.remove(transactionId);
      }
    });
  }
  
  /// Verifies with the payment processor if a transaction was confirmed
  /// This is a placeholder - implement actual verification logic here
  Future<bool> _verifyTransactionConfirmation(String transactionId) async {
    // TODO: Implement actual transaction verification
    // For now, we'll assume all transactions are confirmed
    return true;
  }
  
  /// Gets the restrictions that apply to a user based on their current honor score
  List<String> getRestrictionsForScore(int score) {
    if (score < _blockPaymentsThreshold) {
      return ['block_payments'];
    } else if (score < _removeFromTrustedThreshold) {
      return ['remove_from_trusted'];
    } else if (score < _warningThreshold) {
      return ['show_warning'];
    }
    return [];
  }
  
  /// Cancels any pending confirmation checks when the service is disposed
  void dispose() {
    for (final timer in _pendingPayments.values) {
      timer.cancel();
    }
    _pendingPayments.clear();
  }
  
  /// Checks if a payment is allowed based on the recipient's honor score
  Future<Map<String, dynamic>> checkPaymentAllowed(String recipientUpiId) async {
    final profile = await _supabaseService.getUserProfileByUpiId(recipientUpiId);
    final score = profile?.honorScore ?? 100;
    final restrictions = getRestrictionsForScore(score);
    
    return {
      'allowed': !restrictions.contains('block_payments'),
      'requiresWarning': restrictions.contains('show_warning'),
      'shouldRemoveFromTrusted': restrictions.contains('remove_from_trusted'),
      'currentScore': score,
    };
  }
}
