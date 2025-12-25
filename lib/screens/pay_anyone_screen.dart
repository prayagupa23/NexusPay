import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart';
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

  List<Map<String, String>> get allContacts {
    final contacts = <Map<String, String>>[];
    final seenUpis = <String>{};

    for (var payment in recentPayments) {
      if (!seenUpis.contains(payment["upi"]!)) {
        seenUpis.add(payment["upi"]!);
        contacts.add(payment);
      }
    }

    for (var user in _trustedContacts) {
      if (!seenUpis.contains(user.upiId)) {
        seenUpis.add(user.upiId);
        contacts.add({"name": user.fullName, "upi": user.upiId});
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
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('logged_in_phone');

      if (phoneNumber != null) {
        final user = await _supabaseService.getUserByPhone(phoneNumber);
        if (user != null && user.userId != null) {
          final transactions = await _supabaseService.getUserTransactions(user.userId!, limit: 5);
          final allUsers = await _supabaseService.getAllUsers();
          final contacts = allUsers.where((u) => u.phoneNumber != phoneNumber).toList();

          if (mounted) {
            setState(() {
              _trustedContacts = contacts;
              _recentTransactions = transactions;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
      return item["name"]!.toLowerCase().contains(query) || item["upi"]!.toLowerCase().contains(query);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: hasResults
          ? _buildGrid(_searchResults)
          : Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 80, color: AppColors.mutedText(context)),
            const SizedBox(height: 20),
            Text(
              "No results found",
              style: TextStyle(color: AppColors.secondaryText(context), fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
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