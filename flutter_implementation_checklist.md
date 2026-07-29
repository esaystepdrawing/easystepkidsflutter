# EasyStep Kids Flutter → Google Play Store
## Quick-Start Implementation Checklist

---

## Week 1: Foundation

### Day 1-2: Project Setup
- [ ] `flutter create easystep_kids_flutter`
- [ ] Update `pubspec.yaml` with all dependencies
- [ ] Create folder structure (models/, services/, providers/, screens/, widgets/)
- [ ] Test: `flutter pub get` and `flutter run`

### Day 3: Data Models
- [ ] Implement `AppLanguage` class (15 languages from iOS app)
- [ ] Implement `Category` enum with extensions
- [ ] Implement `TraceItem` class
- [ ] Implement `ItemColors` color map
- [ ] Copy all language/category data from your iOS app's `ContentDataset.swift`

### Day 4: Services Setup
- [ ] Create `TTSService` (flutter_tts wrapper)
- [ ] Test TTS with simple Dart script: `TTSService().speak("Hello", "en-US")`
- [ ] Test TTS in all 15 languages
- [ ] Create `PurchaseService` (google_play_billing wrapper)

### Day 5: State Management
- [ ] Implement `LanguageProvider` (language selection + persistence)
- [ ] Implement `PurchaseProvider` (unlock status, purchase logic)
- [ ] Implement `ProgressProvider` (track completed items)
- [ ] Test providers with simple StatelessWidget

---

## Week 2: Core Features

### Day 6-7: Main App & Screens
- [ ] Create `main.dart` with MultiProvider setup
- [ ] Implement `SplashScreen`
- [ ] Implement `HomeScreen` (language picker + category grid)
- [ ] Implement `PaywallScreen` (for non-English languages)
- [ ] Test navigation between screens

### Day 8: Tracing Canvas
- [ ] Implement `TracingCanvas` widget
- [ ] Implement `StrokePainter` custom painter
- [ ] Implement `DottedTextWidget` (guide text)
- [ ] Add clear/submit button controls
- [ ] Test drawing on emulator (should be smooth)

### Day 9: Content Integration
- [ ] Create `lib/data/content_dataset.dart` (all alphabets, numbers, words, etc.)
- [ ] Port language data from `ContentDataset.swift`
- [ ] Create functions to fetch content by language & category
- [ ] Test content displays correctly

### Day 10: Polish & Testing
- [ ] Implement progress persistence (SharedPreferences)
- [ ] Implement purchase unlock logic
- [ ] Test offline TTS (disable network, verify speech works)
- [ ] Handle edge cases (missing language voice, no internet, etc.)

---

## Week 3: Google Play Submission

### Day 11: Build & Signing
- [ ] Generate keystore: `keytool -genkey -v ...`
- [ ] Create `android/key.properties` with signing info
- [ ] Update `android/app/build.gradle` with signing config
- [ ] Test release build: `flutter build appbundle --release`
- [ ] Verify AAB is generated at `build/app/outputs/bundle/release/app-release.aab`

### Day 12-13: Play Store Setup
- [ ] Create Google Play Console project
- [ ] Set up app listing:
  - [ ] Title: "EasyStep Kids"
  - [ ] Description: (from guide)
  - [ ] Category: Education
  - [ ] Content Rating: Apply questionnaire
  - [ ] Privacy Policy: Upload (kids-focused)
- [ ] Create screenshots (5-8 per language)
- [ ] Create feature graphic (1024x500px)
- [ ] Set up pricing (free with IAP)

### Day 14: Testing & Review
- [ ] Upload AAB to Internal Testing track
- [ ] Test on real Android device via Play Console
- [ ] Verify:
  - [ ] App launches without crashes
  - [ ] TTS speaks in all languages
  - [ ] Tracing canvas responsive
  - [ ] Purchase flow works (use test account)
  - [ ] Languages unlock correctly after purchase
- [ ] Fix any critical issues

