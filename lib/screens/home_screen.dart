import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heisenbug/services/contact_sync_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ensure these imports match your actual file structure
import '../theme/app_colors.dart';
import 'pay_anyone_screen.dart';
import 'contact_detail_screen.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'payment_screen.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../tile/avatar_tile.dart';
import 'chat_screen.dart';
import 'money_screen.dart';
import 'heatmap_screen.dart';
import 'detect_fraud_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/recipient_honor_score_model.dart';
import '../services/recipient_honor_score_db.dart';
import 'trusted_contacts_screen.dart';
import '../models/trusted_contact_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _askContactPermissionAndSync();
    // Listen for payment completion to refresh alerts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUnknownUserAlerts();
    });
  }

  Future<void> _askContactPermissionAndSync() async {
    final status = await Permission.contacts.status;
    if (!status.isGranted) {
      final result = await Permission.contacts.request();
      if (!result.isGranted) return; // User denied, skip sync
    }
    // Get user id (phone number or UUID, adjust as needed)
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('logged_in_phone');
    if (phoneNumber != null) {
      final syncService = ContactSyncService(userId: phoneNumber);
      await syncService.syncContactsToDB();
    }
  }

  Future<void> _checkForUnknownUserAlerts() async {
    // This will be called to refresh alerts when needed
    if (mounted) setState(() {});
  }

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
              const TrustedContactsSection(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MoneyScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          }
        },
      ),
    );
  }
}

