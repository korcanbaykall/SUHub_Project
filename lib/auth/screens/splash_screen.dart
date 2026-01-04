import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _pulseController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _logoScale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutBack,
      ),
    );
    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );
    _pulse = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _introController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize =
        (size.shortestSide * 0.32).clamp(120.0, 180.0).toDouble();

    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _logoOpacity,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final pulseScale = 1 + (_pulse.value * 0.02);
                  return Transform.scale(scale: pulseScale, child: child);
                },
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Text(
                    'SUHub',
                    style: AppTextStyles.subtitle,
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
