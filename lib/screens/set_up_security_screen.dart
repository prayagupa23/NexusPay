import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import '../services/user_registration_state.dart';
import '../services/supabase_service.dart';
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
  bool _obscurePin = true;
  String? _selectedCity;
  bool _isLoading = false;
  String? _errorMessage;
  String? _pinError;

  final _registrationState = UserRegistrationState();
  late final SupabaseService _supabaseService;

  // Valid cities from database constraint
  final List<Map<String, String>> popularCities = [
    {'city': 'Mumbai', 'country': 'India'},
    {'city': 'Pune', 'country': 'India'},
    {'city': 'Delhi', 'country': 'India'},
    {'city': 'Bangalore', 'country': 'India'},
    {'city': 'Hyderabad', 'country': 'India'},
  ];

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _selectedCity = _registrationState.city;
    if (_registrationState.pin != null) {
      _pinController.text = _registrationState.pin!;
    }
  }

  bool get _isFormComplete {
    final pinValid = _pinController.text.length == 4 && 
                     UserModel.isValidPin(_pinController.text) &&
                     !_isSequentialPin(_pinController.text) &&
                     _pinError == null;
    return pinValid && _selectedCity != null && UserModel.isValidCity(_selectedCity!);
  }

  bool _isSequentialPin(String pin) {
    // Check for sequential patterns like 1234, 4321, 0000, etc.
    final digits = pin.split('').map(int.parse).toList();
    
    // Check if all digits are same
    if (digits.every((d) => d == digits[0])) return true;
    
    // Check if sequential ascending
    bool ascending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) {
        ascending = false;
        break;
      }
    }
    
    // Check if sequential descending
    bool descending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] - 1) {
        descending = false;
        break;
      }
    }
    
    return ascending || descending;
  }

  @override
  void dispose() {
    _pinController.dispose();
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
              _buildStepIndicator(),
              const SizedBox(height: 32),

              const Text(
                'Set up Security',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Secure your account with a PIN and tell us where you are based.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

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

              // CREATE A 4-DIGIT PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CREATE A 4-DIGIT PIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _obscurePin ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.mutedText,
                    ),
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final hasDigit = index < _pinController.text.length;
                  final digit = hasDigit ? _pinController.text[index] : '';
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: hasDigit
                            ? AppColors.primaryBlue
                            : AppColors.secondarySurface,
                        width: hasDigit ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _obscurePin ? (hasDigit ? '•' : '') : digit,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'Avoid sequential numbers like 1234 or 0000.',
                style: TextStyle(fontSize: 13, color: AppColors.mutedText),
              ),
              if (_pinError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _pinError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.dangerRed,
                    ),
                  ),
                ),

              // Hidden TextField for actual PIN input
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                  onChanged: (_) {
                    setState(() {
                      _pinError = null;
                      if (_pinController.text.length == 4) {
                        if (!UserModel.isValidPin(_pinController.text)) {
                          _pinError = 'PIN must be exactly 4 digits';
                        } else if (_isSequentialPin(_pinController.text)) {
                          _pinError = 'Avoid sequential or repeating PINs';
                        }
                      }
                    });
                  },
                ),
              ),

              const SizedBox(height: 0),

              // WHERE ARE YOU LOCATED?
              const Text(
                'WHERE ARE YOU LOCATED?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search city or zip code',
                  hintStyle: TextStyle(color: AppColors.mutedText),
                  prefixIcon: Icon(Icons.search, color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(Icons.my_location, color: AppColors.primaryBlue),
                  title: const Text('Use current location', style: TextStyle(color: AppColors.primaryText)),
                  subtitle: Text('San Francisco, CA', style: TextStyle(color: AppColors.secondaryText)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText),
                  onTap: () {
                    setState(() {
                      _selectedCity = 'San Francisco, CA (Current)';
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'POPULAR CITIES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16),
              _popularCitiesList(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // Fixed Save & Continue button at bottom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          border: Border(top: BorderSide(color: AppColors.secondarySurface, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormComplete
                    ? AppColors.primaryBlue
                    : AppColors.secondarySurface,
                foregroundColor: Colors.white,
                elevation: _isFormComplete ? 8 : 0,
                shadowColor: _isFormComplete
                    ? AppColors.subtleBlueGlow
                    : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isFormComplete && !_isLoading
                  ? _handleSaveAndContinue
                  : null,
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
                      'Save & Continue',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Step 5 of 5',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '100% Completed',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 1.0,
            minHeight: 10,
            backgroundColor: AppColors.secondarySurface,
            valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _popularCitiesList() {
    return Column(
      children: popularCities.map((city) {
        final bool isSelected = _selectedCity == city['city'];
        return GestureDetector(
          onTap: () => setState(() => _selectedCity = city['city']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withOpacity(0.15) : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.secondarySurface,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      city['city']![0],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city['city']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Text(
                        city['country']!,
                        style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primaryBlue : AppColors.mutedText,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleSaveAndContinue() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Save PIN and city to registration state
    _registrationState.pin = _pinController.text;
    _registrationState.city = _selectedCity;

    try {
      // Create user model from registration state
      final userModel = _registrationState.toUserModel();
      
      if (userModel == null) {
        setState(() {
          _errorMessage = 'Please complete all required fields';
          _isLoading = false;
        });
        return;
      }

      // Save to Supabase - Create user first
      final createdUser = await _supabaseService.createUser(userModel);

      // Create user profile after user is created
      if (createdUser.userId != null) {
        final userProfile = UserProfileModel(
          userId: createdUser.userId!,
          upiId: createdUser.upiId,
          fullName: createdUser.fullName,
          city: createdUser.city,
          bankName: createdUser.bankName,
          honorScore: 100, // Default honor score
        );

        try {
          await _supabaseService.createUserProfile(userProfile);
        } catch (e) {
          // If profile creation fails, still allow user to proceed
          // but log the error
          debugPrint('Error creating user profile: $e');
        }
      }

      // Save phone number to SharedPreferences for future PIN lock screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_phone', userModel.phoneNumber);

      // Clear registration state
      _registrationState.clear();

      // Navigate to home screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}
