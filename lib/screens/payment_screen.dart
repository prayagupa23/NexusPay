import 'package:flutter/material.dart';
import 'package:heisenbug/screens/account_selection_screen.dart';
import '../theme/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

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
            _buildHeader(),
            _buildPaymentDetails(),
            const Spacer(),
            _buildNumpad(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
          '₹${_amount.isEmpty ? '0' : _amount}',
          style: const TextStyle(color: AppColors.primaryText, fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(Icons.edit, color: AppColors.primaryBlue, size: 16),
          label: const Text('Add note', style: TextStyle(color: AppColors.primaryBlue)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildNumpad() {
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
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: List.generate(12, (index) {
              String text;
              if (index < 9) {
                text = (index + 1).toString();
              } else if (index == 9) {
                text = '.';
              } else if (index == 10) {
                text = '0';
              } else {
                text = 'backspace';
              }

              return InkWell(
                onTap: () => _onKeyPress(text),
                child: Center(
                  child: text == 'backspace'
                      ? const Icon(Icons.backspace_outlined, color: AppColors.primaryText)
                      : Text(text, style: const TextStyle(color: AppColors.primaryText, fontSize: 24)),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_amount.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountSelectionScreen(amount: _amount)),
                );
              }
            },
            child: const Text('Proceed', style: TextStyle(fontSize: 18, color: AppColors.primaryText)),
          ),
        ],
      ),
    );
  }
}