# EasyStep Kids → Flutter for Android
## Codebase-Specific Conversion Guide

Based on analysis of your iOS app structure.

---

## Architecture Overview

### Current iOS Stack
- **App Entry**: SwiftUI (kidsApp.swift)
- **State Management**: @Published, @Observable, ObservableObject (Combine)
- **TTS**: AVFoundation.AVSpeechSynthesizer (offline)
- **In-App Purchases**: StoreKit 2
- **Drawing**: Core Graphics via CustomPaint
- **Persistence**: UserDefaults → SharedPreferences

### Flutter Equivalent
```
Main Entry → MaterialApp → Multi-screen Navigation
State: Provider (analogous to @Published)
TTS: flutter_tts (analogous to AVSpeechSynthesizer)
IAP: google_play_billing (analogous to StoreKit 2)
Drawing: CustomPaint (same concept)
Persistence: shared_preferences
```

---

## Step-by-Step Conversion

### Phase 1: Project Setup

```bash
flutter create easystep_kids_flutter
cd easystep_kids_flutter
flutter pub get
```

#### pubspec.yaml

```yaml
name: easystep_kids
description: Learn alphabets, numbers, and words in 10+ languages
version: 1.0.0+1
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # TTS (equivalent to AVSpeechSynthesizer)
  flutter_tts: ^0.14.0

  # Google Play Billing (equivalent to StoreKit 2)
  google_play_billing: ^1.0.0

  # State Management (equivalent to @Published)
  provider: ^6.0.0

  # Persistence (equivalent to UserDefaults)
  shared_preferences: ^2.2.0

  # UI & Navigation
  cupertino_icons: ^1.0.8
  google_fonts: ^6.0.0

  # Storage & serialization
  json_serializable: ^6.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

---

### Phase 2: Data Models (AppLanguage, TraceItem, Category)

#### lib/models/models.dart

```dart
import 'package:flutter/material.dart';

// Equivalent to Models.swift

class AppLanguage {
  final String id;           // "en", "hi", "te", etc.
  final String name;         // "English", "Hindi"
  final String nativeName;   // "हिन्दी"
  final String speechCode;   // "hi-IN" for TTS
  final String glyph;        // "ह"
  final bool hasLetterCase;

