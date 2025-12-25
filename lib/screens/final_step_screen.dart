import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'set_up_security_screen.dart';
import '../services/user_registration_state.dart';

class FinalStepScreen extends StatefulWidget {
  const FinalStepScreen({super.key});

  @override
  State<FinalStepScreen> createState() => _FinalStepScreenState();
}

class _FinalStepScreenState extends State<FinalStepScreen> {
  final TextEditingController ddController = TextEditingController();
  final TextEditingController mmController = TextEditingController();
  final TextEditingController yyyyController = TextEditingController();

  final _registrationState = UserRegistrationState();
  String? _name;
  String? _email;
  String? _phone;
  String? _dobError;

  bool agreed = false;

  @override
  void initState() {
    super.initState();
    _name = _registrationState.fullName;
    _email = _registrationState.email;
    _phone = _registrationState.phoneNumber;
    
    // Load existing DOB if available
    if (_registrationState.dateOfBirth != null) {
      final dob = _registrationState.dateOfBirth!;
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
    super.dispose();
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
          'Sign Up',
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
                'Final Step',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please enter your date of birth and review your details to ensure accuracy.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Date of Birth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _dobField(ddController, 'DD'),
                  const SizedBox(width: 12),
                  _dobField(mmController, 'MM'),
                  const SizedBox(width: 12),
                  _dobField(yyyyController, 'YYYY', flex: 2),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'You must be 18 years or older to open an account.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
              ),
              if (_dobError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _dobError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.dangerRed,
                    ),
                  ),
                ),

              const SizedBox(height: 32),
              const Text(
                'Review Your Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              _infoCard(),

              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Checkbox(
                      value: agreed,
                      onChanged: (v) => setState(() => agreed = v ?? false),
                      activeColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13.5, color: AppColors.mutedText),
                        children: [
                          const TextSpan(text: 'By continuing, I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy.',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 120), // Extra space to avoid overlap with fixed button
            ],
          ),
        ),
      ),
      // Fixed bottom bar with Confirm button
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
              style: ElevatedButton.styleFrom(
                backgroundColor: agreed
                    ? AppColors.primaryBlue
                    : AppColors.secondarySurface,
                foregroundColor: Colors.white,
                elevation: agreed ? 8 : 0,
                shadowColor: agreed
                    ? AppColors.primaryBlue.withOpacity(0.4)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: agreed && _isDobValid()
                  ? () {
                _saveDob();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SetUpSecurityScreen(),
                  ),
                );
              }
                  : null,
              child: const Text(
                'Confirm & Create Account',
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

  Widget _dobField(TextEditingController controller, String hint, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _dobError != null ? AppColors.dangerRed : AppColors.secondarySurface,
            width: 1,
          ),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: hint == 'YYYY' ? 4 : 2,
          onChanged: (_) {
            setState(() {
              _dobError = null;
            });
            _validateDob();
          },
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppColors.mutedText,
            ),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _dobError != null ? AppColors.dangerRed : AppColors.primaryBlue,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validateDob() {
    final dd = ddController.text.trim();
    final mm = mmController.text.trim();
    final yyyy = yyyyController.text.trim();

    if (dd.isEmpty || mm.isEmpty || yyyy.isEmpty) {
      setState(() {
        _dobError = null;
      });
      return;
    }

    try {
      final day = int.parse(dd);
      final month = int.parse(mm);
      final year = int.parse(yyyy);

      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900 || year > DateTime.now().year) {
        setState(() {
          _dobError = 'Please enter a valid date';
        });
        return;
      }

      final dob = DateTime(year, month, day);
      final age = DateTime.now().difference(dob).inDays ~/ 365;

      if (age < 18) {
        setState(() {
          _dobError = 'You must be at least 18 years old';
        });
        return;
      }

      setState(() {
        _dobError = null;
      });
    } catch (e) {
      setState(() {
        _dobError = 'Invalid date format';
      });
    }
  }

  bool _isDobValid() {
    final dd = ddController.text.trim();
    final mm = mmController.text.trim();
    final yyyy = yyyyController.text.trim();

    if (dd.isEmpty || mm.isEmpty || yyyy.isEmpty) {
      return false;
    }

    try {
      final day = int.parse(dd);
      final month = int.parse(mm);
      final year = int.parse(yyyy);

      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900 || year > DateTime.now().year) {
        return false;
      }

      final dob = DateTime(year, month, day);
      final age = DateTime.now().difference(dob).inDays ~/ 365;

      return age >= 18;
    } catch (e) {
      return false;
    }
  }

  void _saveDob() {
    if (_isDobValid()) {
      final day = int.parse(ddController.text.trim());
      final month = int.parse(mmController.text.trim());
      final year = int.parse(yyyyController.text.trim());
      _registrationState.dateOfBirth = DateTime(year, month, day);
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
              'Step 4 of 5',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '80% Completed',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.8,
            minHeight: 10,
            backgroundColor: AppColors.secondarySurface,
            valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondarySurface),
      ),
      child: Column(
        children: [
          _editableRow('LEGAL NAME', _name ?? 'Not set', (v) {
            setState(() => _name = v);
            _registrationState.fullName = v;
          }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.secondarySurface, height: 1),
          ),
          _editableRow('EMAIL ADDRESS', _email ?? 'Not set', (v) {
            setState(() => _email = v);
            _registrationState.email = v;
          }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.secondarySurface, height: 1),
          ),
          _editableRow('PHONE NUMBER', _phone ?? 'Not set', (v) {
            setState(() => _phone = v);
            _registrationState.phoneNumber = v;
          }),
        ],
      ),
    );
  }

  Widget _editableRow(String label, String value, Function(String) onSave) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          iconSize: 22,
          icon: Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
          onPressed: () async {
            final controller = TextEditingController(text: value);
            final result = await showDialog<String>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.darkSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(
                  label,
                  style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                ),
                content: TextField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.secondarySurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: const Text('Save', style: TextStyle(color: AppColors.primaryBlue)),
                  ),
                ],
              ),
            );
            if (result != null && result.isNotEmpty) onSave(result);
          },
        ),
      ],
    );
  }
}