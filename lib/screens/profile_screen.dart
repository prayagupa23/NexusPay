import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_profile_model.dart';
import '../models/user_model.dart';
import 'auth_choice_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final SupabaseService _supabaseService;
  UserProfileModel? _profile;
  UserModel? _user;
  bool _isLoading = true;
  bool _isBalanceRevealed = false;
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
      if (phoneNumber == null) throw 'No active session found';

      final profile = await _supabaseService.getUserProfileByPhone(phoneNumber);
      final user = await _supabaseService.getUserByPhone(phoneNumber);

      if (mounted) {
        setState(() {
          _profile = profile;
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : _buildProfileBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text('Account Hub', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.2)),
      actions: [
        IconButton(
          onPressed: _showLogoutConfirmation,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 20),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildIdentityHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHonorDashboard(),
                const SizedBox(height: 32),
                _buildSectionHeader('FINANCIAL STATUS'),
                const SizedBox(height: 16),
                _buildBankBalanceCard(),
                const SizedBox(height: 32),
                _buildSectionHeader('PERSONAL METRICS'),
                const SizedBox(height: 16),
                _buildInfoGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryBlue.withOpacity(0.15), Colors.transparent],
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.7)]),
                  boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Center(
                  child: Text(_profile!.fullName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.verified_rounded, color: AppColors.primaryBlue, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(_profile!.fullName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primaryText(context))),
          const SizedBox(height: 4),
          Text(_profile!.upiId, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondaryText(context), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildHonorDashboard() {
    final scoreColor = _getHonorScoreColor(_profile!.honorScore);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.secondarySurface(context)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _profile!.honorScore / 100,
                  strokeWidth: 10,
                  backgroundColor: AppColors.secondarySurface(context),
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
                Text('${_profile!.honorScore}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryText(context))),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HONOR SCORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.primaryBlue)),
                const SizedBox(height: 4),
                Text(_getHonorScoreLabel(_profile!.honorScore), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: scoreColor)),
                const SizedBox(height: 4),
                Text('Score based on transaction integrity.', style: TextStyle(fontSize: 12, color: AppColors.mutedText(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankBalanceCard() {
    return GestureDetector(
      onTap: _isBalanceRevealed ? null : _showPinDialog,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isBalanceRevealed
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [AppColors.primaryBlue, const Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(right: -20, top: -20, child: Icon(Icons.circle, size: 150, color: Colors.white.withOpacity(0.05))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SAVINGS ACCOUNT', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1)),
                      Text(_profile!.bankName.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Available Balance', style: TextStyle(color: Colors.white60, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        _isBalanceRevealed ? '₹ ${_profile!.bankBalance?.toStringAsFixed(2)}' : '••••••••',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(_isBalanceRevealed ? Icons.lock_open_rounded : Icons.lock_outline_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(_isBalanceRevealed ? 'SECURE VIEW ACTIVE' : 'TAP TO REVEAL', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSmallDetailCard('City', _profile!.city, Icons.location_on_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallDetailCard('Bank', _profile!.bankName, Icons.account_balance_rounded)),
          ],
        ),
        const SizedBox(height: 12),
        _buildSmallDetailCard('Registration Date',
            _profile!.profileCreatedAt != null ? '${_profile!.profileCreatedAt!.day} ${_getMonth(_profile!.profileCreatedAt!.month)} ${_profile!.profileCreatedAt!.year}' : 'N/A',
            Icons.calendar_today_rounded),
      ],
    );
  }

  Widget _buildSmallDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondarySurface(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(height: 12),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.mutedText(context), letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryText(context))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.mutedText(context)));
  }

  // Support Methods
  String _getMonth(int m) => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][m-1];

  Color _getHonorScoreColor(int score) {
    if (score >= 80) return AppColors.successGreen;
    if (score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getHonorScoreLabel(int score) {
    if (score >= 90) return 'Elite';
    if (score >= 80) return 'Trusted';
    if (score >= 60) return 'Good';
    return 'Action Needed';
  }

  void _showLogoutConfirmation() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.surface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('End Session?', style: TextStyle(fontWeight: FontWeight.w800)),
          content: const Text('You will need to re-authenticate to access your secure vault.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('STAY', style: TextStyle(color: AppColors.mutedText(context)))),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_phone');
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthChoiceScreen()), (_) => false);
  }

  Widget _buildLoadingState() => Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));

  Widget _buildErrorState() => Center(child: Text(_errorMessage ?? 'Unknown error', style: const TextStyle(color: Colors.red)));

  // PIN Dialog logic remains similar but enhanced with better styling...
  Future<void> _showPinDialog() async {
    final pinController = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: AppColors.surface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          title: const Center(child: Text('Security Check', style: TextStyle(fontWeight: FontWeight.w900))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter 4-digit PIN to unlock balance', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 20),
                decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
                onChanged: (v) {
                  if (v.length == 4) {
                    if (v == _user!.pin) {
                      Navigator.pop(context);
                      setState(() => _isBalanceRevealed = true);
                      HapticFeedback.mediumImpact();
                    } else {
                      pinController.clear();
                      HapticFeedback.vibrate();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
