import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'pin_entry_screen.dart';
import 'package:heisenbug/models/risk_result.dart';
import 'package:heisenbug/services/risk_engine_service.dart';
import 'package:heisenbug/core/user_session.dart';
import 'package:heisenbug/widgets/risk_warning_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';

class AccountSelectionScreen extends StatefulWidget {
  //for risk score engine
  final int userId;
  final String transactionId;

  final String name;
  final String upiId;
  final String amount;

  const AccountSelectionScreen({
    super.key,
    required this.userId,
    required this.transactionId,
    required this.name,
    required this.upiId,
    required this.amount,
  });

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {


  // CRASH PROTECTION: Defined locally so it's never null during build
  bool _isCheckingRisk = false;
  bool _isLoading = true;
  static const Color primaryBlue = Color(0xFF2563EB);
  static const List<Color> avatarColors = [
    primaryBlue,
    Color(0xFF4F46E5),
    Color(0xFF0891B2),
    Color(0xFF7C3AED),
  ];

  late SupabaseService _supabaseService;
  List<Map<String, String>> _accounts = [];
  late Map<String, String> _selectedAccount;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadUserAccounts();
  }

  Future<void> _loadUserAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('logged_in_phone');
      
      if (phoneNumber == null) {
        throw 'No active session found';
      }

      final user = await _supabaseService.getUserByPhone(phoneNumber);
      
      if (user != null && user.bankName.isNotEmpty && user.bankAccountNumber.isNotEmpty) {
        // Format the last 4 digits of the account number
        final lastFourDigits = user.bankAccountNumber.length > 4 
            ? user.bankAccountNumber.substring(user.bankAccountNumber.length - 4)
            : user.bankAccountNumber;
            
        // Create a single account entry from the user's data
        setState(() {
          _accounts = [
            {
              'name': user.bankName,
              'shortName': _getBankShortName(user.bankName),
              'accNo': '•••• $lastFourDigits',
              'color': '0xFF2563EB', // Default color
            }
          ];
          _selectedAccount = _accounts.first;
          _isLoading = false;
        });
      } else {
        throw 'No bank account found for this user';
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint('Error loading user accounts: $e');
    }
  }

  String _getBankShortName(String bankName) {
    // Extract the first word or abbreviation from the bank name
    final words = bankName.split(' ');
    if (words.isEmpty) return 'BANK';
    
    // If the first word is a common prefix like 'The', take the next word
    final firstWord = words.first.toLowerCase();
    if (firstWord == 'the' || firstWord == 'bank' || firstWord == 'of') {
      return words.length > 1 ? words[1].substring(0, 2).toUpperCase() : 'BNK';
    }
    
    // Otherwise take the first 3-4 characters of the first word
    return words.first.length > 3 
        ? words.first.substring(0, 4).toUpperCase()
        : words.first.toUpperCase();
  }

  Color _getAvatarColor() {
    // Fallback protection for empty name
    if (widget.name.isEmpty) return avatarColors.first;
    final int hash = widget.name.toLowerCase().hashCode;
    return avatarColors[hash.abs() % avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              _buildTrustedAvatar(avatarColor),
                              const SizedBox(height: 32),
                              _buildTransactionSummary(),
                            ],
                          ),
                        ),
            ),
            _isLoading ? const SizedBox.shrink() : _buildBottomDrawer(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText(context), size: 20),
          ),
          Text(
            "CONFIRM PAYMENT",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText(context),
              letterSpacing: 2,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            icon: Icon(Icons.close_rounded, color: AppColors.primaryText(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedAvatar(Color currentBg) {
    // Null safety for name
    final String firstLetter = (widget.name.isNotEmpty) ? widget.name[0].toUpperCase() : '?';

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: currentBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: currentBg.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: -5,
                bottom: -5,
                child: Text(
                  firstLetter,
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.1)),
                ),
              ),
              Text(
                firstLetter,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
        const SizedBox(height: 16),
        Text(
          widget.name,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryText(context)),
        ),
        Text(
          widget.upiId,
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText(context), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTransactionSummary() {
    return Column(
      children: [
        Text(
          "₹${widget.amount}",
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryText(context),
            letterSpacing: -2,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondarySurface(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_rounded, size: 18, color: AppColors.successGreen),
              const SizedBox(width: 8),
              Text(
                "Secure Transaction",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryText(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomDrawer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, -10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CHOOSE PAYMENT METHOD",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.mutedText(context),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectedAccountTile(),
          const SizedBox(height: 24),
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildSelectedAccountTile() {
    final bgColorStr = _selectedAccount['color'] ?? '0xFF2563EB';

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showAccountSelection(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondarySurface(context).withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Color(int.parse(bgColorStr)),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                _selectedAccount['shortName'] ?? 'BANK',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedAccount['name'] ?? 'Select Account',
                    style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Text(
                    _selectedAccount['accNo'] ?? '',
                    style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.expand_more_rounded, color: AppColors.mutedText(context)),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  Widget _buildPayButton() {
    void _navigateToPinEntry() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PinEntryScreen(
            amount: widget.amount,
            bankName: _selectedAccount['name']!,
            recipientName: widget.name,
            recipientUpiId: widget.upiId,
            transactionId: widget.transactionId
          ),
        ),
      );
    }

    Future<void> _onConfirmAndPayPressed() async {
      HapticFeedback.heavyImpact();

      try {
        setState(() {
          _isCheckingRisk = true;
        });

        final riskResult = await RiskEngineService.evaluateRisk(
          userId: widget.userId,
          transactionId: widget.transactionId,
        );

        await Supabase.instance.client
          .from('transactions')
          .update({
            'risk_score': riskResult.riskScore,
            'risk_level': riskResult.riskLevel.name,
            'risk_verdict': riskResult.verdict.name,
          })
          .eq('id', widget.transactionId);


        setState(() {
          _isCheckingRisk = false;
        });

        // ✅ CASE 1: SAFE → proceed immediately
        if (riskResult.verdict == RiskVerdict.allow) {
          _navigateToPinEntry();
          return;
        }

        // ✅ CASE 2: WARNING / HIGH ALERT → show modal
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          builder: (_) => RiskWarningSheet(
            result: riskResult,
            onCancel: () {
              Navigator.pop(context); // dismiss modal
            },
            onProceed: () async {
              await Supabase.instance.client
                .from('transactions')
                .update({
                  'risk_acknowledged': true,
                })
                .eq('id', widget.transactionId);

              Navigator.pop(context); // dismiss modal
              _navigateToPinEntry();
            },
          ),
        );
      } catch (e) {
        setState(() {
          _isCheckingRisk = false;
        });

        _showError(
          'Unable to verify transaction security. Please try again.',
        );
      }
    }

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
        ),
        onPressed: _isCheckingRisk ? null : _onConfirmAndPayPressed,
        child: _isCheckingRisk
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                "Confirm & Pay ₹${widget.amount}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }


  void _showAccountSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(42)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.secondarySurface(context), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _accounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final acc = _accounts[index];
                    final isSel = acc == _selectedAccount;
                    final accColor = Color(int.parse(acc['color'] ?? '0xFF000000'));

                    return InkWell(
                      onTap: () {
                        setState(() => _selectedAccount = acc);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryBlue.withOpacity(0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSel ? AppColors.primaryBlue : AppColors.secondarySurface(context).withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: accColor, borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.center,
                              child: Text(acc['shortName']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(acc['name']!, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText(context))),
                                  Text(acc['accNo']!, style: TextStyle(color: AppColors.secondaryText(context), fontSize: 12)),
                                ],
                              ),
                            ),
                            if (isSel) Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}