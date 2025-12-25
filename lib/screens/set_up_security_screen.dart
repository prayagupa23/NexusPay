import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class SetUpSecurityScreen extends StatefulWidget {
  const SetUpSecurityScreen({super.key});

  @override
  State<SetUpSecurityScreen> createState() => _SetUpSecurityScreenState();
}

class _SetUpSecurityScreenState extends State<SetUpSecurityScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _obscurePin = true;
  String? _selectedCity;

  final List<Map<String, String>> popularCities = [
    {'city': 'New York, NY', 'country': 'United States'},
    {'city': 'London', 'country': 'United Kingdom'},
    {'city': 'Singapore', 'country': 'Singapore'},
    {'city': 'Mumbai', 'country': 'India'},
    {'city': 'Dubai', 'country': 'United Arab Emirates'},
  ];

  bool get _isFormComplete =>
      _pinController.text.length == 4 && _selectedCity != null;

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

              // Hidden TextField for actual PIN input
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
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
              onPressed: _isFormComplete
                  ? () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (_) => false,
                );
              }
                  : null,
              child: const Text(
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
}
