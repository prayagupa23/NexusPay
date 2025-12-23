import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart';
import 'account_selection_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String name;
  final String upiId;

  const PaymentScreen({
    super.key,
    required this.name,
    required this.upiId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _amount = "";

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (_amount.length < 6) {
        _amount += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _details(),
            const Spacer(),
            _numpad(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.close,
                color: AppColors.primaryText, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _details() {
    return Column(
      children: [
        // Reused ContactAvatar — colorful background + white letter
        ContactAvatar(
          name: widget.name,
          // No onTap needed here (or pass null if required)
        ),
        const SizedBox(height: 14),
        Text(
          "Paying ${widget.name}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.upiId,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "₹${_amount.isEmpty ? '0' : _amount}",
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit,
              size: 16, color: AppColors.primaryBlue),
          label: const Text(
            "Add note",
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _numpad() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: List.generate(12, (i) {
              String key;
              if (i < 9) {
                key = '${i + 1}';
              } else if (i == 9) {
                key = '.';
              } else if (i == 10) {
                key = '0';
              } else {
                key = 'backspace';
              }

              return InkWell(
                onTap: () => _onKeyPress(key),
                child: Center(
                  child: key == 'backspace'
                      ? const Icon(Icons.backspace_outlined,
                      color: AppColors.primaryText)
                      : Text(
                    key,
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _amount.isEmpty
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AccountSelectionScreen(amount: _amount),
                ),
              );
            },
            child: const Text(
              "Proceed",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
