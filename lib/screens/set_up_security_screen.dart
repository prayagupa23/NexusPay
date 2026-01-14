import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import '../services/user_registration_state.dart';
import '../services/supabase_service.dart';
import '../services/phone_validation_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';

class SetUpSecurityScreen extends StatefulWidget {
  const SetUpSecurityScreen({super.key});

  @override
  State<SetUpSecurityScreen> createState() => _SetUpSecurityScreenState();
}

class _SetUpSecurityScreenState extends State<SetUpSecurityScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();

  bool _obscurePin = true;
  String? _selectedCity;
  bool _isLoading = false;
  String? _errorMessage;
  String? _pinError;

  final _registrationState = UserRegistrationState();
  late final SupabaseService _supabaseService;

  // City Data with specific descriptions for a "Service Node" feel
  final List<Map<String, String>> cityData = [
    {'name': 'Mumbai', 'region': 'West India', 'desc': 'Primary Financial Hub'},
    {'name': 'Delhi', 'region': 'North India', 'desc': 'National Capital Region'},
    {'name': 'Bangalore', 'region': 'South India', 'desc': 'Technology & Innovation'},
    {'name': 'Hyderabad', 'region': 'South India', 'desc': 'Digital Infrastructure'},
    {'name': 'Pune', 'region': 'West India', 'desc': 'Educational & Tech Center'},
  ];

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _selectedCity = _registrationState.city;
  }

  bool get _isFormComplete =>
      _pinController.text.length == 4 && _pinError == null && _selectedCity != null;

  bool _isSequentialPin(String pin) {
    if (pin.length < 4) return false;
    final digits = pin.split('').map(int.parse).toList();
    if (digits.every((d) => d == digits[0])) return true;
    bool ascending = true;
    bool descending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) ascending = false;
      if (digits[i] != digits[i - 1] - 1) descending = false;
    }
    return ascending || descending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(context),
                    if (_errorMessage != null) _buildErrorBanner(),
                    const SizedBox(height: 32),
                    _buildPinSection(context),
                    const SizedBox(height: 40),
                    _buildLocationSection(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primaryText(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Account Security',
          style: TextStyle(color: AppColors.primaryText(context), fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FINALIZATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 1.5)),
              Text('Step 5/5', style: TextStyle(fontSize: 10, color: AppColors.mutedText(context), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 1.0,
              minHeight: 4,
              backgroundColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Secure Access',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primaryText(context), letterSpacing: -1)),
        const SizedBox(height: 6),
        Text('Establish your unique transaction identity.',
            style: TextStyle(fontSize: 15, color: AppColors.secondaryText(context))),
      ],
    );
  }

  Widget _buildPinSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('4-DIGIT SECURITY PIN',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.mutedText(context), letterSpacing: 1)),
            TextButton.icon(
              onPressed: () => setState(() => _obscurePin = !_obscurePin),
              icon: Icon(_obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16),
              label: Text(_obscurePin ? "Show" : "Hide", style: const TextStyle(fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pinFocus.requestFocus(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              bool hasDigit = index < _pinController.text.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _pinError != null ? AppColors.dangerRed : (hasDigit ? AppColors.primaryBlue : AppColors.secondarySurface(context)),
                    width: hasDigit ? 2 : 1.5,
                  ),
                  boxShadow: hasDigit ? [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.1), blurRadius: 10)] : [],
                ),
                child: Center(
                  child: Text(
                    hasDigit ? (_obscurePin ? '●' : _pinController.text[index]) : '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
        ),
        if (_pinError != null) ...[
          const SizedBox(height: 12),
          Text(_pinError!, style: const TextStyle(color: AppColors.dangerRed, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
        SizedBox(
          height: 0, width: 0,
          child: TextField(
            controller: _pinController,
            focusNode: _pinFocus,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            onChanged: (v) {
              setState(() {
                _pinError = _isSequentialPin(v) ? "Pin pattern is too simple." : null;
                if (_pinError != null) HapticFeedback.vibrate();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SELECT OPERATING REGION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.mutedText(context), letterSpacing: 1)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cityData.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final city = cityData[index];
            bool isSelected = _selectedCity == city['name'];

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCity = city['name']);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : AppColors.surface(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : AppColors.secondarySurface(context),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))] : [],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : AppColors.secondarySurface(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isSelected ? Icons.location_on : Icons.location_on_outlined,
                        color: isSelected ? Colors.white : AppColors.mutedText(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(city['name']!,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText(context))),
                          const SizedBox(height: 2),
                          Text("${city['region']} • ${city['desc']}",
                              style: TextStyle(fontSize: 12, color: AppColors.secondaryText(context))),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        border: Border(top: BorderSide(color: AppColors.secondarySurface(context), width: 0.5)),
      ),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (_isFormComplete && !_isLoading) ? _handleSaveAndContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            disabledBackgroundColor: AppColors.secondarySurface(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Complete Secure Setup', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _handleSaveAndContinue() async {
    HapticFeedback.heavyImpact();
    setState(() { _errorMessage = null; _isLoading = true; });

    try {
      _registrationState.pin = _pinController.text;
      _registrationState.city = _selectedCity;

      final userModel = _registrationState.toUserModel();
      if (userModel == null) throw "Internal state error.";

      // Calculate honor score based on phone number validation
      int honorScore = 100; // Default score
      
      try {
        // If we have phone validation data, use it to calculate the score
        if (_registrationState.honorScoreData != null) {
          final phoneService = PhoneValidationService();
          final phoneNumber = _registrationState.honorScoreData!['phone_number'] as String?;
          
          if (phoneNumber != null) {
            final validationData = await phoneService.validatePhoneNumber(phoneNumber);
            if (validationData != null) {
              honorScore = phoneService.calculateHonorScore(validationData);
            }
          }
        }
      } catch (e) {
        debugPrint('Error calculating honor score: $e');
        // Continue with default score if there's an error
      }

      final createdUser = await _supabaseService.createUser(userModel);

      if (createdUser.userId != null) {
        // Create user profile with calculated honor score
        await _supabaseService.createUserProfile(UserProfileModel(
          userId: createdUser.userId!,
          upiId: createdUser.upiId,
          fullName: createdUser.fullName,
          city: createdUser.city,
          bankName: createdUser.bankName,
          honorScore: honorScore,
          bankBalance: 10000.0,
        ));
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_phone', userModel.phoneNumber);
      _registrationState.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
      }
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(color: AppColors.dangerBg(context), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.dangerRed, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.dangerRed, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}