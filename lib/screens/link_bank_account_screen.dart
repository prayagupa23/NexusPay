import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptics
import '../theme/app_colors.dart';
import 'final_step_screen.dart';
import '../services/user_registration_state.dart';

class LinkBankAccountScreen extends StatefulWidget {
  const LinkBankAccountScreen({super.key});

  @override
  State<LinkBankAccountScreen> createState() => _LinkBankAccountScreenState();
}

class _LinkBankAccountScreenState extends State<LinkBankAccountScreen> {
  final _registrationState = UserRegistrationState();

  String? _selectedBank;
  String? _generatedUpiId;
  bool _isLoading = false;

  final List<String> _validBanks = ['Union', 'BOI', 'BOBaroda', 'Kotak', 'HDFC'];

  final Map<String, String> _bankDisplayNames = {
    'Union': 'Union Bank',
    'BOI': 'Bank of India',
    'BOBaroda': 'Bank of Baroda',
    'Kotak': 'Kotak Mahindra',
    'HDFC': 'HDFC Bank',
  };

  final Map<String, Color> _bankColors = {
    'Union': const Color(0xFFE91E63),
    'BOI': const Color(0xFF0D47A1),
    'BOBaroda': const Color(0xFFFF6D00),
    'Kotak': const Color(0xFFD32F2F),
    'HDFC': const Color(0xFF003366),
  };

  @override
  void initState() {
    super.initState();
    _selectedBank = _registrationState.bankName;
    _generateUpiId();
  }

  void _generateUpiId() {
    if (_registrationState.fullName != null && _selectedBank != null) {
      final name = _registrationState.fullName!.toLowerCase().replaceAll(' ', '.');
      final bank = _selectedBank!.toLowerCase();
      setState(() => _generatedUpiId = '$name@$bank');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildTextHeader(context),
                    const SizedBox(height: 32),
                    _buildBankGrid(),
                    const SizedBox(height: 40),
                    _buildUpiPreviewCard(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryText(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Step 3: Bank Linking',
        style: TextStyle(color: AppColors.primaryText(context), fontSize: 16, fontWeight: FontWeight.w700),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('60% COMPLETE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryBlue, letterSpacing: 1)),
              Text('Step 3/5', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.mutedText(context))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 6,
              backgroundColor: AppColors.secondarySurface(context),
              valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connect your bank', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primaryText(context), letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('We will verify your account via encrypted mobile binding.', style: TextStyle(fontSize: 15, color: AppColors.secondaryText(context))),
      ],
    );
  }

  Widget _buildBankGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _validBanks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, i) {
        final bank = _validBanks[i];
        final isSelected = _selectedBank == bank;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedBank = bank);
            _generateUpiId();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? _bankColors[bank]!.withOpacity(0.05) : AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? _bankColors[bank]! : AppColors.secondarySurface(context),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [BoxShadow(color: _bankColors[bank]!.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(Icons.account_balance, size: 40, color: _bankColors[bank]!.withOpacity(0.05)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _buildBankLogo(bank),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _bankDisplayNames[bank]!,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryText(context)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankLogo(String bank) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _bankColors[bank],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(bank[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
    );
  }

  Widget _buildUpiPreviewCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondarySurface(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_2_rounded, size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text('UPI ID PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryBlue, letterSpacing: 1)),
                const Spacer(),
                Icon(Icons.security, size: 16, color: AppColors.successGreen),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _generatedUpiId ?? 'Select your bank above',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _generatedUpiId != null ? AppColors.primaryText(context) : AppColors.mutedText(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text('This will be your unique address for all transactions', style: TextStyle(fontSize: 12, color: AppColors.mutedText(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    bool canProceed = _selectedBank != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        border: Border(top: BorderSide(color: AppColors.secondarySurface(context), width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: AppColors.mutedText(context)),
              const SizedBox(width: 6),
              Text('Verify via SMS (Standard rates apply)', style: TextStyle(fontSize: 12, color: AppColors.mutedText(context))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: !canProceed || _isLoading ? null : _handleContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Initialize Secure Link', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate bank handshaking
    _registrationState.bankName = _selectedBank;
    _registrationState.upiId = _generatedUpiId;
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FinalStepScreen()));
    }
  }
}
