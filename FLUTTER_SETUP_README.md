# EasyStep Kids - Flutter Setup Guide

This directory contains all the Dart code files needed to build EasyStep Kids for Android/Google Play Store.

## 📁 Files Included

### Core Application
- **main.dart** — App entry point, splash screen, home screen
- **models.dart** — Language, Category, TraceItem data models
- **app_state.dart** — Provider-based state management (Language, Purchase, Progress)
- **tts_service.dart** — Text-to-speech service (flutter_tts wrapper)
- **purchase_service.dart** — Google Play Billing integration

### Configuration
- **pubspec.yaml** — Flutter dependencies and project configuration
- **android_build.gradle** — Android build configuration with signing setup

---

## 🚀 Quick Setup (5 minutes)

### Step 1: Create Flutter Project

```bash
flutter create easystep_kids_flutter
cd easystep_kids_flutter
```

### Step 2: Replace Files

Copy these files into your project:

```bash
# Copy main app files to lib/
cp main.dart lib/
cp models.dart lib/
cp app_state.dart lib/
cp tts_service.dart lib/
cp purchase_service.dart lib/

# Copy pubspec.yaml
cp pubspec.yaml ./

# Copy Android configuration
cp android_build.gradle android/app/build.gradle
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

### Step 4: Run on Emulator

```bash
flutter run
```

---

## 🔧 Setup Instructions

### 1. **Fix App Package Name**

Edit `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.easystepkids.app"  // Change to your package name
}
```

Also update `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.easystepkids.app">  <!-- Update this -->
```

### 2. **Create Signing Key (One-Time)**

```bash
# Generate key
keytool -genkey -v -keystore ~/easystep-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias easystep

# Create android/key.properties
echo "storeFile=/path/to/easystep-key.jks" > android/key.properties
echo "storePassword=your_password" >> android/key.properties
echo "keyPassword=your_key_password" >> android/key.properties
echo "keyAlias=easystep" >> android/key.properties
```

### 3. **Setup Google Play Billing**

In Google Play Console:
1. Create new app entry
2. Set product ID: `com.easystepkids.app.alllanguages`
3. Create this in-app product for "Unlock All Languages"

### 4. **Add Assets**

Create these directories:
```bash
mkdir -p assets/images
mkdir -p assets/fonts
```

Add your app logo as `assets/app_logo.png`

### 5. **Update AndroidManifest.xml**

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.easystepkids.app">

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

## 📦 Build Release APK/AAB

### Build AAB (Recommended for Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build APK (For Testing)

```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

---

## 📝 What Each File Does

### main.dart
- **SplashScreen**: Shows logo while loading data
- **HomeScreen**: Displays language selector and category grid
- **TracingScreen**: Placeholder for tracing activity

### models.dart
- **AppLanguage**: Language definition (15 languages from iOS app)
- **Category**: Alphabet, numbers, words, etc.
- **TraceItem**: Text to trace with pronunciation
- **ItemColors**: Color mapping for color learning

### app_state.dart
- **LanguageProvider**: Manages selected language
- **PurchaseProvider**: Handles in-app purchases
- **ProgressProvider**: Tracks completed items
- **TTSProvider**: Manages text-to-speech

### tts_service.dart
- Offline text-to-speech using flutter_tts
- Supports all 15 languages
- Fallback language handling

### purchase_service.dart
- Google Play Billing integration
- Handles unlock purchases
- Stores purchase state

---

## 🧪 Testing Checklist

- [ ] App launches without errors
- [ ] Language selection works
- [ ] TTS speaks in selected language
- [ ] Progress persists after app restart
- [ ] Purchase flow works (test account)
- [ ] Unlock works after purchase
- [ ] No crashes on Android 5.0+

---

## 🎮 Testing Commands

```bash
# Run on emulator
flutter emulators --launch Pixel_5_API_33
flutter run

# Run in verbose mode (debug)
flutter run -v

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Build release APK
flutter build apk --release

# Profile app performance
flutter run --profile
```

---

## 📱 Android Emulator Setup

If you don't have an emulator:

```bash
# Install Android SDK (if needed)
flutter doctor

# Create emulator
android avd

# Or use command line
$ANDROID_HOME/tools/bin/avdmanager create avd -n Pixel_5_API_33 \
  -k "system-images;android-33;google_apis;x86_64" \
  -d pixel_5
```

---

## 🔗 Important Links

| Topic | Link |
|-------|------|
| Flutter Setup | https://flutter.dev/docs/get-started/install |
| flutter_tts | https://pub.dev/packages/flutter_tts |
| google_play_billing | https://pub.dev/packages/google_play_billing |
| Provider | https://pub.dev/packages/provider |
| Android Signing | https://developer.android.com/studio/publish/app-signing |
| Google Play Console | https://play.google.com/console |

---

## ❓ Troubleshooting

### App crashes on start?
```bash
# Check logs
adb logcat | grep -i flutter

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### TTS not working?
- Ensure language is installed on device (Settings → Languages)
- Check `flutter_tts` is properly initialized
- Verify `languageCode` format (e.g., "hi-IN")

### Purchase not working?
- Add test account in Google Play Console
- Use correct product ID: `com.easystepkids.app.alllanguages`
- Test in sandbox first

### Build fails?
```bash
# Update dependencies
flutter pub upgrade

# Check doctor
flutter doctor

# Full clean rebuild
flutter clean
rm -rf .dart_tool pubspec.lock
flutter pub get
flutter run
```

---

## 📋 Next Steps

1. **Port Content**: Copy alphabet/number/word data from your iOS app's `ContentDataset.swift`
2. **Add Tracing Canvas**: Implement drawing canvas in `TracingScreen`
3. **Add Paywall**: Create paywall for locked languages
4. **Setup Analytics**: Add Firebase Analytics
5. **Test & Submit**: Build AAB and submit to Google Play Store

---

## 📞 Support

For issues or questions:
- Check [Flutter documentation](https://flutter.dev/docs)
- Review [Google Play Billing docs](https://developer.android.com/google-play/billing)
- Check console logs: `flutter run -v`

---

**Happy coding! 🚀**
