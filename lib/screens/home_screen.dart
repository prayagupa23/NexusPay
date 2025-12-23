import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'contact_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // T O P  B L A C K  S E C T I O N  (App Bar + Carousel)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    SizedBox(height: 32),
                    _AppBarSection(),
                    SizedBox(height: 8),
                    HeroCarousel(),
                    SizedBox(height: 14),
                  ],
                ),
              ),

              // G R E Y I S H  S E C T I O N (Quick Actions, Alert, Trusted Contacts)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.secondarySurface.withOpacity(0.85),
                  // Greyish background like GPay
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    SizedBox(height: 32),
                    // Small top padding to avoid abrupt edge
                    _QuickActions(),
                    SizedBox(height: 32),
                    _AlertCard(),
                    SizedBox(height: 32),
                    _TrustedContacts(),
                    SizedBox(height: 110),
                    // Space for bottom nav
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
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
      children: const [
        SizedBox(width: 28),
        AnimatedAppTitle(),
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.secondarySurface,
          child: Icon(Icons.person_rounded, color: AppColors.primaryText),
        ),
      ],
    );
  }
}

// A N I M A T E D   A P P  T I T L E

class AnimatedAppTitle extends StatefulWidget {
  const AnimatedAppTitle({super.key});

  @override
  State<AnimatedAppTitle> createState() => _AnimatedAppTitleState();
}

class _AnimatedAppTitleState extends State<AnimatedAppTitle> {
  bool showStatus = false;

  @override
  void initState() {
    super.initState();
    _runOnce();
  }

  void _runOnce() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => showStatus = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => showStatus = false);
  }

  void _restart() {
    setState(() => showStatus = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showStatus = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _restart,
      child: AnimatedSwitcher(
        duration: 450.ms,
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.6),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: showStatus
            ? const Text(
                "Last security check · 3 mins ago",
                key: ValueKey("status"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
              )
            : const Text(
                "App Name",
                key: ValueKey("app"),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                  letterSpacing: -0.6,
                ),
              ),
      ),
    );
  }
}

// Quick Actions wrapped in greyish container to simulate the lower background
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface.withOpacity(0.7),
        // Greyish background like GPay lower section
        borderRadius: BorderRadius.circular(28),
      ),
      child: const _QuickActions(),
    );
  }
}

// Q U I C K  A C T I O N
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      {"icon": Icons.qr_code_scanner_rounded, "label": "Scan any\nQR code"},
      {"icon": Icons.payment_rounded, "label": "Pay\nanyone"},
      {"icon": Icons.location_on_rounded, "label": "Heat\nMaps"},
      {"icon": Icons.security_rounded, "label": "Fraud\nDetect"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.asMap().entries.map((e) {
        return Column(
          children: [
            Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    e.value["icon"] as IconData,
                    color: Colors.white,
                    size: 32,
                  ),
                )
                .animate(delay: (e.key * 120).ms)
                .scale(begin: const Offset(0.85, 0.85)),
            const SizedBox(height: 8),
            Text(
              e.value["label"] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// A L E R T  C A R D

class _AlertCard extends StatelessWidget {
  const _AlertCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.dangerBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.dangerRed, width: 1.4),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.dangerRed.withOpacity(0.2),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.dangerRed,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Unverified user is attempting a transaction.",
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Review the profile before proceeding.",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  "View Profile",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -5,
          right: 1,
          child: IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            color: AppColors.mutedText,
            onPressed: () {},
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.15);
  }
}

// T R U S T E D  C O N T A C T S

class _TrustedContacts extends StatelessWidget {
  const _TrustedContacts();

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {"name": "Parth S Salunke", "upi": "814329@fam"},
      {"name": "Rahul Patil", "upi": "rahul@upi"},
      {"name": "Amit Shah", "upi": "amit@ybl"},
      {"name": "Sneha Kulkarni", "upi": "sneha@upi"},
      {"name": "Riya Mehta", "upi": "riya@upi"},
      {"name": "Om Deshmukh", "upi": "om@upi"},
      {"name": "Kunal Jain", "upi": "kunal@upi"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Trusted Contacts",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            Text(
              "View all",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: contacts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
          ),
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return _ContactAvatar(
              name: contact["name"]!,
              upiId: contact["upi"]!,
            );
          },
        ),
      ],
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final String name;
  final String upiId;

  const _ContactAvatar({
    required this.name,
    required this.upiId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContactDetailScreen(
              name: name,
              upiId: upiId,
            ),
          ),
        );
      },
      child: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.secondarySurface,
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}


// B O T T O M  N A V
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectedIndex = 0;

  Widget item(int i, IconData icon, String label) {
    final selected = selectedIndex == i;
    return InkWell(
      onTap: () => setState(() => selectedIndex = i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: 250.ms,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryBlue.withOpacity(0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: selected ? AppColors.primaryBlue : AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: selected ? AppColors.primaryBlue : AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          item(0, Icons.home_rounded, "Home"),
          item(1, Icons.account_balance_wallet_rounded, "Money"),
          item(2, Icons.person_rounded, "You"),
        ],
      ),
    );
  }
}

// H E R O C A R O U S E L
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _controller;
  late final Timer _timer;

  final List<Map<String, dynamic>> slides = [
    {
      "text": "Real-time AI protection for every transaction.",
      "painter": MountainSecurePainter(),
    },
    {
      "text": "Instant fraud alerts before money moves.",
      "painter": ShieldAlertPainter(),
    },
    {
      "text": "Stay ahead with trusted contacts & heatmap.",
      "painter": NetworkTrustPainter(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 1.0, // Full-width carousel
    );

    // Optional auto-slide timer
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final nextPage = (_controller.page?.round() ?? 0) + 1;
      _controller.animateToPage(
        nextPage >= slides.length ? 0 : nextPage,
        duration: const Duration(milliseconds: 200),
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
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            physics: const BouncingScrollPhysics(), // Allow manual sliding
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black, // Keep original color scheme
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        slide["text"] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: CustomPaint(
                        painter: slide["painter"] as CustomPainter,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Page indicators
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final current = _controller.hasClients && _controller.page != null
                    ? _controller.page!.round()
                    : 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                        (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
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

// Custom Painters - unchanged and working
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