  const AppLanguage({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.speechCode,
    required this.glyph,
    required this.hasLetterCase,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLanguage && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// All supported languages (from your iOS app)
class LanguageRepository {
  static final List<AppLanguage> all = [
    AppLanguage(
      id: 'en',
      name: 'English',
      nativeName: 'English',
      speechCode: 'en-US',
      glyph: 'A',
      hasLetterCase: true,
    ),
    AppLanguage(
      id: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      speechCode: 'hi-IN',
      glyph: 'ह',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'te',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      speechCode: 'te-IN',
      glyph: 'త',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      speechCode: 'ta-IN',
      glyph: 'த',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      speechCode: 'gu-IN',
      glyph: 'ગ',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      speechCode: 'es-ES',
      glyph: 'A',
      hasLetterCase: true,
    ),
    AppLanguage(
      id: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      speechCode: 'de-DE',
      glyph: 'A',
      hasLetterCase: true,
    ),
    AppLanguage(
      id: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      speechCode: 'ur-PK',
      glyph: 'ا',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'mr',
      name: 'Marathi',
      nativeName: 'मराठी',
      speechCode: 'mr-IN',
      glyph: 'म',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      speechCode: 'ja-JP',
      glyph: 'あ',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'zh',
      name: 'Chinese',
      nativeName: '中文',
      speechCode: 'zh-CN',
      glyph: '中',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'ml',
      name: 'Malayalam',
      nativeName: 'മലയാളം',
      speechCode: 'ml-IN',
      glyph: 'മ',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'kn',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      speechCode: 'kn-IN',
      glyph: 'ಕ',
      hasLetterCase: false,
    ),
    AppLanguage(
      id: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
      speechCode: 'pt-BR',
      glyph: 'A',
      hasLetterCase: true,
    ),
    AppLanguage(
      id: 'fr',
      name: 'French',
      nativeName: 'Français',
      speechCode: 'fr-FR',
      glyph: 'A',
      hasLetterCase: true,
    ),
  ];

  static AppLanguage findById(String id) {
    return all.firstWhere((l) => l.id == id, orElse: () => all.first);
  }
}

// Category (equivalent to enum Category in Models.swift)
enum Category {
  alphabets,
  numbers,
  words,
  days,
  colors,
  shapes,
  months,
}

extension CategoryX on Category {
  String get title {
    switch (this) {
      case Category.alphabets:
        return 'Alphabets';
      case Category.numbers:
        return 'Numbers';
      case Category.words:
        return 'Words';
      case Category.days:
        return 'Days of the Week';
      case Category.colors:
        return 'Colors';
      case Category.shapes:
        return 'Shapes';
      case Category.months:
        return 'Months';
    }
  }

  String get icon {
    switch (this) {
      case Category.alphabets:
        return 'textformat.abc';
      case Category.numbers:
        return 'number';
      case Category.words:
        return 'text.book.closed';
      case Category.days:
        return 'calendar';
      case Category.colors:
        return 'palette';
      case Category.shapes:
        return 'square';
      case Category.months:
        return 'date_range';
    }
  }

  Color get tint {
    switch (this) {
      case Category.alphabets:
        return Colors.blue;
      case Category.numbers:
        return Colors.orange;
      case Category.words:
        return Colors.green;
      case Category.days:
        return Colors.purple;
      case Category.colors:
        return Colors.pink;
      case Category.shapes:
        return Colors.teal;
      case Category.months:
        return Colors.indigo;
    }
  }

  String? localizedTitle(String languageId) {
    final translations = {
      'hi': {
        'alphabets': 'वर्णमाला',
        'numbers': 'अंक',
        'words': 'शब्द',
        'days': 'सप्ताह के दिन',
        'colors': 'रंग',
        'shapes': 'आकृतियाँ',
        'months': 'महीने',
      },
      'te': {
        'alphabets': 'అక్షరమాల',
        'numbers': 'అంకెలు',
        'words': 'పదాలు',
        'days': 'వారపు రోజులు',
        'colors': 'రంగులు',
        'shapes': 'ఆకారాలు',
        'months': 'నెలలు',
      },
      // ... add other language translations from your iOS app
    };

    return translations[languageId]?[toString().split('.').last];
  }
}

// TraceItem (equivalent to struct TraceItem in Models.swift)
class TraceItem {
  final String display;  // What is shown on screen to trace
  final String spoken;   // What the speech synthesizer says
  final String? colorKey;
  final String? shapeKey;

  TraceItem(
    this.display, {
    String? spoken,
    this.colorKey,
    this.shapeKey,
  }) : spoken = spoken ?? display;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraceItem &&
          runtimeType == other.runtimeType &&
          display == other.display;

  @override
  int get hashCode => display.hashCode;
}

// Item Colors (equivalent to enum ItemColors in Models.swift)
class ItemColors {
  static final Map<String, Color> map = {
    'red': Colors.red,
    'orange': Colors.orange,
    'yellow': const Color.fromARGB(255, 242, 191, 0),
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'black': Colors.black,
  };

  static Color get(String? key) {
    if (key == null) return Colors.transparent;
    return map[key] ?? Colors.transparent;
  }
}
```

---

### Phase 3: TTS Service (equivalent to SpeechManager)

#### lib/services/tts_service.dart

```dart
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  late FlutterTts _tts;

  factory TTSService() {
    return _instance;
  }

  TTSService._internal() {
    _tts = FlutterTts();
    _initialize();
  }

  Future<void> _initialize() async {
    // Equivalent to AVAudioSession setup in SpeechManager
    await _tts.setLanguage('en-US');
    await _tts.setRate(0.38);  // Kid-friendly pace (same as iOS)
    await _tts.setPitch(1.1);
    
    // Don't use audio ducking (play over other audio)
    // This is platform-specific, handled in Android native code
  }

  /// Speak text in specified language (equivalent to speak(_:languageCode:))
  Future<void> speak(String text, String languageCode) async {
    try {
      await _tts.setLanguage(languageCode);
      await _tts.speak(text);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  /// Stop speaking (equivalent to stop())
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Get available voices for fallback (equivalent to speechVoices())
  Future<List<String>> getLanguages() async {
    try {
      final langs = await _tts.getLanguages;
      return List<String>.from(langs ?? []);
    } catch (e) {
      print('Error getting languages: $e');
      return [];
    }
  }
}
```

#### Android Setup for TTS (android/app/build.gradle)

```gradle
dependencies {
    // TTS native support
    implementation 'androidx.core:core:1.6.0'
}
```

#### android/app/src/main/AndroidManifest.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.easystep_kids">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <application
        android:label="EasyStep Kids"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

### Phase 4: Store/Purchase Manager (equivalent to StoreManager)

#### lib/services/purchase_service.dart

```dart
import 'package:google_play_billing/google_play_billing.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  late GooglePlayBilling _billing;

  // Product ID (must match Google Play Console)
  static const String unlockProductId = 'com.easystepkids.app.alllanguages';

  factory PurchaseService() {
    return _instance;
  }

  PurchaseService._internal() {
    _billing = GooglePlayBilling();
  }

  /// Initialize billing (must be called once)
  Future<void> initialize() async {
    try {
      // Listen for purchases (equivalent to listenForTransactions in StoreManager)
      _billing.onProductPurchased.listen((purchase) {
        _handlePurchaseUpdate(purchase);
      });
    } catch (e) {
      print('Billing init error: $e');
    }
  }

  /// Fetch product details (equivalent to loadProduct())
  Future<ProductDetails?> fetchProduct() async {
    try {
      final products = await _billing.queryProductDetails([unlockProductId]);
      return products.isNotEmpty ? products.first : null;
    } catch (e) {
      print('Failed to fetch product: $e');
      return null;
    }
  }

  /// Purchase product (equivalent to purchase())
  Future<void> purchaseProduct() async {
    try {
      await _billing.buyNonConsumable(productId: unlockProductId);
    } catch (e) {
      print('Purchase error: $e');
    }
  }

  /// Restore purchases (equivalent to restore())
  Future<void> restorePurchases() async {
    try {
      // In Android, purchases are automatically restored via Google Play
      // This is mainly for iOS compatibility
    } catch (e) {
      print('Restore error: $e');
    }
  }

  /// Check if product is owned (equivalent to refreshEntitlement())
  Future<bool> isUnlocked() async {
    try {
      final purchases = await _billing.queryPastPurchases();
      return purchases.any((p) => p.productId == unlockProductId);
    } catch (e) {
      print('Query error: $e');
      return false;
    }
  }

  void _handlePurchaseUpdate(PurchaseDetails purchase) {
    // Handle successful purchase
    print('Purchase completed: ${purchase.productId}');
  }
}
```

---

### Phase 5: State Management with Provider

#### lib/providers/app_state.dart

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/tts_service.dart';
import '../services/purchase_service.dart';

// Language Provider (equivalent to selected language state)
class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = LanguageRepository.all.first;

  AppLanguage get currentLanguage => _currentLanguage;

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    
    // Persist selection
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language.id);
    
    // Update TTS language
    await TTSService().speak('', language.speechCode);
    
    notifyListeners();
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('selected_language') ?? 'en';
    _currentLanguage = LanguageRepository.findById(savedId);
    notifyListeners();
  }
}

// Purchase Provider (equivalent to StoreManager)
class PurchaseProvider extends ChangeNotifier {
  late PurchaseService _purchaseService;
  bool _isUnlocked = false;
  bool _isLoading = false;
  String? _error;

  bool get isUnlocked => _isUnlocked;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PurchaseProvider() {
    _purchaseService = PurchaseService();
    _initialize();
  }

  Future<void> _initialize() async {
    await _purchaseService.initialize();
    await checkUnlockStatus();
  }

  /// Check if language pack is unlocked (equivalent to isAvailable())
  bool isLanguageAvailable(AppLanguage language) {
    return language.id == 'en' || _isUnlocked;
  }

  Future<void> checkUnlockStatus() async {
    _isUnlocked = await _purchaseService.isUnlocked();
    notifyListeners();
  }

  Future<void> purchase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _purchaseService.purchaseProduct();
      await checkUnlockStatus();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restore() async {
    try {
      await _purchaseService.restorePurchases();
      await checkUnlockStatus();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

// Progress Provider (track completed items)
class ProgressProvider extends ChangeNotifier {
  Map<String, Set<String>> _completed = {};

  bool isCompleted(String languageId, String itemText) {
    return _completed[languageId]?.contains(itemText) ?? false;
  }

  void markComplete(String languageId, String itemText) async {
    _completed.putIfAbsent(languageId, () => {});
    _completed[languageId]!.add(itemText);
    notifyListeners();
    await _saveProgress();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _completed.map((lang, items) =>
        MapEntry(lang, items.toList()));
    // Save to SharedPreferences
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // Load from SharedPreferences
  }
}
```

---

### Phase 6: Main App Entry Point

#### lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tracing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EasyStepKidsApp());
}

class EasyStepKidsApp extends StatelessWidget {
  const EasyStepKidsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp(
        title: 'EasyStep Kids',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'GoogleSans',
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/tracing': (_) => const TracingScreen(),
        },
      ),
    );
  }
}
```

---

### Phase 7: Screens

#### lib/screens/splash_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  Future<void> _loadAppData() async {
    // Load saved language & purchases
    if (!mounted) return;
    await context.read<LanguageProvider>().loadSavedLanguage();
    await context.read<ProgressProvider>().loadProgress();

    // Navigate to home
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/app_logo.png', width: 200),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

#### lib/screens/home_screen.dart (sketch)

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EasyStep Kids')),
      body: Consumer2<LanguageProvider, PurchaseProvider>(
        builder: (context, langProvider, purchaseProvider, _) {
          final language = langProvider.currentLanguage;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Language selector
                _buildLanguagePicker(context, langProvider),
                // Category grid
                _buildCategoryGrid(context, purchaseProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguagePicker(
    BuildContext context,
    LanguageProvider provider,
  ) {
    // Language dropdown/picker UI
    return const SizedBox();
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    PurchaseProvider provider,
  ) {
    // Grid of categories (alphabets, numbers, words, etc.)
    // Use Category enum to loop through
    return const SizedBox();
  }
}
```

