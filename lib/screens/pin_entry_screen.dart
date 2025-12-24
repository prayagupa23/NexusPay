import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'payment_success_screen.dart';

class PinEntryScreen extends StatefulWidget {
  final String amount;
  final String bankName;
  final String recipientName;

  const PinEntryScreen({
    super.key,
    required this.amount,
    required this.bankName,
    required this.recipientName,
  });

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(
                amount: widget.amount,
                recipient: widget.recipientName,
                transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
                timestamp: DateTime.now(),
              ),
            ),
          );
        }
      } else if (_pin.length < 4) {
        _pin += value;
      }
    });
  }

  bool get _isPinComplete => _pin.length == 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.bankName.toUpperCase(),
          style: const TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "UPI",
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
          Text(
            widget.recipientName,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
          Text(
            '₹ ${widget.amount}',
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinEntry() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Text(
            'ENTER UPI PIN',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: index < _pin.length
                      ? AppColors.primaryText
                      : AppColors.secondarySurface,
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: List.generate(12, (index) {
          String value;
          if (index < 9) {
            value = (index + 1).toString();
          } else if (index == 9) {
            value = 'backspace';
          } else if (index == 10) {
            value = '0';
          } else {
            value = 'submit';
          }

          return InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => _onKeyPress(value),
            child: Center(
              child: value == 'backspace'
                  ? const Icon(
                Icons.backspace_outlined,
                color: AppColors.primaryText,
                size: 28,
              )
                  : value == 'submit'
                  ? Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _isPinComplete
                      ? AppColors.primaryBlue
                      : AppColors.secondarySurface,
                  shape: BoxShape.circle,
                  boxShadow: _isPinComplete
                      ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : null,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              )
                  : Text(
                value,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}