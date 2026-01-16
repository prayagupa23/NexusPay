import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:no_screenshot/no_screenshot.dart';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart';
import 'payment_screen.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';
import '../models/transaction_model.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // No longer need to store device contacts in state
  // as we'll fetch them on demand
  List<UserModel> _searchResults = [];
  Timer? _debounce;

  late final SupabaseService _supabaseService;
  List<UserModel> _trustedContacts = [];
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;

  // Convert trusted contacts to map format for compatibility
  List<Map<String, String>> get allContacts {
    final contacts = <Map<String, String>>[];
    final seenUpis = <String>{};

    // Add recent payments
    for (var payment in recentPayments) {
      final upi = payment["upi"]!;
      if (!seenUpis.contains(upi)) {
        seenUpis.add(upi);
        contacts.add({
          "name": payment["name"]!,
          "upi": upi,
          "type": "recent"
        });
      }
    }

    // Add trusted contacts
    for (var user in _trustedContacts) {
      if (!seenUpis.contains(user.upiId)) {
        seenUpis.add(user.upiId);
        contacts.add({
          "name": user.fullName,
          "upi": user.upiId,
          "type": "trusted"
        });
      }
    }

    return contacts;
  }

  @override
  void initState() {
    super.initState();
    _enableScreenshotProtection();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadData();
    // TODO: Handle contact permissions in the future
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _disableScreenshotProtection();
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _enableScreenshotProtection() async {
    try {
      await NoScreenshot.instance.screenshotOff();
    } catch (e) {
      debugPrint('Error enabling screenshot protection: $e');
    }
  }

  Future<void> _disableScreenshotProtection() async {
    try {
      await NoScreenshot.instance.screenshotOn();
    } catch (e) {
      debugPrint('Error disabling screenshot protection: $e');
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _performSearch);
  }

  // No longer need to preload device contacts
  // We'll fetch them on demand during search

  Future<void> _performSearch() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searchQuery = '';
        });
      }
      return;
    }

    try {
      // Check for exact UPI ID match first
      if (query.contains('@')) {
        try {
          debugPrint('🔍 Checking for exact UPI ID match: $query');
          final exactMatch = await _supabaseService.getUserByUpiId(query);
          if (exactMatch != null) {
            debugPrint('✅ Found exact UPI ID match: ${exactMatch.upiId}');
            if (mounted) {
              setState(() {
                _searchResults = [exactMatch];
                _searchQuery = query;
              });
            }
            return; // Exit early if we found an exact UPI match
          } else {
            debugPrint('ℹ️ No exact UPI ID match found for: $query');
          }
        } catch (e) {
          debugPrint('❌ Error checking for exact UPI match: $e');
          // Continue with regular search if there's an error
        }
      }
      
      // Also try searching by email if the query looks like an email
      if (query.contains('@') && query.contains('.')) {
        try {
          debugPrint('🔍 Checking for email match: $query');
          final emailMatch = await _supabaseService.client
              .from('upi_user')
              .select()
              .ilike('email', query)
              .maybeSingle();
              
          if (emailMatch != null) {
            debugPrint('✅ Found email match: $emailMatch');
            final user = UserModel.fromMap(emailMatch);
            if (mounted) {
              setState(() {
                _searchResults = [user];
                _searchQuery = query;
              });
            }
            return;
          }
        } catch (e) {
          debugPrint('❌ Error checking for email match: $e');
        }
      }
      
      // Regular search if no exact matches found
      debugPrint('🔍 Performing regular search for: $query');
      final supabaseResults = await _supabaseService.searchUsers(query);
      final deviceResults = await _searchContacts(query);
      
      debugPrint('ℹ️ Found ${supabaseResults.length} Supabase results and ${deviceResults.length} device contacts');
      
      // Combine and deduplicate results
      final combinedResults = <UserModel>[];
      final seenUpiIds = <String>{};
      
      // Add Supabase results first (prioritize them)
      for (var user in supabaseResults) {
        if (user.upiId != null && user.upiId!.isNotEmpty) {
          final upiLower = user.upiId!.toLowerCase();
          if (!seenUpiIds.contains(upiLower)) {
            seenUpiIds.add(upiLower);
            combinedResults.add(user);
          }
        } else if (user.email != null && user.email!.isNotEmpty) {
          // Also check by email if UPI ID is not available
          final emailLower = user.email!.toLowerCase();
          if (!seenUpiIds.contains(emailLower)) {
            seenUpiIds.add(emailLower);
            combinedResults.add(user);
          }
        }
      }
      
      // Add device contacts that aren't already in the results
      for (var contact in deviceResults) {
        if (contact['isDeviceContact'] == true) {
          final upiId = contact['phone'] + '@heisenbug';
          if (!seenUpiIds.contains(upiId)) {
            seenUpiIds.add(upiId);
            combinedResults.add(UserModel(
              fullName: contact['name'],
              phoneNumber: contact['phone'],
              upiId: upiId,
              email: '${contact['phone']}@heisenbug.com',
              dateOfBirth: DateTime(1990, 1, 1), // Default date
              pin: '0000', // Default PIN
              city: 'Unknown',
              bankAccountNumber: contact['phone'].padRight(12, '0').substring(0, 12), // Default bank account
              aadhaarNumber: contact['phone'].padRight(12, '0').substring(0, 12), // Default Aadhaar
              bankName: 'Heisenbug Bank', // Default bank name
            ));
          }
        }
      }

      if (mounted) {
        setState(() {
          _searchResults = combinedResults;
          _searchQuery = query;
        });
      }
    } catch (e) {
      debugPrint('Error performing search: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> _searchContacts(String query) async {
    final results = <Map<String, dynamic>>[];
    
    if (await Permission.contacts.request().isGranted) {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts();
        
        for (var contact in contacts) {
          final name = contact.displayName;
          final phoneNumbers = contact.phones.map((p) => p.number).toList();
          
          if (name.toLowerCase().contains(query.toLowerCase()) ||
              phoneNumbers.any((p) => p.contains(query))) {
            results.add({
              'name': name,
              'phone': phoneNumbers.isNotEmpty ? phoneNumbers.first : '',
              'isDeviceContact': true,
            });
          }
        }
      }
    }
    
    return results;
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('logged_in_phone');

      if (phoneNumber != null) {
        final user = await _supabaseService.getUserByPhone(phoneNumber);
        if (user != null && user.userId != null) {
          // Get recent transactions
          final transactions = await _supabaseService.getUserTransactions(user.userId!, limit: 5);
          
          // Get trusted contacts with 3+ transactions
          final trustedContacts = await _supabaseService.getTrustedContacts(user.userId!);
          
          // Convert trusted contacts to UserModel list
          final trustedUsers = <UserModel>[];
          
          for (var contact in trustedContacts) {
            if (contact.upiId != null && contact.upiId!.isNotEmpty) {
              final user = await _supabaseService.getUserByUpiId(contact.upiId!);
              if (user != null) {
                trustedUsers.add(user);
                debugPrint('Added trusted user: ${user.fullName} (${user.upiId})');
              }
            }
          }

          if (mounted) {
            setState(() {
              _trustedContacts = trustedUsers;
              _recentTransactions = transactions;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading pay screen data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Get search results based on current query
  List<UserModel> get searchResults {
    if (_searchQuery.isEmpty) return [];
    
    final query = _searchQuery.toLowerCase();
    return _allContacts().where((user) {
      return user.fullName.toLowerCase().contains(query) || 
             user.upiId.toLowerCase().contains(query) ||
             user.phoneNumber.contains(query);
    }).toList();
  }

  List<Map<String, String>> get recentPayments {
    final seen = <String>{};
    final payments = <Map<String, String>>[];
    for (var txn in _recentTransactions) {
      if (!seen.contains(txn.receiverUpi)) {
        seen.add(txn.receiverUpi);
        final user = _trustedContacts.firstWhereOrNull((u) => u.upiId == txn.receiverUpi);
        payments.add({
          "name": user != null ? user.fullName : txn.receiverUpi.split('@').first,
          "upi": txn.receiverUpi,
        });
      }
    }
    return payments;
  }
  
  List<UserModel> _allContacts() {
    final contacts = <UserModel>[];
    final seenUpis = <String>{};
    
    // Add trusted contacts
    for (var contact in _trustedContacts) {
      if (!seenUpis.contains(contact.upiId)) {
        seenUpis.add(contact.upiId);
        contacts.add(contact);
      }
    }
    
    // Add recent payments that aren't already in trusted contacts
    for (var payment in recentPayments) {
      final upi = payment["upi"]!;
      final name = payment["name"]!;
      
      if (!seenUpis.contains(upi)) {
        seenUpis.add(upi);
        
        // Skip if already in trusted contacts
        if (!_trustedContacts.any((u) => u.upiId == upi)) {
          // Create a minimal user with required fields
          contacts.add(UserModel(
            upiId: upi,
            fullName: name,
            phoneNumber: upi.split('@').first,
            email: '${upi.split('@').first}@example.com', // Default email
            dateOfBirth: DateTime(1990, 1, 1), // Default date
            pin: '0000', // Default PIN
            city: 'Unknown', // Default city
            bankAccountNumber: upi.split('@').first.padRight(12, '0').substring(0, 12), // Default bank account
            aadhaarNumber: upi.split('@').first.padRight(12, '0').substring(0, 12), // Default Aadhaar
            bankName: 'Heisenbug Bank', // Default bank name
          ));
        }
      }
    }
    
    return contacts;
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;
    final hasResults = _searchResults.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pay",
          style: TextStyle(color: AppColors.primaryText(context), fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppColors.primaryText(context)),
              decoration: InputDecoration(
                hintText: "Search any UPI ID",
                hintStyle: TextStyle(color: AppColors.mutedText(context)),
                prefixIcon: Icon(Icons.search, color: AppColors.mutedText(context)),
                filled: true,
                fillColor: AppColors.surface(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: isSearching
                  ? _buildSearchView(hasResults)
                  : _buildDefaultSections(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView(bool hasResults) {
    // Check if we have an exact match (search query matches a UPI ID exactly)
    final exactMatch = _searchResults.firstWhereOrNull(
      (user) => user.upiId?.toLowerCase() == _searchQuery.toLowerCase(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show exact match in a prominent card if found
          if (exactMatch != null) ...[
            _buildExactMatchCard(exactMatch),
            const SizedBox(height: 32),
            if (_searchResults.length > 1) ...[
              const Divider(height: 40),
              Text(
                'Other matches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
          
          // Show all results or no results message
          if (hasResults)
            _buildGrid(_searchResults.where((user) => user != exactMatch).map((user) => {
                  'name': user.fullName ?? 'Unknown',
                  'upi': user.upiId ?? '',
                  'type': 'searched'
                }).toList())
          else
            Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 80, color: AppColors.mutedText(context)),
                  const SizedBox(height: 20),
                  Text(
                    "No results found",
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToPayment(UserModel user) {
    if (user.upiId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            name: user.fullName ?? 'Recipient',
            upiId: user.upiId!,
          ),
        ),
      );
    }
  }

  Widget _buildExactMatchCard(UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<UserProfileModel?>(
      future: _supabaseService.getUserProfileByUpiId(user.upiId ?? ''),
      builder: (context, snapshot) {
        final honorScore = snapshot.data?.honorScore ?? 100; // Default to 100 if not found
        final scoreColor = _getHonorScoreColor(honorScore, isDark);
        
        return GestureDetector(
          onTap: () => _navigateToPayment(user),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Exact Match',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryBlue,
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: TextStyle(
                              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.upiId,
                            style: TextStyle(
                              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scoreColor.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: scoreColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$honorScore',
                            style: TextStyle(
                              color: scoreColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getHonorScoreColor(int score, bool isDark) {
    if (score >= 80) return const Color(0xFF10B981); // Green for high scores
    if (score >= 50) return const Color(0xFFF59E0B); // Yellow for medium scores
    return const Color(0xFFEF4444); // Red for low scores
  }

  Widget _buildDefaultSections() {
    return _isLoading
        ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue)))
        : SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentPayments.isNotEmpty) _buildSection("Recent Payments", recentPayments),
          if (_trustedContacts.isNotEmpty)
            _buildSection(
              "Trusted Contacts",
              _trustedContacts.map((u) => {"name": u.fullName, "upi": u.upiId}).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, String>> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryText(context)),
        ),
        const SizedBox(height: 20),
        _buildGrid(contacts),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildGrid(List<Map<String, String>> contacts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        const spacing = 24.0;
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 32,
          children: contacts.map((contact) {
            return SizedBox(
              width: itemWidth,
              child: ContactAvatar(
                name: contact["name"]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        name: contact["name"]!,
                        upiId: contact["upi"]!,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// Helper extension
extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}