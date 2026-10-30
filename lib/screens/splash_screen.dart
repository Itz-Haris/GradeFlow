import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

/// Animated Splash Screen with GradeFlow custom branding.
/// Combines a graduation cap and progress chart symbol, animated smoothly.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for animation and smooth transition
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Stack(
        children: [
          // Subtle background decorative glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryElectric.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentCyan.withOpacity(0.12),
              ),
            ),
          ),

          // Central Animated Brand Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Custom Logo (Mortarboard Cap + Progress Chart)
                    Container(
                      width: 104,
                      height: 104,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.electricCyanGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryElectric.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: GradeFlowLogoPainter(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name
                    const Text(
                      'GradeFlow',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    const Text(
                      'Your Marks, Your Progress.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.accentCyanLight,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Academic Metadata Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: const Text(
                        'Robotics & Automation • DL&A Unit 6',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom loading animation indicator
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.accentCyan.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter rendering the unique GradeFlow emblem:
/// A Graduation Cap combined with an upward rising progress bar chart.
class GradeFlowLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokeWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // 1. Graduation Cap (Mortarboard Top Diamond)
    final path = Path();
    path.moveTo(w * 0.5, h * 0.08); // Top vertex
    path.lineTo(w * 0.95, h * 0.28); // Right vertex
    path.lineTo(w * 0.5, h * 0.48); // Bottom vertex
    path.lineTo(w * 0.05, h * 0.28); // Left vertex
    path.close();
    canvas.drawPath(path, paintWhite);

    // Tassel hanging on the right side
    final tasselPath = Path();
    tasselPath.moveTo(w * 0.92, h * 0.30);
    tasselPath.lineTo(w * 0.96, h * 0.52);
    canvas.drawPath(tasselPath, strokeWhite);
    canvas.drawCircle(Offset(w * 0.96, h * 0.54), 2.2, paintWhite);

    // 2. Rising Progress Chart Bars below the cap
    final barPaint = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.fill;

    const barWidthRatio = 0.14;
    final barW = w * barWidthRatio;
    final gap = w * 0.08;
    final startX = w * 0.16;

    // Bar 1 (Lowest)
    final r1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(startX, h * 0.74, barW, h * 0.22),
      const Radius.circular(3),
    );
    canvas.drawRRect(r1, barPaint);

    // Bar 2 (Medium)
    final r2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(startX + barW + gap, h * 0.62, barW, h * 0.34),
      const Radius.circular(3),
    );
    canvas.drawRRect(r2, barPaint);

    // Bar 3 (Highest)
    final r3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(startX + (barW + gap) * 2, h * 0.50, barW, h * 0.46),
      const Radius.circular(3),
    );
    canvas.drawRRect(r3, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
