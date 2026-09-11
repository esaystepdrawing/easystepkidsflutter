import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'data/content_dataset.dart';
import 'models.dart';
import 'tracing_screen.dart';
import 'splash_screen.dart';
import 'paywall_screen.dart';
import 'sound_help_sheet.dart';
import 'puzzle_screen.dart';
import 'sound_screen.dart';
import 'free_draw_screen.dart';
import 'xylophone_screen.dart';
import 'promo_banner.dart';
import 'line_tracing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TTSProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: const EasyStepKidsApp(),
    ),
  );
}

// ── App ───────────────────────────────────────────────────────────────

class EasyStepKidsApp extends StatelessWidget {
  const EasyStepKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyStep Kids',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
      home: const SplashWrapper(),
    );
  }
}

// ── Splash → Home ─────────────────────────────────────────────────────

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: _showSplash ? const SplashScreen() : const HomeScreen(),
    );
  }
}

// ── Home Screen ───────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppLanguage> get _filtered {
    final q = _search.toLowerCase();
    if (q.isEmpty) return ContentDataset.languages;
    return ContentDataset.languages
        .where((l) =>
    l.name.toLowerCase().contains(q) ||
        l.nativeName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final purchase = context.watch<PurchaseProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F5FF), Color(0xFFEFF8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: OrientationBuilder(builder: (ctx, orientation) {
            final isTablet = MediaQuery.of(ctx).size.shortestSide > 600;
            final isLandscape = orientation == Orientation.landscape;

            if (isLandscape && !isTablet) {
              // ── Phone landscape: compact left rail + right grid ──
              return Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Compact logo row
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.asset(
                                    'assets/easystepkids.jpeg',
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.school,
                                        size: 36,
                                        color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text('EasyStep Kids',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1A1A2E))),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up_outlined,
                                      size: 18),
                                  color: Colors.blue,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _showSoundHelp(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Compact search
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.07),
                                      blurRadius: 4)
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (v) => setState(() => _search = v),
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12),
                                  prefixIcon: const Icon(Icons.search,
                                      color: Colors.grey, size: 16),
                                  suffixIcon: _search.isNotEmpty
                                      ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.grey, size: 14),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _search = '');
                                      })
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 6),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Promo banner
                            const EasyStepDrawingBanner(),
                            const SizedBox(height: 4),
                            _freeDrawButton(context),
                            _AppFooter(
                                onSoundHelp: () => _showSoundHelp(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Right: language grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                      child: Column(
                        children: [
                          const Text('Pick a Language',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 6),
                          Expanded(child: _languageGrid(purchase, context)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // ── Portrait (phone + tablet) ──
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _header(context, isTablet: isTablet),
                ),
                const SizedBox(height: 8),
                Expanded(child: _languageGrid(purchase, context)),
                const EasyStepDrawingBanner(),
                _freeDrawButton(context),
                _AppFooter(onSoundHelp: () => _showSoundHelp(context)),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────

  Widget _header(BuildContext context, {required bool isTablet}) {
    final logoSize = isTablet ? 72.0 : 56.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(logoSize * 0.22),
              child: Image.asset(
                'assets/easystepkids.jpeg',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                    Icons.school,
                    size: logoSize,
                    color: Colors.blue),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EasyStep Kids',
                      style: TextStyle(
                          fontSize: isTablet ? 28.0 : 22.0,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1A2E))),
                  Text('SAI — Sketch, Art, Imagine',
                      style: TextStyle(
                          fontSize: isTablet ? 14.0 : 11.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up_outlined),
              color: Colors.blue,
              iconSize: isTablet ? 28 : 24,
              tooltip: 'Sound help',
              onPressed: () => _showSoundHelp(context),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _search = v),
            style: TextStyle(fontSize: isTablet ? 16 : 14),
            decoration: InputDecoration(
              hintText: 'Search languages...',
              hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: isTablet ? 16 : 14),
              prefixIcon: Icon(Icons.search,
                  color: Colors.grey, size: isTablet ? 26 : 22),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _search = '');
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  vertical: isTablet ? 18 : 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Pick a Language',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: isTablet ? 26.0 : 18.0,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E))),
      ],
    );
  }

  // ── Language grid ─────────────────────────────────────────────────

  Widget _languageGrid(PurchaseProvider purchase, BuildContext context) {
    if (_filtered.isEmpty) {
      return Center(
        child: Text('No language found for "$_search"',
            style: TextStyle(color: Colors.grey.shade500)),
      );
    }
    // Single result — show centered card instead of grid
    if (_filtered.length == 1) {
      final lang = _filtered.first;
      final isLocked = !lang.isFree && !purchase.isUnlocked;
      return Center(
        child: SizedBox(
          width: 180,
          height: 200,
          child: _LanguageCard(
            language: lang,
            locked: isLocked,
            onTap: () {
              if (isLocked) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PaywallScreen()));
              } else {
                _openLanguage(context, lang);
              }
            },
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.9,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, i) {
        final lang = _filtered[i];
        final isLocked = !lang.isFree && !purchase.isUnlocked;
        return _LanguageCard(
          language: lang,
          locked: isLocked,
          onTap: () {
            if (isLocked) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PaywallScreen()));
            } else {
              _openLanguage(context, lang);
            }
          },
        );
      },
    );
  }

  // ── Free Draw button ──────────────────────────────────────────────

  Widget _freeDrawButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const FreeDrawScreen())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFFA855F7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.brush, color: Colors.white),
              SizedBox(width: 10),
              Text('Free Draw',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  void _openLanguage(BuildContext context, AppLanguage lang) {
    context.read<LanguageProvider>().setLanguage(lang);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => CategoryScreen(language: lang)),
    );
  }

  void _showSoundHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SoundHelpSheet(),
    );
  }
}

