import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_profile_model.dart';
import '../models/transaction_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'chat_screen.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  late final SupabaseService _supabaseService;
  UserProfileModel? _userProfile;
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('logged_in_phone');

      if (phoneNumber != null) {
        final user = await _supabaseService.getUserByPhone(phoneNumber);
        if (user != null && user.userId != null) {
          final profile = await _supabaseService.getUserProfile(user.userId!);
          final transactions = await _supabaseService.getUserTransactions(
            user.userId!,
            limit: 5,
          );

          if (mounted) {
            setState(() {
              _userProfile = profile;
              _transactions = transactions;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading money screen data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshBalance() async {
    setState(() => _isLoading = true);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshBalance,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(context),
                      const SizedBox(height: 32),
                      _buildBalanceCard(context, isDark),
                      const SizedBox(height: 32),
                      _buildCheckBalanceButton(context, isDark),
                      const SizedBox(height: 40),
                      _buildTransactionHistory(context, isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Money',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryText(context),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your wallet & transactions',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.primaryText(context),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDark) {
    final balance = _userProfile?.bankBalance ?? 0.0;
    final formattedBalance = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    ).format(balance);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primaryBlue.withOpacity(0.15),
                  AppColors.primaryBlue.withOpacity(0.05),
                ]
              : [
                  AppColors.primaryBlue.withOpacity(0.1),
                  AppColors.primaryBlue.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText(context),
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: AppColors.secondaryText(context),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _balanceVisible ? formattedBalance : '₹••••••',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText(context),
              letterSpacing: -1.5,
            ),
          ),
          if (_userProfile != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  size: 16,
                  color: AppColors.secondaryText(context),
                ),
                const SizedBox(width: 8),
                Text(
                  _userProfile!.bankName,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckBalanceButton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _refreshBalance,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh_rounded, size: 22),
              const SizedBox(width: 12),
              Text(
                'Check Bank Balance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context, bool isDark) {
    if (_transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: AppColors.mutedText(context),
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your transaction history will appear here',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._transactions.map((transaction) => _buildTransactionItem(
              context,
              transaction,
              isDark,
            )),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionModel transaction,
    bool isDark,
  ) {
    final isSuccess = transaction.status == 'SUCCESS';
    final receiverName = transaction.receiverUpi.split('@').first;
    final formattedDate = transaction.createdAt != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.createdAt!)
        : 'Date unknown';
    final formattedAmount = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    ).format(transaction.amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondarySurface(context).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSuccess
                  ? AppColors.successGreen.withOpacity(0.1)
                  : AppColors.warningYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: isSuccess ? AppColors.successGreen : AppColors.warningYellow,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiverName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-$formattedAmount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? AppColors.successGreen.withOpacity(0.1)
                      : AppColors.warningYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSuccess
                        ? AppColors.successGreen
                        : AppColors.warningYellow,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

