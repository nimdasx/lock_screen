import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LockScreenApp());
}

class LockScreenApp extends StatelessWidget {
  const LockScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lock Screen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey, 
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LockScreenPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LockScreenPage extends StatefulWidget {
  const LockScreenPage({super.key});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> with WidgetsBindingObserver {
  static const platform = MethodChannel('lock_screen_channel');
  bool _isAdminActive = false;
  bool _isAccessibilitySupported = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSupportAndStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSupportAndStatus();
    }
  }

  Future<void> _checkSupportAndStatus() async {
    try {
      final bool isSupported = await platform.invokeMethod('isAccessibilitySupported');
      final bool isActive = await platform.invokeMethod('isDeviceAdmin');
      setState(() {
        _isAccessibilitySupported = isSupported;
        _isAdminActive = isActive;
      });
      if (isActive) {
        // If the user already granted privileges, we can lock instantly 
        // when they open the app.
        await _lockScreen();
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to check status: '${e.message}'.");
    }
  }

  Future<void> _lockScreen() async {
    try {
      final success = await platform.invokeMethod('lockScreen');
      if (success == true) {
        // Automatically close the app after locking to allow quick locking next time.
        SystemNavigator.pop();
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to lock screen: '${e.message}'.");
    }
  }

  Future<void> _requestAdmin() async {
    try {
      await platform.invokeMethod('requestAdmin');
    } on PlatformException catch (e) {
      debugPrint("Failed to request admin: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lock Screen'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isAdminActive ? Icons.lock_outline : Icons.lock_open,
                size: 100,
                color: _isAdminActive ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 32),
              if (!_isAccessibilitySupported) ...[
                const Text(
                  'Your Android version is too old to use the Accessibility-based lock screen (Requires Android 9+).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.redAccent),
                ),
              ] else if (!_isAdminActive) ...[
                const Text(
                  'To lock your screen instantly without disabling biometric unlock (fingerprint), please enable the Accessibility Service for this app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _requestAdmin,
                  icon: const Icon(Icons.accessibility_new),
                  label: const Text('Open Settings'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ] else ...[
                const Text(
                  'Accessibility Service enabled. You can lock your screen by tapping the button below, or simply launching the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _lockScreen,
                  icon: const Icon(Icons.phonelink_lock),
                  label: const Text('Lock Screen Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
