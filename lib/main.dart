import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'models.dart';
import 'paywall_screen.dart';
import 'splash_screen.dart';
import 'tracing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EasyStepKidsApp());
}

class EasyStepKidsApp extends StatelessWidget {
  const EasyStepKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => TTSProvider()),
      ],
      child: MaterialApp(
        title: 'EasyStep Kids',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// ---------------------------------------------------------------- Home

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('EasyStep Kids',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Consumer<LanguageProvider>(
            builder: (context, lp, _) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  lp.currentLanguage.glyph,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer2<LanguageProvider, PurchaseProvider>(
        builder: (context, lp, pp, _) {
          if (lp.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LanguageSelector(langProvider: lp, purchaseProvider: pp),
                const SizedBox(height: 28),
                _CategoryGrid(langProvider: lp),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.langProvider,
    required this.purchaseProvider,
  });

  final LanguageProvider langProvider;
  final PurchaseProvider purchaseProvider;

  @override
  Widget build(BuildContext context) {
    final languages = langProvider.languages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Language',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: languages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final lang = languages[i];
              final selected = langProvider.currentLanguage.id == lang.id;
              final available = purchaseProvider.isLanguageAvailable(lang);

              final card = Container(
                width: 84,
                decoration: BoxDecoration(
                  color: selected ? Colors.blue : Colors.white,
                  border: Border.all(
                    color: selected ? Colors.blue : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lang.glyph,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              lang.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!available)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child:
                        Icon(Icons.lock, size: 14, color: Colors.orange),
                      ),
                  ],
                ),
              );

              return GestureDetector(
                onTap: () {
                  if (available) {
                    langProvider.setLanguage(lang);
                  } else {
                    PaywallScreen.show(context);
                  }
                },
                child: Opacity(opacity: available ? 1 : 0.45, child: card),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.langProvider});

  final LanguageProvider langProvider;

  @override
  Widget build(BuildContext context) {
    final lang = langProvider.currentLanguage;

    // Only show categories that actually have content for this language.
    final categories = Category.values
        .where((c) => langProvider.itemsFor(c).isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Learn',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final category = categories[i];
            final count = langProvider.itemsFor(category).length;

            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TracingScreen(category: category),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: category.tint.withOpacity(0.10),
                  border: Border.all(color: category.tint, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: category.tint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(category.icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        category.localizedTitle(lang.id),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('$count items',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}