---

### Phase 8: Tracing Canvas (Custom Drawing)

#### lib/widgets/tracing_canvas.dart

```dart
import 'package:flutter/material.dart';

class TracingCanvas extends StatefulWidget {
  final String guideText;
  final String languageId;
  final Function(bool) onComplete;

  const TracingCanvas({
    required this.guideText,
    required this.languageId,
    required this.onComplete,
  });

  @override
  State<TracingCanvas> createState() => _TracingCanvasState();
}

class _TracingCanvasState extends State<TracingCanvas> {
  late List<Offset?> _points;
  late List<List<Offset?>> _strokes;

  @override
  void initState() {
    super.initState();
    _points = [];
    _strokes = [];
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_points.isNotEmpty) {
      setState(() {
        _strokes.add(List.from(_points));
        _points = [];
      });
    }
  }

  void _clear() {
    setState(() {
      _points = [];
      _strokes = [];
    });
  }

  void _submit() {
    // Mark as complete
    widget.onComplete(true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Stack(
        children: [
          // Guide text (dotted, faint)
          Positioned.fill(
            child: DottedTextWidget(
              text: widget.guideText,
              opacity: 0.15,
            ),
          ),
          // Canvas for user strokes
          Positioned.fill(
            child: CustomPaint(
              painter: StrokePainter(_strokes, _points),
            ),
          ),
          // Control buttons
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _clear,
              mini: true,
              child: const Icon(Icons.clear),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _submit,
              mini: true,
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

class StrokePainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final List<Offset?> currentPoints;

  StrokePainter(this.strokes, this.currentPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw completed strokes
    for (var stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        if (stroke[i] != null && stroke[i + 1] != null) {
          canvas.drawLine(stroke[i]!, stroke[i + 1]!, paint);
        }
      }
    }

    // Draw current stroke
    for (int i = 0; i < currentPoints.length - 1; i++) {
      if (currentPoints[i] != null && currentPoints[i + 1] != null) {
        canvas.drawLine(currentPoints[i]!, currentPoints[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) => true;
}

class DottedTextWidget extends StatelessWidget {
  final String text;
  final double opacity;

  const DottedTextWidget({
    required this.text,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedTextPainter(text, opacity),
      size: Size.infinite,
    );
  }
}

class DottedTextPainter extends CustomPainter {
  final String text;
  final double opacity;

  DottedTextPainter(this.text, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size.height * 0.7,
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(DottedTextPainter oldDelegate) =>
      text != oldDelegate.text;
}
```

