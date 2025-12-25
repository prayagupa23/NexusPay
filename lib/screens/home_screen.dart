import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'pay_anyone_screen.dart';
import 'contact_detail_screen.dart';
import 'profile_screen.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';
import '../tile/avatar_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const _AppBarSection(),
              const SizedBox(height: 24),
              const _ProtectionShieldCard(),
              const SizedBox(height: 32),
              const _QuickActionsRow(),
              const SizedBox(height: 32),
              const _FraudIntelligenceSection(),
              const SizedBox(height: 40),
              const TrustedContactsSection(), // Correctly linked section
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}

// -----------------------------------------------------------------------------
// APP BAR
// -----------------------------------------------------------------------------
class _AppBarSection extends StatelessWidget {
  const _AppBarSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("AppName",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primaryText(context))),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFFFE4D6),
              child: const Icon(Icons.person, color: Color(0xFFF97316)),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PROTECTION SHIELD CARD
// -----------------------------------------------------------------------------
class _ProtectionShieldCard extends StatelessWidget {
  const _ProtectionShieldCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: const Icon(Icons.shield_rounded, color: Color(0xFF1A56DB), size: 38),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(8)),
                child: const Text("ACTIVE",
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              )
            ],
          ),
          const SizedBox(height: 24),
          Text("Live Protection Shield",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryText(context))),
          const SizedBox(height: 8),
          Text("Your transactions are being monitored\nin real-time.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.secondaryText(context), height: 1.4)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// QUICK ACTIONS
// -----------------------------------------------------------------------------
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionItem(context, "Scan & Pay", Icons.qr_code_scanner_rounded),
          _actionItem(context, "Send Money", Icons.send_rounded, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PayScreen()));
          }),
          _actionItem(context, "Heat Maps", Icons.map_rounded),
          _actionItem(context, "Detect Fraud", Icons.fact_check_rounded),
        ],
      ),
    );
  }

  Widget _actionItem(BuildContext context, String label, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: const Color(0xFF1A56DB), borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryText(context))),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// FRAUD INTELLIGENCE
// -----------------------------------------------------------------------------
class _FraudIntelligenceSection extends StatelessWidget {
  const _FraudIntelligenceSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Fraud Intelligence Center",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText(context))),
              const Text("View All", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A56DB))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFF5F5), Color(0xFFFFE8E8)]),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFFFD1D1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFFDADA), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.report_problem_rounded, color: Color(0xFFE11D48)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Fraud Alert Detected",
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFFFE4E4), borderRadius: BorderRadius.circular(8)),
                                child: const Text("High Risk",
                                    style: TextStyle(color: Color(0xFFE11D48), fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const Text("Suspicious login attempt", style: TextStyle(fontSize: 13, color: Color(0xFF991B1B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Unverified contact, verification required", style: TextStyle(fontSize: 14, color: Color(0xFF4B5563))),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE11D48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Color(0xFFFEE2E2))),
                    ),
                    child: const Text("View Profile", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TRUSTED CONTACTS SECTION
// -----------------------------------------------------------------------------
class TrustedContactsSection extends StatefulWidget {
  const TrustedContactsSection({super.key});

  @override
  State<TrustedContactsSection> createState() => _TrustedContactsSectionState();
}

class _TrustedContactsSectionState extends State<TrustedContactsSection> {
  late final SupabaseService _supabaseService;
  List<UserModel> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final allUsers = await _supabaseService.getAllUsers();
      final prefs = await SharedPreferences.getInstance();
      final currentPhone = prefs.getString('logged_in_phone');
      final contacts = currentPhone != null
          ? allUsers.where((user) => user.phoneNumber != currentPhone).toList()
          : allUsers;
      if (mounted) setState(() { _contacts = contacts; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text("Trusted Contacts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText(context))),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._contacts.map((user) => Padding(
                padding: const EdgeInsets.only(right: 24),
                child: ContactAvatar(
                  name: user.fullName,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ContactDetailScreen(name: user.fullName, upiId: user.upiId))),
                ),
              )),
              _buildAddButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Column(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.5),
          ),
          child: Icon(Icons.add, color: Colors.grey.shade400, size: 28),
        ),
        const SizedBox(height: 12),
        Text("Add New",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// BOTTOM NAVIGATION
// -----------------------------------------------------------------------------
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_filled, "Home"),
          _navItem(1, Icons.account_balance_wallet_rounded, "Money"),
          _navItem(2, Icons.person_rounded, "Profile"),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0F4FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: isSelected ? const Color(0xFF1A56DB) : const Color(0xFF94A3B8), size: 26),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1A56DB) : const Color(0xFF94A3B8),
              )),
        ],
      ),
    );
  }
}