class _AppBarSection extends StatelessWidget {
  const _AppBarSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "NexusPay",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText(context),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondarySurface(context),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor(context),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primaryText(context).withOpacity(0.8),
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionShieldCard extends StatelessWidget {
  const _ProtectionShieldCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.secondarySurface(context).withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.shield_rounded,
              size: 80,
              color: const Color(0xFF1A56DB).withOpacity(0.03),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAnimatedShieldIcon(),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Secure Protection",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryText(context),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Your account is currently under end-to-end security monitoring.",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText(context),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedShieldIcon() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A56DB).withOpacity(0.05),
            border: Border.all(
              color: const Color(0xFF1A56DB).withOpacity(0.1),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.gpp_good_rounded,
            color: Color(0xFF1A56DB),
            size: 38,
          ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionItem(
            context,
            "Scan & Pay",
            Icons.qr_code_scanner_rounded,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              );

              if (result != null && result is Map<String, dynamic>) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      name: result['name'] as String,
                      upiId: result['upiId'] as String,
                    ),
                  ),
                );
              }
            },
          ),
          _actionItem(
            context,
            "Pay Anyone",
            Icons.send_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PayScreen()),
              );
            },
          ),
          _actionItem(
            context,
            "Heat Maps",
            Icons.map_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HeatmapScreen()),
              );
            },
          ),
          _actionItem(
            context,
            "Detect Fraud",
            Icons.fact_check_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetectFraudScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionItem(
    BuildContext context,
    String label,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A56DB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText(context),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// UNKNOWN USER ALERT SECTION
// -----------------------------------------------------------------------------
class _UnknownUserAlertSection extends StatefulWidget {
  const _UnknownUserAlertSection();

  @override
  State<_UnknownUserAlertSection> createState() =>
      _UnknownUserAlertSectionState();
}

class _UnknownUserAlertSectionState extends State<_UnknownUserAlertSection> {
  late final SupabaseService _supabaseService;
  TransactionModel? _unknownUserTransaction;
  UserModel? _unknownUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadUnknownUserAlert();
  }

  Future<void> _loadUnknownUserAlert() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('logged_in_phone');

      if (phoneNumber != null) {
        final user = await _supabaseService.getUserByPhone(phoneNumber);
        if (user != null && user.userId != null) {
          // Get recent transactions
          final transactions = await _supabaseService.getUserTransactions(
            user.userId!,
            limit: 10,
          );

          // Find the most recent transaction with unknown/unverified user
          for (var tx in transactions) {
            // Check if transaction is with unknown user (not trusted and not verified)
            if (tx.isTrustedContact == false ||
                (tx.isTrustedContact == null &&
                    tx.isVerifiedContact == false)) {
              // Try to get user info
              try {
                final receiver = await _supabaseService.getUserByUpiId(
                  tx.receiverUpi,
                );
                if (mounted) {
                  setState(() {
                    _unknownUserTransaction = tx;
                    _unknownUser = receiver;
                    _isLoading = false;
                  });
                }
                return;
              } catch (e) {
                // If user not found, still show alert
                if (mounted) {
                  setState(() {
                    _unknownUserTransaction = tx;
                    _unknownUser = null;
                    _isLoading = false;
                  });
                }
                return;
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading unknown user alert: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _unknownUserTransaction == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final receiverName =
        _unknownUser?.fullName ??
        _unknownUserTransaction!.receiverUpi.split('@').first;
    final amount = _unknownUserTransaction!.amount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF4A1A1A).withOpacity(0.8),
                    const Color(0xFF2A0A0A).withOpacity(0.9),
                    const Color(0xFF1A0505),
                  ]
                : [
                    const Color(0xFFFFE8E8),
                    const Color(0xFFFFD1D1),
                    const Color(0xFFFFC7C7),
                  ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark
                ? AppColors.dangerRed.withOpacity(0.3)
                : AppColors.dangerRed.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dangerRed.withOpacity(isDark ? 0.2 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF450A0A)
                        : const Color(0xFFFFDADA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: isDark
                        ? const Color(0xFFF87171)
                        : const Color(0xFFE11D48),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Unknown User Payment",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE11D48).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "UNVERIFIED",
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFF87171)
                                    : const Color(0xFFE11D48),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Payment to $receiverName",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF450A0A)
                      : const Color(0xFFFEE2E2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Amount",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText(context),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText(context),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.orange.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Unverified Contact",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "This payment was made to an unverified contact. Verify the recipient before sending money again.",
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText(context),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to transaction details or contact verification
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  foregroundColor: isDark
                      ? Colors.white
                      : const Color(0xFFE11D48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF450A0A)
                          : const Color(0xFFFEE2E2),
                    ),
                  ),
                ),
                child: const Text(
                  "Verify Contact",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fraud Intelligence Center",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryText(context),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "View All",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? Colors.blue.shade300
                      : const Color(0xFF1A56DB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF4A1A1A).withOpacity(0.8),
                        const Color(0xFF2A0A0A).withOpacity(0.9),
                        const Color(0xFF1A0505),
                      ]
                    : [
                        const Color(0xFFFFE8E8),
                        const Color(0xFFFFD1D1),
                        const Color(0xFFFFC7C7),
                      ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? AppColors.dangerRed.withOpacity(0.3)
                    : AppColors.dangerRed.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dangerRed.withOpacity(isDark ? 0.2 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF450A0A)
                            : const Color(0xFFFFDADA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.gpp_maybe_rounded,
                        color: isDark
                            ? const Color(0xFFF87171)
                            : const Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Critical Alert",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE11D48,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "HIGH RISK",
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFF87171)
                                        : const Color(0xFFE11D48),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Unverified Contact Detected",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF991B1B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Unverified contact detected. Verify now to ensure your account security.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                      foregroundColor: isDark
                          ? Colors.white
                          : const Color(0xFFE11D48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF450A0A)
                              : const Color(0xFFFEE2E2),
                        ),
                      ),
                    ),
                    child: const Text(
                      "Verify Contact",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrustedContactsSection extends StatefulWidget {
  const TrustedContactsSection({super.key});

  @override
  State<TrustedContactsSection> createState() => _TrustedContactsSectionState();
}

class _TrustedContactsSectionState extends State<TrustedContactsSection> {
  late final SupabaseService _supabaseService;
  List<TrustedContact> _trustedContacts = [];
  bool _isLoading = true;
  String? _currentUserUpi;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      debugPrint('Loading trusted contacts...');
      final prefs = await SharedPreferences.getInstance();
      _currentUserUpi = prefs.getString('current_user_upi');
      
      // Get current user ID
      final currentPhone = prefs.getString('logged_in_phone');
      if (currentPhone == null) {
        debugPrint('No logged in user found');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Get current user's profile to get user_id
      final currentUser = await _supabaseService.getUserByPhone(currentPhone);
      if (currentUser == null || currentUser.userId == null) {
        debugPrint('Failed to get current user profile');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (currentUser.userId == null) {
        debugPrint('No current user ID available');
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      
      _currentUserId = currentUser.userId!;
      
      // If we don't have UPI ID, try to get it from profile
      if (_currentUserUpi == null) {
        final profile = await _supabaseService.getUserProfile(_currentUserId!);
        if (profile != null) {
          _currentUserUpi = profile.upiId;
          await prefs.setString('current_user_upi', _currentUserUpi!);
        }
      }

      // Get trusted contacts (users with 3+ transactions)
      debugPrint('Fetching trusted contacts for user ID: $_currentUserId');
      final trustedContacts = await _supabaseService.getTrustedContacts(_currentUserId!);
      
      debugPrint('Found ${trustedContacts.length} trusted contacts');
      for (var contact in trustedContacts) {
        debugPrint('Trusted contact: ${contact.fullName} (${contact.upiId}) - ${contact.transactionCount} transactions');
      }

      if (mounted) {
        setState(() {
          _trustedContacts = trustedContacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading trusted contacts: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trusted Contacts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrustedContactsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _trustedContacts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'Your trusted contacts will appear here after 3+ transactions',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._trustedContacts
                            .map(
                              (contact) => Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Column(
                                  children: [
                                    ContactAvatar(
                                      name: contact.fullName ?? 'Unknown',
                                      onTap: () {
                                        if (_currentUserUpi == null || contact.upiId == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("User profile not loaded"),
                                            ),
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ContactDetailScreen(
                                              name: contact.fullName ?? 'Unknown',
                                              upiId: contact.upiId!,
                                              currentUserUpi: _currentUserUpi!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    // Transaction count text removed as per request
                                  ],
                                ),
                              ),
                            )
                            .toList(),
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
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.5),
          ),
          child: Icon(Icons.add, color: Colors.grey.shade400, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          "Add New",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
