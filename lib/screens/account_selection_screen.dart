import 'package:flutter/material.dart';
import 'package:heisenbug/screens/pin_entry_screen.dart';
import '../theme/app_colors.dart';

class AccountSelectionScreen extends StatefulWidget {
  final String amount;

  const AccountSelectionScreen({super.key, required this.amount});

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  final List<Map<String, String>> _accounts = [
    {
      'name': 'Union Bank of India',
      'shortName': 'UnionBank',
      'accNo': 'XXXX XXXX 1234',
    },
    {
      'name': 'Saraswat Bank',
      'shortName': 'Saraswat',
      'accNo': 'XXXX XXXX 5678',
    },
    {
      'name': 'Bank of Baroda',
      'shortName': 'BoB',
      'accNo': 'XXXX XXXX 9012',
    },
    {
      'name': 'HDFC Bank',
      'shortName': 'HDFC',
      'accNo': 'XXXX XXXX 3456',
    },
    {
      'name': 'ICICI Bank',
      'shortName': 'ICICI',
      'accNo': 'XXXX XXXX 7890',
    },
  ];

  late Map<String, String> _selectedAccount;

  @override
  void initState() {
    super.initState();
    _selectedAccount = _accounts.first;
  }

  void _showAccountSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondarySurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Choose account to pay with',
                style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ..._accounts.map((account) {
              bool isSelected = account == _selectedAccount;
              return ListTile(
                onTap: () {
                  setState(() {
                    _selectedAccount = account;
                  });
                  Navigator.pop(context);
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(account['shortName']!, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                title: Text(account['name']!, style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
                subtitle: Text('acc no: ${account['accNo']!}', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.primaryBlue) : null,
              );
            }),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildPaymentDetails(),
            const Spacer(),
            _buildAccountSelector(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryText, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.primaryText, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.secondarySurface,
          child: Icon(Icons.person, color: AppColors.primaryText, size: 30),
        ),
        const SizedBox(height: 16),
        const Text(
          'Paying Deep Bandekar',
          style: TextStyle(color: AppColors.primaryText, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'UPI ID: 123456789@fam',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Text(
          '₹${widget.amount}',
          style: const TextStyle(color: AppColors.primaryText, fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Add note', style: TextStyle(color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildAccountSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose account to pay with',
            style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showAccountSelection(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_selectedAccount['shortName']!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedAccount['name']!, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
                        Text('acc no: ${_selectedAccount['accNo']!}', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryText),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PinEntryScreen(
                    amount: widget.amount,
                    bankName: _selectedAccount['name']!,
                  ),
                ),
              );
            },
            child: Text('Pay ₹${widget.amount}', style: const TextStyle(fontSize: 18, color: AppColors.primaryText)),
          ),
        ],
      ),
    );
  }
}