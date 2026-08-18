import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'main.dart' show HomeScreen;

/// Port of SplashView.swift + the 2.5s hold in ContentView.swift.
///
/// The logo bounces in with a spring, then the title block fades up. Startup
/// data (saved language, progress) loads in parallel; the splash stays on
/// screen for at least [_minimumDuration] so the animation is never clipped.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _minimumDuration = Duration(milliseconds: 2500);

  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOffset;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleOffset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Logo: scale 0.4 -> 1.0 with a spring-like overshoot, sliding up 30pt.
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.elasticOut),
      ),
    );
    _logoOffset = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOut),
      ),
    );

    // Title block: fades in slightly later, rising 20pt.
    _titleOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.33, 0.75, curve: Curves.easeOut),
    );
    _titleOffset = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.75, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final started = DateTime.now();

    await context.read<LanguageProvider>().loadSavedLanguage();
    if (!mounted) return;
    await context.read<ProgressProvider>().loadProgress();
    if (!mounted) return;
    await context.read<TTSProvider>().loadSettings();
    if (!mounted) return;

    // Hold the splash for the remainder of the minimum duration.
    final elapsed = DateTime.now().difference(started);
    final remaining = _minimumDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD966), // warm yellow
              Color(0xFFFF8C8C), // coral
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(0, _logoOffset.value),
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: _logo(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Opacity(
                          opacity: _titleOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _titleOffset.value),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit,
                                        size: 34, color: Colors.white),
                                    SizedBox(width: 20),
                                    Icon(Icons.brush,
                                        size: 34, color: Colors.white),
                                    SizedBox(width: 20),
                                    Icon(Icons.palette,
                                        size: 34, color: Colors.white),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'EasyStep Kids',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'SAI',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sketch • Art • Imagine',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Opacity(
                        opacity: _titleOpacity.value,
                        child: Text(
                          'easystepkids.com',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// The bundled logo, falling back to a lettermark if the asset is missing
  /// so the splash never renders as a broken image.
  Widget _logo() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.asset(
          'assets/easystepkids.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: const Text(
              'Easy Step Kids',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF8C8C),
              ),
            ),
          ),
        ),
      ),
    );
  }
}