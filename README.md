# Lock Screen App

A minimal, production-ready Flutter app designed to instantly lock your Android device's screen. Ideal for users with broken power buttons or those who want a simple software-based alternative.

## Features
- **Biometric Friendly**: Uses Accessibility Service API so Fingerprint/Face Unlock continues to work.
- **Home Screen Shortcut**: Create a dedicated "Lock" icon on your home screen for instant one-tap locking.
- **Setup Page**: Easy-to-follow guide to enable required permissions.
- **No Ads / No Tracking**: Lightweight and privacy-focused.

## Prerequisites

- Flutter SDK (latest stable recommended)
- Android Studio / Android SDK
- An Android device running **Android 9.0 (Pie) or higher**.

## How it Works

This app utilizes Android's **Accessibility Service API** to securely lock the screen. Unlike the older "Device Admin" approach, this method allows the device to be unlocked using biometrics (Fingerprint/Face) without requiring a PIN/Pattern every time.

Because this requires special permissions, the app provides a setup guide:
1. **Enable Service**: You must toggle the "Lock Screen Service" in your device's Accessibility settings.
2. **Add Shortcut**: Once enabled, you can add a "Lock" shortcut to your home screen. This shortcut is designed to trigger the lock action instantly and close itself.

## Steps to Run, Build, and Test

### 1. Running the App
To run the app locally on your connected device or emulator:
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Building the App (Production)
To build a release APK for installation on your device:
```bash
flutter build apk --release
```
You can find the generated APK at `build/app/outputs/flutter-apk/app-release.apk`. Transfer this file to your device and install it.

### 3. Testing & Setup
1. Install and launch the app.
2. Tap **"Open Accessibility Settings"**.
3. Find **"Lock Screen Service"** (usually under "Installed apps" or "Downloaded services") and toggle it **ON**.
4. Return to the app and tap **"Add to Home Screen"**.
5. Use the new "Lock Screen" icon on your home screen to lock your device instantly!

## Android 13+ Note (Restricted Settings)

On Android 13 and above, the system might block you from enabling the Accessibility Service for side-loaded apps.
**To fix this:**
1. Go to **Settings > Apps > Lock Screen**.
2. Tap the **three dots** in the top-right corner.
3. Select **"Allow restricted settings"**.
4. You can now enable the Accessibility Service in the main accessibility settings.

## Project Structure Highlights
- `lib/main.dart`: Flutter UI for the setup page and platform channel logic.
- `android/.../MainActivity.kt`: Handles shortcut creation and triggers the lock broadcast.
- `android/.../LockScreenAccessibilityService.kt`: The background service that performs the actual `GLOBAL_ACTION_LOCK_SCREEN`.
- `android/.../accessibility_service_config.xml`: Configuration for the accessibility service.