---

## Google Play Store Submission

### Step 1: Generate Release Build

```bash
# Build AAB (recommended for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Step 2: Setup Signing

Create `android/key.properties`:

```properties
storeFile=/path/to/easystep-key.jks
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=easystep
```

Generate key (one-time):

```bash
keytool -genkey -v -keystore ~/easystep-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias easystep
```

### Step 3: Play Store Configuration

**Gradle (android/app/build.gradle):**

```gradle
android {
    compileSdkVersion 34
    ndkVersion "25.1.8937393"

    defaultConfig {
        applicationId "com.easystepkids.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"

        // For TTS language support
        resConfigs "en", "hi", "te", "ta", "gu", "es", "de", "ur", "mr", "ja", "zh"
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Step 4: Create Play Store Listing

1. **App Title**: EasyStep Kids (SAI — Sketch, Art, Imagine)
2. **Short Description**: Learn alphabets and handwriting in 15+ languages
3. **Full Description**:
```
🎨 Learn to trace alphabets, numbers, and words!

EasyStep Kids helps children practice handwriting and letter tracing across 15+ languages:

✨ Features
• Interactive tracing for letters, numbers, words, and shapes
• Real-time voice pronunciation (fully offline)
• Supports 15+ languages: English, Hindi, Telugu, Tamil, Gujarati, Spanish, German, Urdu, Marathi, Japanese, Chinese, Malayalam, Kannada, Portuguese, and French
• Beautiful, kid-friendly interface
• Offline-first (no internet required)
• Colorful, engaging activities

📚 Content Categories
• Alphabets/Characters
• Numbers
• Vocabulary Words
• Days of the Week
• Colors
• Shapes
• Months

🎯 Perfect for ages 3-8

Download now and start learning! 🚀
```

4. **Screenshots** (5-8 per language, minimum):
   - Splash screen
   - Language selection
   - Category grid
   - Tracing screen
   - Color learning
   - Progress view

5. **Feature Graphic** (1024x500px)
6. **Content Rating**: Apply (COPPA-compliant for kids)
7. **Privacy Policy**: [Create simple privacy policy for kids app]

### Step 5: Upload to Play Store

```bash
# Use Play Console web UI or:
fastlane supply init  # For automation
```

---

## Testing Checklist

- [ ] TTS works offline in all supported languages
- [ ] Languages load correctly
- [ ] In-app purchase works (test in sandbox account)
- [ ] Tracing canvas is responsive
- [ ] Progress persists after app restart
- [ ] No crashes on low-end devices (Android 5.0+)
- [ ] Permissions handled correctly
- [ ] App resizes properly on different screen sizes
- [ ] Back button behavior is correct

---

## Estimated Timeline

| Phase | Task | Timeline |
|-------|------|----------|
| 1-2 | Setup + Models | 2 days |
| 3-4 | TTS + Purchases | 3 days |
| 5-6 | State & Main App | 2 days |
| 7-8 | Screens & Canvas | 4 days |
| 9 | Testing & Polish | 3 days |
| 10 | Play Store Setup | 2 days |
| **Total** | | **~16 days** |

---

## Key Swift→Flutter Mappings

| iOS (Swift) | Android (Flutter) |
|------------|-------------------|
| @Published / @StateObject | ChangeNotifier + Provider |
| AVSpeechSynthesizer | flutter_tts |
| StoreKit 2 | google_play_billing |
| Core Graphics CustomPaint | CustomPaint (same concept) |
| UserDefaults | shared_preferences |
| SwiftUI Views | StatelessWidget / StatefulWidget |

---

## Resources

- [Flutter TTS Docs](https://pub.dev/packages/flutter_tts)
- [Google Play Billing Integration](https://pub.dev/packages/google_play_billing)
- [Provider State Management](https://pub.dev/packages/provider)
- [CustomPaint Tutorial](https://flutter.dev/docs/development/ui/advanced/custom-paint)
- [Google Play Submission Guide](https://support.google.com/googleplay/android-developer/answer/113469)
- [Kids App Compliance](https://support.google.com/googleplay/android-developer/answer/10787469)

