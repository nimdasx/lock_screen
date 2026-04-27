# Lock Screen App

A minimal, production-ready Flutter app designed to instantly lock your Android device's screen. Ideal for users with broken power buttons or those who want a simple software-based alternative.

## Features
- **Instant Locking**: Tap the app icon to immediately lock your device.
- **Minimalist UI**: No ads, no tracking, just a single purpose app.
- **Lightweight**: Uses Android's native `DevicePolicyManager`.

## Prerequisites

- Flutter SDK (latest stable recommended)
- Android Studio / Android SDK
- An Android device or emulator (Android 5.0+)

## How it Works

This app utilizes Android's **Accessibility Service API** to securely lock the screen without disabling biometric unlocks (like Fingerprint or Face Unlock). 

*Note: The older "Device Admin" approach forces a PIN/Pattern input upon the next unlock. By using Accessibility Service (available on Android 9+), this limitation is bypassed.*

Because this requires special permissions, the first time you open the app, it will prompt you to open the **Accessibility Settings**. Once you enable the "Lock Screen Service", launching the app again will lock the screen instantly.

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

### 3. Testing
1. Install and launch the app.
2. Tap "Open Settings". This will take you to your device's Accessibility settings.
3. Find **"Lock Screen Service"** (usually under "Installed apps" or "Downloaded services") and toggle it **ON**.
4. Once granted, open the app again to test the lock functionality.
5. Try closing the app and launching it from your home screen. It should instantly lock the device, and you should be able to unlock it with your fingerprint!

## Instructions for Home Screen Shortcut

To make the lock screen easily accessible:
1. Open your app drawer.
2. Find the **"lock_screen"** app.
3. Long-press the icon and drag it to your home screen or dock for easy access.
4. Now, simply tapping the icon on your home screen will lock the device instantly without needing to press the physical power button.

## Uninstallation

Unlike the Device Admin approach, apps using Accessibility Services can be uninstalled normally just like any other app. Simply long-press the app icon on your home screen and select **Uninstall**, or remove it via Settings > Apps.

## Project Structure Highlights
- `lib/main.dart`: Contains the Flutter UI and MethodChannel communication.
- `android/app/src/main/kotlin/.../MainActivity.kt`: Handles the MethodChannel calls and checks Accessibility Service status.
- `android/app/src/main/kotlin/.../LockScreenAccessibilityService.kt`: The AccessibilityService class that triggers `GLOBAL_ACTION_LOCK_SCREEN`.
- `android/app/src/main/res/xml/accessibility_service_config.xml`: Declares the Accessibility Service configuration.
