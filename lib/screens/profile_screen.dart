import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_profile_model.dart';
import 'auth_choice_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final SupabaseService _supabaseService;
  UserProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('logged_in_phone');

      if (phoneNumber == null) {
        setState(() {
          _errorMessage = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      final profile = await _supabaseService.getUserProfileByPhone(phoneNumber);
      
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading profile: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_phone');
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryText),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.darkSurface,
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.mutedText)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: const Text('Logout', style: TextStyle(color: AppColors.dangerRed)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.dangerRed,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.dangerRed,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _profile == null
                  ? const Center(
                      child: Text(
                        'Profile not found',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryBlue,
                                      width: 3,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _profile!.fullName[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _profile!.fullName,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _profile!.upiId,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Honor Score Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.secondarySurface),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Honor Score',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${_profile!.honorScore}',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: _getHonorScoreColor(_profile!.honorScore),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: _profile!.honorScore / 100,
                                  minHeight: 8,
                                  backgroundColor: AppColors.secondarySurface,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getHonorScoreColor(_profile!.honorScore),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getHonorScoreLabel(_profile!.honorScore),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Profile Details
                          const Text(
                            'Profile Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildDetailCard('Full Name', _profile!.fullName),
                          const SizedBox(height: 12),
                          _buildDetailCard('UPI ID', _profile!.upiId),
                          const SizedBox(height: 12),
                          _buildDetailCard('City', _profile!.city),
                          const SizedBox(height: 12),
                          _buildDetailCard('Bank', _profile!.bankName),
                          const SizedBox(height: 12),
                          _buildDetailCard(
                            'Member Since',
                            _profile!.profileCreatedAt != null
                                ? '${_profile!.profileCreatedAt!.day}/${_profile!.profileCreatedAt!.month}/${_profile!.profileCreatedAt!.year}'
                                : 'N/A',
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondarySurface),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHonorScoreColor(int score) {
    if (score >= 80) return AppColors.successGreen;
    if (score >= 50) return AppColors.warningAmber;
    return AppColors.dangerRed;
  }

  String _getHonorScoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Improvement';
  }
}

