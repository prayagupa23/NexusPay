import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'set_up_security_screen.dart';
import '../services/user_registration_state.dart';

class FinalStepScreen extends StatefulWidget {
  const FinalStepScreen({super.key});

  @override
  State<FinalStepScreen> createState() => _FinalStepScreenState();
}

class _FinalStepScreenState extends State<FinalStepScreen> {
  final _registrationState = UserRegistrationState();

  final ddController = TextEditingController();
  final mmController = TextEditingController();
  final yyyyController = TextEditingController();

  final FocusNode _mmFocus = FocusNode();
  final FocusNode _yyyyFocus = FocusNode();

  String? _dobError;
  bool agreed = false;

  @override
  void initState() {
    super.initState();
    final dob = _registrationState.dateOfBirth;
    if (dob != null) {
      ddController.text = dob.day.toString().padLeft(2, '0');
      mmController.text = dob.month.toString().padLeft(2, '0');
      yyyyController.text = dob.year.toString();
    }
  }

  @override
  void dispose() {
    ddController.dispose();
    mmController.dispose();
    yyyyController.dispose();
    _mmFocus.dispose();
    _yyyyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildHeroHeader(context),
                    const SizedBox(height: 40),

                    _buildDobSection(context),
                    const SizedBox(height: 48),

                    _buildReviewManifest(context),
                    const SizedBox(height: 32),

                    _buildAgreementSection(context),
                    const SizedBox(height: 120), // Bottom padding for scroll
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomCTA(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryText(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Identity Verification',
        style: TextStyle(color: AppColors.primaryText(context), fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FINAL REVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 1.2)),
              Text('Step 4 of 5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText(context))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.8,
              minHeight: 6,
              backgroundColor: AppColors.secondarySurface(context),
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Almost there',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.primaryText(context), letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your information before we finalize your secure digital wallet.',
          style: TextStyle(fontSize: 16, color: AppColors.secondaryText(context), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDobSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATE OF BIRTH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryBlue, letterSpacing: 1)),
        const SizedBox(height: 16),
        Row(
          children: [
            _dobInputTile(ddController, 'DD', 2, null, _mmFocus),
            const SizedBox(width: 12),
            _dobInputTile(mmController, 'MM', 2, _mmFocus, _yyyyFocus),
            const SizedBox(width: 12),
            _dobInputTile(yyyyController, 'YYYY', 4, _yyyyFocus, null, flex: 2),
          ],
        ),
        if (_dobError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 14, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(_dobError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _dobInputTile(TextEditingController controller, String hint, int limit, FocusNode? current, FocusNode? next, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondarySurface(context), width: 1.5),
        ),
        child: TextField(
          controller: controller,
          focusNode: current,
          keyboardType: TextInputType.number,
          maxLength: limit,
          textAlign: TextAlign.center,
          onChanged: (v) {
            if (v.length == limit && next != null) next.requestFocus();
            _validateDob();
          },
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryText(context)),
          decoration: InputDecoration(counterText: '', hintText: hint, hintStyle: TextStyle(color: AppColors.mutedText(context), fontSize: 16), border: InputBorder.none),
        ),
      ),
    );
  }

  Widget _buildReviewManifest(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('IDENTITY MANIFEST', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryBlue, letterSpacing: 1)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.secondarySurface(context), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              _manifestRow(context, Icons.person_outline, 'Full Name', _registrationState.fullName),
              _manifestDivider(),
              _manifestRow(context, Icons.alternate_email_rounded, 'Email', _registrationState.email),
              _manifestDivider(),
              _manifestRow(context, Icons.phone_android_rounded, 'Mobile', _registrationState.phoneNumber),
            ],
          ),
        ),
      ],
    );
  }

  Widget _manifestRow(BuildContext context, IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.mutedText(context), letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value ?? '—', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryText(context))),
              ],
            ),
          ),
          Icon(Icons.edit_note_rounded, color: AppColors.mutedText(context), size: 22),
        ],
      ),
    );
  }

  Widget _manifestDivider() => Divider(height: 32, thickness: 1, color: AppColors.secondarySurface(context).withOpacity(0.5));

  Widget _buildAgreementSection(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => agreed = !agreed),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: agreed ? AppColors.primaryBlue.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: agreed ? AppColors.primaryBlue.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(agreed ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: agreed ? AppColors.primaryBlue : AppColors.mutedText(context)),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: AppColors.secondaryText(context), height: 1.4),
                  children: [
                    const TextSpan(text: 'I verify that the above details are correct and I agree to the '),
                    TextSpan(text: 'Terms of Service.', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context) {
    final bool isReady = agreed && _isDobValid();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        border: Border(top: BorderSide(color: AppColors.secondarySurface(context), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: ElevatedButton(
            onPressed: isReady ? _onFinalSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              disabledBackgroundColor: AppColors.secondarySurface(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: isReady ? 8 : 0,
              shadowColor: AppColors.primaryBlue.withOpacity(0.4),
            ),
            child: const Text('Confirm & Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Future<void> _onFinalSubmit() async {
    HapticFeedback.heavyImpact();
    _saveDob();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final phoneNumber = _registrationState.phoneNumber;
      if (phoneNumber == null) {
        throw Exception('Phone number is required');
      }

      // Store the phone number in registration state for later use
      _registrationState.honorScoreData = {
        'phone_number': phoneNumber,
        'validation_time': DateTime.now().toIso8601String(),
      };

      // Proceed to security setup
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const SetUpSecurityScreen())
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Logic remains the same as provided, just ensuring it plugs into the new fields
  void _validateDob() {
    setState(() {
      try {
        final d = int.parse(ddController.text);
        final m = int.parse(mmController.text);
        final y = int.parse(yyyyController.text);
        if (y < 1900 || y > DateTime.now().year) { _dobError = 'Invalid year'; return; }
        if (m < 1 || m > 12) { _dobError = 'Invalid month'; return; }
        if (d < 1 || d > 31) { _dobError = 'Invalid day'; return; }
        final dob = DateTime(y, m, d);
        final age = DateTime.now().difference(dob).inDays ~/ 365;
        _dobError = age < 18 ? 'Must be 18 or older' : null;
      } catch (_) { _dobError = null; }
    });
  }

  bool _isDobValid() => _dobError == null && ddController.text.length == 2 && mmController.text.length == 2 && yyyyController.text.length == 4;

  void _saveDob() {
    _registrationState.dateOfBirth = DateTime(int.parse(yyyyController.text), int.parse(mmController.text), int.parse(ddController.text));
  }
}