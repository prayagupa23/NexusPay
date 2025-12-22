// H O M E  S C R E E N
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 12),
              _AppBarSection(),
              SizedBox(height: 28),
              HeroCarousel(), // Smaller hero carousel
              SizedBox(height: 32),
              _QuickActions(),
              SizedBox(height: 32),
              _AlertCard(), // Updated to match wireframe exactly
              SizedBox(height: 32),
              _TrustedContacts(),
              SizedBox(height: 110),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// A P P  B A R
class _AppBarSection extends StatelessWidget {
  const _AppBarSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.menu_rounded, size: 28),
          color: AppColors.primaryText,
          onPressed: () {},
        ),
        Text(
          "Appname",
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            shadows: [
              Shadow(
                color: AppColors.primaryBlue.withOpacity(0.35),
                blurRadius: 18,
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.secondarySurface,
          child: Icon(Icons.person_rounded, color: AppColors.primaryText),
        ),
      ],
    );
  }
}

// Q U I C K  A C T I O N S
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      {"icon": Icons.qr_code_scanner_rounded, "label": "Scan QR"},
      {"icon": Icons.send_rounded, "label": "Pay"},
      {"icon": Icons.location_on_rounded, "label": "Heat Map"},
      {"icon": Icons.security_rounded, "label": "Detect"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.asMap().entries.map((entry) {
        final i = entry.key;
        final action = entry.value;

        return Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Icon(
                action["icon"] as IconData,
                color: AppColors.primaryBlue,
                size: 30,
              ),
            )
                .animate(delay: (i * 100).ms)
                .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 10),
            Text(
              action["label"] as String,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            )
                .animate(delay: (i * 120).ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3),
          ],
        );
      }).toList(),
    );
  }
}

// A L E R T   C A R D
class _AlertCard extends StatelessWidget {
  const _AlertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dangerRed.withOpacity(0.7), width: 1.8),
        boxShadow: [
          BoxShadow(color: AppColors.dangerRed.withOpacity(0.35), blurRadius: 24),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.dangerRed.withOpacity(0.2),
            child: const Icon(Icons.person_outline, color: AppColors.dangerRed, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Alert !!",
                      style: TextStyle(color: AppColors.dangerRed, fontSize: 19, fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: AppColors.mutedText,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "An unverified user is attempting to make a transaction.",
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 14.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkSurface,
              foregroundColor: AppColors.primaryText,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("View Profile", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2)
        .then(delay: 800.ms)
        .shake(hz: 4, duration: 600.ms);
  }
}

// T R U S T E D  C O N T A C T S
class _TrustedContacts extends StatelessWidget {
  const _TrustedContacts();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Trusted Contacts", style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.w800)),
            Text("view all", style: TextStyle(color: AppColors.primaryBlue)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (_, i) {
              return CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.secondarySurface,
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.primaryBg,
                  child: Text("P${i + 1}", style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ).animate(delay: (i * 100).ms).fadeIn().slideY(begin: 0.3);
            },
          ),
        ),
      ],
    );
  }
}

// B O T T O M  N A V
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, -10))],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mutedText,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.account_balance_wallet_rounded),
                Positioned(right: 0, top: 0, child: CircleAvatar(radius: 6, backgroundColor: AppColors.primaryBlue)),
              ],
            ),
            label: "Money",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "You"),
        ],
      ),
    );
  }
}

// H E R O  C A R O U S E L
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _controller;
  late final Timer _timer;

  final List<Map<String, dynamic>> slides = [
    {"text": "Real-time AI protection for every transaction.", "painter": MountainSecurePainter()},
    {"text": "Instant fraud alerts before money moves.", "painter": ShieldAlertPainter()},
    {"text": "Stay ahead with trusted contacts & heatmap.", "painter": NetworkTrustPainter()},
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final nextPage = (_controller.page?.round() ?? 0) + 1;
      _controller.animateToPage(
        nextPage >= slides.length ? 0 : nextPage,
        duration: 800.ms,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // Reduced height for compact look
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.35), width: 1.2),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        slide["text"] as String,
                        style: TextStyle(color: AppColors.primaryText, fontSize: 15.5, height: 1.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: CustomPaint(painter: slide["painter"] as CustomPainter),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 700.ms).scale(begin: const Offset(0.97, 0.97), duration: 500.ms);
            },
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final current = _controller.hasClients && _controller.page != null ? _controller.page!.round() : 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                        (i) => AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: i == current ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == current ? AppColors.primaryBlue : AppColors.mutedText,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// C U S T O M  P A I N T E R S
class MountainSecurePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.6)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.2)
      ..lineTo(size.width, size.height);

    canvas.drawPath(path, paint);

    final shieldPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.5 - 16, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..lineTo(size.width * 0.5 + 16, size.height * 0.45)
      ..close();
    canvas.drawPath(shieldPath, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShieldAlertPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.dangerRed.withOpacity(0.7)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2 - 8), 24, paint);
    canvas.drawLine(Offset(size.width / 2, size.height / 2 - 20), Offset(size.width / 2, size.height / 2 + 4), paint..strokeWidth = 7);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2 + 16), 7, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NetworkTrustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.6)
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 12, paint..style = PaintingStyle.fill);

    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * pi / 5;
      final dx = center.dx + 36 * cos(angle);
      final dy = center.dy + 36 * sin(angle);
      canvas.drawCircle(Offset(dx, dy), 10, paint..style = PaintingStyle.fill);
      canvas.drawLine(center, Offset(dx, dy), paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}