import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'personal_details_screen.dart';

class Feature {
  final String name;
  final String description;
  final String imagePath;

  Feature({
    required this.name,
    required this.description,
    required this.imagePath,
  });
}

class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({super.key});

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Feature> _features = [
    Feature(
      name: 'Phishing & Fake Link Detection',
      description: 'Detect scam emails, malicious URLs, and fake UPI IDs with our multi-layered protection system. Combines TF-IDF, Logistic Regression, and Random Forest for accurate, real-time detection.',
      imagePath: 'assets/phishing.png',
    ),
    Feature(
      name: 'Transaction Anomaly Detection',
      description: 'Personalized fraud protection that learns your spending patterns. Flags unusual transactions instantly using XGBoost for real-time security.',
      imagePath: 'assets/anomaly.png',
    ),
    Feature(
      name: 'Visual Analytics & Heatmaps',
      description: 'Interactive heatmaps show fraud trends and risky patterns. Transforms complex ML data into clear, actionable insights for better security decisions.',
      imagePath: 'assets/visual.png',
    ),
    Feature(
      name: 'Extra Security Layer',
      description: 'Enhanced protection with device alerts, payee trust scoring, and instant transaction freezing. Multiple security layers for complete peace of mind.',
      imagePath: 'assets/security.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _features.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) => _buildFeaturePage(_features[index]),
              ),
            ),
            _buildPageIndicator(),
            const SizedBox(height: 40),
            _buildNavigationButtons(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePage(Feature feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            feature.imagePath,
            height: 240,
            width: 240,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 60),
          Text(
            feature.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            feature.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: AppColors.secondaryText(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_features.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: _currentPage == index ? 36 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primaryBlue
                : AppColors.secondarySurface(context),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          OutlinedButton(
            onPressed: _currentPage > 0
                ? () => _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            )
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: _currentPage > 0 ? AppColors.primaryBlue : AppColors.mutedText(context),
              side: BorderSide(
                color: _currentPage > 0 ? AppColors.primaryBlue : AppColors.secondarySurface(context),
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: Text(
              'Previous',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _currentPage > 0 ? AppColors.primaryBlue : AppColors.mutedText(context),
              ),
            ),
          ),

          // Next / Get Started Button
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _features.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PersonalDetailsScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 12,
              shadowColor: AppColors.subtleBlueGlow,
            ),
            child: Text(
              _currentPage == _features.length - 1 ? 'Get Started' : 'Next',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}