### Day 15: Submit for Review
- [ ] Finalize listing content
- [ ] Review compliance requirements
- [ ] Submit to Production track
- [ ] Expected review time: 1-3 hours (usually)

---

## Critical Implementation Details

### TTS Language Codes (from your iOS app)
```
"en" → "en-US"
"hi" → "hi-IN"
"te" → "te-IN"
"ta" → "ta-IN"
"gu" → "gu-IN"
"es" → "es-ES"
"de" → "de-DE"
"ur" → "ur-PK"
"mr" → "mr-IN"
"ja" → "ja-JP"
"zh" → "zh-CN"
"ml" → "ml-IN"
"kn" → "kn-IN"
"pt" → "pt-BR"
"fr" → "fr-FR"
```

### Google Play Product ID
```
com.easystepkids.app.alllanguages
```
(Must match exactly in Google Play Console)

### Content to Port from iOS App

**From `ContentDataset.swift`:**
- Alphabets (for each language)
- Numbers (0-20)
- Words (10-15 per language)
- Days of week
- Colors (9 colors)
- Months (12 months)
- Shapes (if applicable)

**From `SymbolMap.swift`:**
- SF Symbol → Image name mappings (not needed for Android, use Material icons instead)

**From `Models.swift`:**
- AppLanguage list (all 15)
- Category enum
- TraceItem structure
- Color mappings

---

## Troubleshooting Guide

### TTS not working?
- Ensure flutter_tts is properly initialized
- Check language code is correct (use `getLanguages()` to verify)
- Device needs TTS language data installed (Settings → Language)

### Purchase not working?
- Verify product ID in Google Play Console
- Test account must be added as tester in Play Console
- Purchase in sandbox environment first

### App crashes on launch?
- Check logcat: `adb logcat | grep -i flutter`
- Ensure all dependencies are installed: `flutter pub get`
- Check AndroidManifest.xml permissions

### Tracing canvas laggy?
- Reduce point capture rate
- Use `shouldRepaint: false` when possible
- Profile with Flutter DevTools

---

## File Structure Summary

```
easystep_kids_flutter/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── models.dart
│   ├── services/
│   │   ├── tts_service.dart
│   │   └── purchase_service.dart
│   ├── providers/
│   │   └── app_state.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── tracing_screen.dart
│   │   └── paywall_screen.dart
│   ├── widgets/
│   │   ├── tracing_canvas.dart
│   │   └── category_grid.dart
│   └── data/
│       └── content_dataset.dart
├── android/
│   ├── app/
│   │   ├── build.gradle (signing config)
│   │   └── src/main/AndroidManifest.xml
│   └── key.properties (signing keys)
├── assets/
│   ├── app_logo.png
│   └── sounds/
├── pubspec.yaml
└── README.md
```

---

## Success Criteria

✅ **App launches without crashing**
✅ **TTS works offline in all 15 languages**
✅ **Tracing canvas is responsive & smooth**
✅ **Unlock works via in-app purchase**
✅ **Progress persists after restart**
✅ **No console errors or warnings**
✅ **Google Play review approved**
✅ **Live on Google Play Store**

---

## Support & Resources

| Topic | Link |
|-------|------|
| Flutter Setup | https://flutter.dev/docs/get-started |
| flutter_tts Docs | https://pub.dev/packages/flutter_tts |
| google_play_billing | https://pub.dev/packages/google_play_billing |
| Provider Docs | https://pub.dev/packages/provider |
| CustomPaint | https://flutter.dev/docs/development/ui/advanced/custom-paint |
| Android Signing | https://developer.android.com/studio/publish/app-signing |
| Google Play Submission | https://support.google.com/googleplay/android-developer/answer/113469 |

---

## Next Steps After Submission

1. Monitor play console for reviews/crashes
2. Respond to user reviews and feedback
3. Plan updates:
   - iOS version (Flutter can target both)
   - Additional languages
   - New features (shapes, animations, etc.)

Good luck! 🚀
