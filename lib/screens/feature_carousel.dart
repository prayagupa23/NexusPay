import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'personal_details_screen.dart';

class Feature {
  final String name;
  final String description;
  final String imagePath;

  Feature({required this.name, required this.description, required this.imagePath});
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _features.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return _buildFeaturePage(_features[index]);
              },
            ),
          ),
          _buildPageIndicator(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildFeaturePage(Feature feature) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            feature.imagePath,
            height: 140,
            width: 140,
          ),
          const SizedBox(height: 40),
          Text(
            feature.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            feature.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_features.length, (index) {
        return Container(
          margin: const EdgeInsets.all(8.0),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? theme.primaryColor
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              if (_currentPage > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Text(
              'Previous',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_currentPage < _features.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                // Navigate to HomeScreen when on last slide
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()),
                );
              }
            },
            child: Text(
              _currentPage == _features.length - 1 ? 'Get Started' : 'Next',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}