// ── Language card ─────────────────────────────────────────────────────

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.locked,
    required this.onTap,
  });

  final AppLanguage language;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language.glyph,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: locked ? Colors.grey : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(language.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(language.nativeName,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11)),
                  if (language.isFree)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('FREE',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ),
                ],
              ),
            ),
            if (locked)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.lock,
                    color: Colors.orange.shade400, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Category Screen ───────────────────────────────────────────────────

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({required this.language, super.key});
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.name)),
      body: Container(
        color: const Color(0xFFF7F5FF),
        child: OrientationBuilder(builder: (ctx, orientation) {
          final isTablet = MediaQuery.of(ctx).size.shortestSide > 600;
          final isLandscape = orientation == Orientation.landscape;
          return (isLandscape && !isTablet)
              ? _landscapeLayout(ctx)
              : _portraitLayout(ctx);
        }),
      ),
    );
  }

  Widget _portraitLayout(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            language.nativeName,
            style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.blue),
          ),
        ),
        Expanded(child: _categoryGrid(context)),
        _puzzleButton(context),
        _AppFooter(onSoundHelp: () => _openSoundHelp(context)),
      ],
    );
  }

  Widget _landscapeLayout(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 260,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      language.nativeName,
                      style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                _puzzleButton(context),
                const SizedBox(height: 6),
                _AppFooter(onSoundHelp: () => _openSoundHelp(context)),
              ],
            ),
          ),
        ),
        const VerticalDivider(
            width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        Expanded(child: _categoryGrid(context)),
      ],
    );
  }

  Widget _categoryGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: Category.values.length,
      itemBuilder: (context, i) {
        final cat = Category.values[i];
        return _CategoryCard(
          category: cat,
          language: language,
          onTap: () {
            if (cat == Category.sounds) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SoundScreen()));
            } else if (cat == Category.xylophone) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const XylophoneScreen()));
            } else if (cat == Category.lines) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LineTracingScreen()),
              );
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TracingScreen(category: cat)));
            }
          },
        );
      },
    );
  }

  Widget _puzzleButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PuzzleScreen())),
        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9333EA), Color(0xFF4F46E5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gamepad, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Puzzle Game',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _openSoundHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SoundHelpSheet(),
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.language,
    required this.onTap,
  });

  final Category category;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.tint;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.iconEmoji,
                style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 4),
            Text(
              category.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.localizedTitle(language.id),
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App footer ────────────────────────────────────────────────────────

class _AppFooter extends StatelessWidget {
  const _AppFooter({required this.onSoundHelp});
  final VoidCallback onSoundHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onSoundHelp,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border:
                Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up, size: 12, color: Colors.blue),
                  SizedBox(width: 4),
                  Text('Sound not working?',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Text('easystepkids.com',
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}