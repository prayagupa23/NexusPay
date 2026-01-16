import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import '../theme/app_colors.dart';
import '../services/fraud_data_service.dart';
import '../services/heatmap_coordinates_service.dart';
import '../models/fraud_data_model.dart';
import 'fraud_analytics_screen.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  // TEMP: local / placeholder URL
  static const String heatmapUrl =
      "https://nexuspay-heatmap-api.onrender.com/heatmap/india";

  List<FraudData> _fraudData = [];
  OverlayEntry? _tooltipOverlay;
  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _enableScreenshotProtection();
    _loadFraudData();
  }

  @override
  void dispose() {
    _disableScreenshotProtection();
    _removeTooltip();
    super.dispose();
  }

  Future<void> _enableScreenshotProtection() async {
    try {
      await NoScreenshot.instance.screenshotOff();
    } catch (e) {
      debugPrint('Error enabling screenshot protection: $e');
    }
  }

  Future<void> _disableScreenshotProtection() async {
    try {
      await NoScreenshot.instance.screenshotOn();
    } catch (e) {
      debugPrint('Error disabling screenshot protection: $e');
    }
  }

  Future<void> _loadFraudData() async {
    try {
      final data = await FraudDataService.getFraudData();
      setState(() {
        _fraudData = data;
      });
    } catch (e) {
      // Handle error silently for now
    }
  }

  void _removeTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  void _showTooltip(
    BuildContext context,
    TapUpDetails details,
    FraudData fraudData,
  ) {
    _removeTooltip();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset tapPosition = renderBox.globalToLocal(details.globalPosition);

    _tooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: tapPosition.dx,
        top: tapPosition.dy - 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fraudData.stateName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: AppColors.dangerRed,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${fraudData.fraudCases} cases',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.dangerRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_tooltipOverlay!);

    // Auto-hide tooltip after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _removeTooltip();
      }
    });
  }

  void _onImageTap(TapUpDetails details) {
    final RenderBox? renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset localPosition = renderBox.globalToLocal(
      details.globalPosition,
    );
    final Size size = renderBox.size;

    // Convert to relative coordinates (0.0 to 1.0)
    final double relativeX = localPosition.dx / size.width;
    final double relativeY = localPosition.dy / size.height;

    final String? stateName = HeatmapCoordinatesService.findStateByCoordinates(
      relativeX,
      relativeY,
    );

    if (stateName != null) {
      final FraudData? fraudData = _fraudData.cast<FraudData?>().firstWhere(
        (data) => data?.stateName.toLowerCase() == stateName.toLowerCase(),
        orElse: () => null,
      );

      if (fraudData != null) {
        _showTooltip(context, details, fraudData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text(
          "Fraud Heatmap",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText(context),
          ),
        ),
        backgroundColor: AppColors.surface(context),
        foregroundColor: AppColors.primaryText(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryText(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: _removeTooltip,
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondarySurface(context).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.dangerRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.warning_rounded,
                            color: AppColors.dangerRed,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Fraud Activity Heatmap",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Real-time visualization of fraudulent activities across regions",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondaryText(context),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Heatmap Image Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondarySurface(
                        context,
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GestureDetector(
                      onTapUp: _onImageTap,
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 6.0,
                        child: Image.network(
                          key: _imageKey,
                          heatmapUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColors.primaryBlue,
                                    strokeWidth: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Loading heatmap...",
                                    style: TextStyle(
                                      color: AppColors.secondaryText(context),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.dangerRed.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.dangerRed,
                                      size: 48,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Unable to load heatmap",
                                    style: TextStyle(
                                      color: AppColors.primaryText(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Please check your internet connection and try again",
                                    style: TextStyle(
                                      color: AppColors.secondaryText(context),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // View Analytics Button
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FraudAnalyticsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: AppColors.subtleBlueGlow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "View Analytics",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom padding
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
