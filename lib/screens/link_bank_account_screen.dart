import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'final_step_screen.dart';
import '../services/user_registration_state.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';

class LinkBankAccountScreen extends StatefulWidget {
  const LinkBankAccountScreen({super.key});

  @override
  State<LinkBankAccountScreen> createState() => _LinkBankAccountScreenState();
}

class _LinkBankAccountScreenState extends State<LinkBankAccountScreen> {
  final _registrationState = UserRegistrationState();
  late final SupabaseService _supabaseService;
  String? _selectedBank;
  String? _generatedUpiId;
  bool _isLoading = false;
  String? _errorMessage;

  // Valid banks from database constraint
  final List<String> _validBanks = ['Union', 'BOI', 'BOBaroda', 'Kotak', 'HDFC'];
  
  // Bank display names mapping
  final Map<String, String> _bankDisplayNames = {
    'Union': 'Union Bank',
    'BOI': 'Bank of India',
    'BOBaroda': 'Bank of Baroda',
    'Kotak': 'Kotak Mahindra',
    'HDFC': 'HDFC Bank',
  };

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _selectedBank = _registrationState.bankName;
    _generatedUpiId = _registrationState.upiId;
    _generateUpiId();
  }

  void _generateUpiId() {
    if (_registrationState.fullName != null && _selectedBank != null) {
      // Generate UPI ID: firstname.lastname@bankname (lowercase)
      final nameParts = _registrationState.fullName!.toLowerCase().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.last : '';
      final bankName = _selectedBank!.toLowerCase();
      
      String upiId;
      if (lastName.isNotEmpty) {
        upiId = '$firstName.$lastName@$bankName';
      } else {
        upiId = '$firstName@$bankName';
      }
      
      setState(() {
        _generatedUpiId = upiId;
      });
    }
  }

  void _selectBank(String bank) {
    setState(() {
      _selectedBank = bank;
      _errorMessage = null;
    });
    _generateUpiId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryText),
        title: const Text(
          'Link Bank Account',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stepIndicator(),
              const SizedBox(height: 32),

              const Text(
                'Select your primary bank',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Link your account to enable secure UPI payments.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dangerRed),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.dangerRed, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.dangerRed, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),
              Text(
                'SELECT YOUR BANK',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 20),
              _popularBanksGrid(),

              const SizedBox(height: 40),

              _generatedUpiIdCard(),

              const SizedBox(height: 100), // Extra space so content scrolls above bottom bar
            ],
          ),
        ),
      ),
      // Persistent bottom bar with Verify & Continue button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          border: Border(
            top: BorderSide(color: AppColors.secondarySurface, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading || _selectedBank == null ? null : _handleContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading || _selectedBank == null
                    ? AppColors.secondarySurface
                    : AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: AppColors.subtleBlueGlow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Verify & Continue →',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedBank == null || _generatedUpiId == null) {
      setState(() {
        _errorMessage = 'Please select a bank';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if UPI ID already exists
      final upiExists = await _supabaseService.checkUpiIdExists(_generatedUpiId!);
      if (upiExists) {
        // Try to generate a unique UPI ID by adding a number
        int counter = 1;
        String newUpiId = _generatedUpiId!;
        while (await _supabaseService.checkUpiIdExists(newUpiId)) {
          final parts = _generatedUpiId!.split('@');
          newUpiId = '${parts[0]}$counter@${parts[1]}';
          counter++;
        }
        _generatedUpiId = newUpiId;
      }

      // Save to registration state
      _registrationState.bankName = _selectedBank;
      _registrationState.upiId = _generatedUpiId;

      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FinalStepScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    } finally {
      if (mounted && _errorMessage != null) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _stepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Step 3 of 5',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '60% Completed',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.6,
            minHeight: 10,
            backgroundColor: AppColors.secondarySurface,
            valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _popularBanksGrid() {
    // Map valid banks to colors
    final bankColors = {
      'Union': const Color(0xFF4CAF50),
      'BOI': const Color(0xFF00BCD4),
      'BOBaroda': const Color(0xFFFF9800),
      'Kotak': const Color(0xFF1976D2),
      'HDFC': const Color(0xFFE91E63),
    };

    return Wrap(
      spacing: 20,
      runSpacing: 24,
      alignment: WrapAlignment.start,
      children: _validBanks.map((bank) {
        final isSelected = _selectedBank == bank;
        return GestureDetector(
          onTap: () => _selectBank(bank),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bankColors[bank],
                  border: isSelected
                      ? Border.all(color: AppColors.primaryBlue, width: 3)
                      : null,
                ),
                child: Center(
                  child: Text(
                    bank[0],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _bankDisplayNames[bank] ?? bank,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? AppColors.primaryBlue : AppColors.primaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _generatedUpiIdCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR GENERATED UPI ID',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.6,
                ),
              ),
              if (_generatedUpiId != null)
                TextButton(
                  onPressed: () {
                    // Allow manual editing of UPI ID
                    _showEditUpiDialog();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Edit ID',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _generatedUpiId ?? 'Select a bank to generate UPI ID',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _generatedUpiId != null
                  ? AppColors.primaryText
                  : AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                      children: [
                        const TextSpan(text: 'Linked to '),
                        TextSpan(
                          text: _registrationState.phoneNumber != null
                              ? '${_registrationState.phoneNumber!.substring(0, 4)} **** ${_registrationState.phoneNumber!.substring(8)}'
                              : '+1234 **** *89',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(text: '. You can use this ID to receive money securely from any payment app.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.mutedText, size: 18),
              const SizedBox(width: 8),
              Text(
                'Bank grade security & encryption',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditUpiDialog() {
    final controller = TextEditingController(text: _generatedUpiId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Edit UPI ID',
          style: TextStyle(color: AppColors.primaryText),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: 'e.g., parth.salunke@hdfc',
            hintStyle: const TextStyle(color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.secondarySurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.mutedText)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _generatedUpiId = controller.text.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );
  }
}