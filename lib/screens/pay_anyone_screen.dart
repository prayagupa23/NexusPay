import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart'; // ContactAvatar
import 'payment_screen.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  late final SupabaseService _supabaseService;
  List<UserModel> _trustedContacts = [];
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;

  // Combine all data once for unified search
  List<Map<String, String>> get allContacts {
    final contacts = <Map<String, String>>[];
    final seenUpis = <String>{};
    
    // Add recent payments (from transactions) - these are already in recentPayments getter
    for (var payment in recentPayments) {
      if (!seenUpis.contains(payment["upi"]!)) {
        seenUpis.add(payment["upi"]!);
        contacts.add(payment);
      }
    }
    
    // Add trusted contacts
    for (var user in _trustedContacts) {
      if (!seenUpis.contains(user.upiId)) {
        seenUpis.add(user.upiId);
        contacts.add({
          "name": user.fullName,
          "upi": user.upiId,
        });
      }
    }
    
    return contacts;
  }

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadData();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('logged_in_phone');

      if (phoneNumber != null) {
        final user = await _supabaseService.getUserByPhone(phoneNumber);
        if (user != null && user.userId != null) {
          // Load recent transactions
          final transactions = await _supabaseService.getUserTransactions(
            user.userId!,
            limit: 5,
          );
          
          // Get unique receiver UPIs from recent transactions
          final recentReceiverUpis = transactions
              .map((t) => t.receiverUpi)
              .toSet()
              .toList();

          // Load all users for trusted contacts
          final allUsers = await _supabaseService.getAllUsers();
          
          // Filter out current user
          final contacts = allUsers
              .where((u) => u.phoneNumber != phoneNumber)
              .toList();

          if (mounted) {
            setState(() {
              _trustedContacts = contacts;
              _recentTransactions = transactions;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _searchResults {
    if (_searchQuery.isEmpty) return [];

    final query = _searchQuery.toLowerCase();
    return allContacts.where((item) {
      final name = item["name"]!.toLowerCase();
      final upi = item["upi"]!.toLowerCase();
      return name.contains(query) || upi.contains(query);
    }).toList();
  }

  List<Map<String, String>> get recentPayments {
    // Get unique recent payments from transactions
    final seen = <String>{};
    final payments = <Map<String, String>>[];
    
    for (var txn in _recentTransactions) {
      if (!seen.contains(txn.receiverUpi)) {
        seen.add(txn.receiverUpi);
        
        // Try to find user in trusted contacts first
        UserModel? user;
        try {
          user = _trustedContacts.firstWhere(
            (u) => u.upiId == txn.receiverUpi,
          );
        } catch (e) {
          // User not in trusted contacts, use UPI ID part as name
          user = null;
        }
        
        payments.add({
          "name": user != null 
              ? user.fullName.split(' ').first // First name only
              : txn.receiverUpi.split('@').first, // Use UPI ID part as fallback
          "upi": txn.receiverUpi,
        });
      }
    }
    
    return payments;
  }

  List<Map<String, String>> get trustedContacts {
    return _trustedContacts.map((user) => {
      "name": user.fullName,
      "upi": user.upiId,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchQuery.isNotEmpty;
    final bool hasResults = _searchResults.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pay",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search any UPI ID",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          // Full Grey Content Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondarySurface.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
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

  // Search Mode: Show results or "No results"
  Widget _buildSearchView(bool hasResults) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: hasResults
          ? _buildGrid(_searchResults)
          : const Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              "No results found",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Default Mode: Full sections
  Widget _buildDefaultSections() {
    return _isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
          )
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recentPayments.isNotEmpty)
                  _buildSection("Recent Payments", recentPayments),
                if (trustedContacts.isNotEmpty)
                  _buildSection("Trusted Contacts", trustedContacts),
              ],
            ),
          );
  }

  Widget _buildSection(String title, List<Map<String, String>> contacts) {
    if (contacts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        _buildGrid(contacts),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildGrid(List<Map<String, String>> contacts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const int columns = 4;
        const double spacing = 20.0;
        final double totalSpacing = spacing * (columns - 1);
        final double itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 20,
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