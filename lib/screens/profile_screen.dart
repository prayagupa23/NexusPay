import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_profile_model.dart';
import '../models/user_model.dart';
import '../widgets/upi_qr_code_widget.dart';
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
      appBar: _buildCreativeAppBar(),
      body: Stack(
        children: [
          _buildBackgroundBlobs(), // Creative background elements
          _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _buildProfileBody(),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF9333EA).withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildCreativeAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.01),
      elevation: 0,
      centerTitle: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Text('SECURE HUB',
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 2,
              color: AppColors.primaryText(context).withOpacity(0.7)
          )),
      actions: [
        IconButton(
          onPressed: _showLogoutConfirmation,
          icon: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 22),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          _buildIdentityHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHonorDashboard(),
                const SizedBox(height: 32),
                _buildSectionHeader('FINANCIAL STATUS'),
                const SizedBox(height: 16),
                _buildRealDebitCard(), // The Enhanced Card
                const SizedBox(height: 32),
                _buildSectionHeader('PERSONAL METRICS'),
                const SizedBox(height: 16),
                _buildInfoGrid(),
                const SizedBox(height: 32),
                _buildSectionHeader('PAYMENT QR CODE'),
                const SizedBox(height: 16),
                Center(
                  child: UpiQrCodeWidget(
                    upiId: _profile!.upiId,
                    displayName: _profile!.fullName,
                    size: 250,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Breathing Glow Effect
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(0.1),
              ),
            ),
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A56DB), Color(0xFF4F46E5)],
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1A56DB).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Center(
                child: Text(_profile!.fullName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(_profile!.fullName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryText(context))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
          child: Text(_profile!.upiId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A56DB))),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRealDebitCard() {
    return GestureDetector(
      onTap: _isBalanceRevealed ? null : _showPinDialog,
      child: Container(
        height: 210,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isBalanceRevealed
                ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                : [const Color(0xFF1A56DB), const Color(0xFF4F46E5)],
          ),
          boxShadow: [
            BoxShadow(
              color: (_isBalanceRevealed ? Colors.black : const Color(0xFF1A56DB)).withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Card Texture/Patterns
              Positioned(
                top: -50,
                right: -50,
                child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05)),
              ),
              Positioned(
                bottom: -30,
                left: -20,
                child: Icon(Icons.wifi_tethering, size: 150, color: Colors.white.withOpacity(0.03)),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("PREMIUM ACCOUNT",
                            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                        const Icon(Icons.contactless_outlined, color: Colors.white54, size: 24),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // SIM CHIP ICON
                    Container(
                      width: 45,
                      height: 35,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.orange.shade300, Colors.orange.shade600]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomPaint(painter: ChipLinesPainter()),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isBalanceRevealed ? '₹ ${_profile!.bankBalance?.toStringAsFixed(2)}' : 'XXXX XXXX XXXX',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: _isBalanceRevealed ? 28 : 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2
                            )),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_profile!.fullName.toUpperCase(),
                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                            const Text("12/28", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 85,
                width: 85,
                child: CircularProgressIndicator(
                  value: _profile!.honorScore / 100,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.secondarySurface(context),
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
              ),
              Text('${_profile!.honorScore}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryText(context))),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TRUST METRIC',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF1A56DB))),
                const SizedBox(height: 4),
                Text(_getHonorScoreLabel(_profile!.honorScore),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: scoreColor)),
                const SizedBox(height: 4),
                Text('Transaction integrity level',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedText(context), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSmallDetailCard('Home City', _profile!.city, Icons.explore_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _buildSmallDetailCard('Issuer', _profile!.bankName, Icons.account_balance_rounded)),
          ],
        ),
        const SizedBox(height: 16),
        _buildSmallDetailCard('Member Since',
            _profile!.profileCreatedAt != null
                ? '${_profile!.profileCreatedAt!.day} ${_getMonth(_profile!.profileCreatedAt!.month)} ${_profile!.profileCreatedAt!.year}'
                : 'N/A',
            Icons.shield_moon_rounded),
      ],
    );
  }

  Widget _buildSmallDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondarySurface(context).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.mutedText(context), letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryText(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.mutedText(context))),
        const SizedBox(width: 8),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  // Logic Helpers
  String _getMonth(int m) => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][m-1];

  Color _getHonorScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 50) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  String _getHonorScoreLabel(int score) {
    if (score >= 90) return 'Elite Member';
    if (score >= 80) return 'Trusted User';
    if (score >= 60) return 'Fair Rating';
    return 'Critical';
  }

  void _showLogoutConfirmation() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: AppColors.surface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('End Secure Session?', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text('Are you sure you want to exit your vault?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: TextStyle(color: AppColors.mutedText(context), fontWeight: FontWeight.w800))),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('YES, LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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

  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator(color: Color(0xFF1A56DB)));

  Widget _buildErrorState() => Center(child: Text(_errorMessage ?? 'Unknown error', style: const TextStyle(color: Colors.red)));

  Future<void> _showPinDialog() async {
    final pinController = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AlertDialog(
          backgroundColor: AppColors.surface(context).withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          title: const Icon(Icons.lock_person_rounded, size: 48, color: Color(0xFF1A56DB)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('AUTHENTICATION REQUIRED', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('Enter 4-digit PIN to decrypt balance', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
              const SizedBox(height: 24),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                autofocus: true,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 20),
                decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
                onChanged: (v) {
                  if (v.length == 4) {
                    if (v == _user!.pin) {
                      Navigator.pop(context);
                      setState(() => _isBalanceRevealed = true);
                      HapticFeedback.lightImpact();
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

// Custom Painter for the Debit Card SIM Chip lines
class ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black26..strokeWidth = 1;
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.6, 0), Offset(size.width * 0.6, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
