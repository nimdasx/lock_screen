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

This app utilizes Android's Device Administration API. Specifically, it uses `DevicePolicyManager.lockNow()` to turn off the screen and lock the device.

Because this requires elevated permissions, the first time you open the app, it will prompt you to activate "Device Admin" privileges. Once activated, launching the app again will lock the screen instantly.

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
2. Tap "Grant Permission" and activate the Device Admin app in the system settings.
3. Once granted, tap "Lock Screen Now" to test the lock functionality.
4. Try closing the app and launching it from your home screen. It should instantly lock the device.

## Instructions for Home Screen Shortcut

To make the lock screen easily accessible:
1. Open your app drawer.
2. Find the **"lock_screen"** app.
3. Long-press the icon and drag it to your home screen or dock for easy access.
4. Now, simply tapping the icon on your home screen will lock the device instantly without needing to press the physical power button.

## Android Limitations & Uninstallation

**Uninstallation Issue:**
Because this app uses Device Admin privileges, Android prevents you from uninstalling it directly from the home screen in standard ways.

**How to Uninstall:**
1. Open **Settings** on your Android device.
2. Search for **Device Admin apps** (or navigate to Security > Device Admin apps).
3. Find **"Lock Screen"** in the list and **Deactivate** it.
4. You can now uninstall the app normally via Settings > Apps, or from the home screen.

**Biometrics / Fingerprint Unlock Limitation:**
On some Android versions (especially Android 9 Pie and below), using `DevicePolicyManager.lockNow()` will force a PIN/Password/Pattern unlock the next time you turn on the screen, disabling fingerprint or face unlock for that specific unlock. On newer Android versions, this behavior might still apply depending on the manufacturer's implementation.

## Project Structure Highlights
- `lib/main.dart`: Contains the Flutter UI and MethodChannel communication.
- `android/app/src/main/kotlin/.../MainActivity.kt`: Handles the MethodChannel calls and interacts with `DevicePolicyManager`.
- `android/app/src/main/kotlin/.../LockScreenAdminReceiver.kt`: Required receiver class for Device Admin.
- `android/app/src/main/res/xml/device_admin.xml`: Declares the required policy (`force-lock`).
