import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'main.dart' show HomeScreen;

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
            colors: [Color(0xFFFFD966), Color(0xFFFF8C8C)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return OrientationBuilder(builder: (ctx, orientation) {
                final isLandscape = orientation == Orientation.landscape;
                return Stack(
                  children: [
                    isLandscape
                        ? _landscapeContent()
                        : _portraitContent(),
                    // Footer
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
              });
            },
          ),
        ),
      ),
    );
  }

  // ── Portrait: logo on top, title below ───────────────────────────

  Widget _portraitContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, _logoOffset.value),
            child: Transform.scale(
              scale: _logoScale.value,
              child: _logo(size: 180),
            ),
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: _titleOpacity.value,
            child: Transform.translate(
              offset: Offset(0, _titleOffset.value),
              child: _titleBlock(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Landscape: logo left, title right ────────────────────────────

  Widget _landscapeContent() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, _logoOffset.value),
            child: Transform.scale(
              scale: _logoScale.value,
              child: _logo(size: 130),  // smaller in landscape
            ),
          ),
          const SizedBox(width: 40),
          Opacity(
            opacity: _titleOpacity.value,
            child: Transform.translate(
              offset: Offset(0, _titleOffset.value),
              child: _titleBlock(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared title block ────────────────────────────────────────────

  Widget _titleBlock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 28, color: Colors.white),
            SizedBox(width: 16),
            Icon(Icons.brush, size: 28, color: Colors.white),
            SizedBox(width: 16),
            Icon(Icons.palette, size: 28, color: Colors.white),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'EasyStep Kids',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'SAI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sketch • Art • Imagine',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  // ── Logo widget ───────────────────────────────────────────────────

  Widget _logo({double size = 220}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: Image.asset(
          'assets/easystepkids.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: const Text(
              'Easy\nStep\nKids',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
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