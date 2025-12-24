import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart';
import 'pin_entry_screen.dart';

class AccountSelectionScreen extends StatefulWidget {
  final String name;
  final String upiId;
  final String amount;

  const AccountSelectionScreen({
    super.key,
    required this.name,
    required this.upiId,
    required this.amount,
  });

  @override
  State<AccountSelectionScreen> createState() =>
      _AccountSelectionScreenState();
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

  //  Same avatar color logic
  Color _getAvatarColor() {
    final int hash = widget.name.toLowerCase().hashCode;
    return ContactAvatar.avatarColors[
    hash.abs() % ContactAvatar.avatarColors.length
    ];
  }

  void _showAccountSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Choose account to pay with',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: _accounts.length,
                    itemBuilder: (context, index) {
                      final account = _accounts[index];
                      final bool isSelected =
                          account == _selectedAccount;

                      return ListTile(
                        onTap: () {
                          setState(() {
                            _selectedAccount = account;
                          });
                          Navigator.pop(context);
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            account['shortName']!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          account['name']!,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'acc no: ${account['accNo']!}',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryBlue,
                        )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            //  Header
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.popUntil(
                      context,
                          (route) => route.isFirst,
                    ),
                  ),
                ],
              ),
            ),

            // Payee Details
            Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: avatarColor,
                  child: Text(
                    widget.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Paying ${widget.name}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  widget.upiId,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "₹${widget.amount}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Add note",
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            //  Bottom Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pay from",
                    style:
                    TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () => _showAccountSelection(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _selectedAccount['shortName']!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedAccount['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'acc no: ${_selectedAccount['accNo']!}',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PinEntryScreen(
                              amount: widget.amount,
                              bankName: _selectedAccount['name']!,
                              recipientName: widget.name,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Pay ₹${widget.amount}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
