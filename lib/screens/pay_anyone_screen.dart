import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart'; // ContactAvatar
import 'payment_screen.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Combine all data once for unified search
  late final List<Map<String, String>> allContacts;

  final List<Map<String, String>> recentPayments = [
    {"name": "Parth", "upi": "814329@fam"},
    {"name": "Rahul", "upi": "rahul@upi"},
    {"name": "Sneha", "upi": "sneha@upi"},
    {"name": "Riya", "upi": "riya@upi"},
  ];

  final List<Map<String, String>> trustedContacts = [
    {"name": "Parth S Salunke", "upi": "814329@fam"},
    {"name": "Rahul Patil", "upi": "rahul@upi"},
    {"name": "Amit Shah", "upi": "amit@ybl"},
    {"name": "Sneha Kulkarni", "upi": "sneha@upi"},
    {"name": "Riya Mehta", "upi": "riya@upi"},
    {"name": "Om Deshmukh", "upi": "om@upi"},
    {"name": "Kunal Jain", "upi": "kunal@upi"},
  ];

  final List<Map<String, String>> businesses = [
    {"name": "Amazon", "upi": "amazon@upi"},
    {"name": "Swiggy", "upi": "swiggy@upi"},
    {"name": "Netflix", "upi": "netflix@upi"},
    {"name": "Electricity Bill", "upi": "electricity@upi"},
    {"name": "Zomato", "upi": "zomato@upi"},
    {"name": "Uber", "upi": "uber@upi"},
    {"name": "Flipkart", "upi": "flipkart@upi"},
    {"name": "PhonePe", "upi": "phonepe@upi"},
  ];

  @override
  void initState() {
    super.initState();
    // Combine all contacts once
    allContacts = [...recentPayments, ...trustedContacts, ...businesses];

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection("Recent Payments", recentPayments),
          _buildSection("Trusted Contacts", trustedContacts),
          _buildSection("Businesses", businesses),
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