import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';

class UpiQrCodeWidget extends StatelessWidget {
  final String upiId;
  final String displayName;
  final double size;

  const UpiQrCodeWidget({
    super.key,
    required this.upiId,
    required this.displayName,
    this.size = 250,
  });

  // Generate UPI payment payload string
  String _generateUpiPayload() {
    // URL encode the display name to handle special characters
    final encodedName = Uri.encodeComponent(displayName);
    
    // Use standard UPI format that works with all UPI apps
    // Our app will intercept upi:// scheme if installed (via AndroidManifest)
    // If our app is not installed, standard UPI apps will handle it
    return 'upi://pay?pa=$upiId&pn=$encodedName&cu=INR';
  }

  @override
  Widget build(BuildContext context) {
    final payload = _generateUpiPayload();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor(context), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor(context), width: 1),
            ),
            child: QrImageView(
              data: payload,
              version: QrVersions.auto,
              size: size - 32, // Account for padding
              backgroundColor: AppColors.bg(context),
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primaryText(context).withOpacity(0.8),
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.primaryText(context).withOpacity(0.9),
              ),
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              padding: const EdgeInsets.all(0),
            ),
          ),
          const SizedBox(height: 16),
          
          // UPI ID Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  upiId,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Info text
          Text(
            'Scan to pay',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mutedText(context),
            ),
          ),
        ],
      ),
    );
  }
}

