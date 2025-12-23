import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'payment_success_screen.dart';

class PinEntryScreen extends StatefulWidget {
  final String amount;
  final String bankName;

  const PinEntryScreen({super.key, required this.amount, required this.bankName});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _pin = "";

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else if (value == 'submit') {
        if (_pin.length == 4) {
          // Navigate to success screen when PIN is complete and submit is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                amount: widget.amount,
                recipient: widget.bankName,
                transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
                timestamp: DateTime.now(),
              ),
            ),
          );
        }
      } else if (_pin.length < 4) {
        _pin += value;
        
        // Auto-submit when 4 digits are entered
        if (_pin.length == 4) {
          // Small delay to show the last digit
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _onKeyPress('submit');
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.bankName.toUpperCase(), style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'UPI',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildPaymentInfo(),
          _buildPinEntry(),
          const Spacer(),
          _buildNumpad(),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Deep Bandekar', style: TextStyle(color: AppColors.primaryText, fontSize: 16)),
          Text('₹ ${widget.amount}', style: const TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPinEntry() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          const Text('ENTER UPI PIN', style: TextStyle(color: AppColors.secondaryText, fontSize: 14, letterSpacing: 0.5)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: index < _pin.length ? AppColors.primaryText : AppColors.secondarySurface,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: List.generate(12, (index) {
          String text;
          if (index < 9) {
            text = (index + 1).toString();
          } else if (index == 9) {
            text = 'backspace';
          } else if (index == 10) {
            text = '0';
          } else {
            text = 'submit';
          }

          return InkWell(
            onTap: () => _onKeyPress(text),
            borderRadius: BorderRadius.circular(30),
            child: Center(
              child: text == 'backspace'
                  ? const Icon(Icons.backspace_outlined, color: AppColors.primaryText, size: 28)
                  : text == 'submit'
                      ? Container(
                          decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: AppColors.primaryText, size: 32),
                        )
                      : Text(text, style: const TextStyle(color: AppColors.primaryText, fontSize: 28, fontWeight: FontWeight.w600)),
            ),
          );
        }),
      ),
    );
  }
}