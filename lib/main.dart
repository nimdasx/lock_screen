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
      title: 'Quick Lock',
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
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    try {
      final bool isSupported = await platform.invokeMethod('isAccessibilitySupported');
      final bool isActive = await platform.invokeMethod('isDeviceAdmin');
      setState(() {
        _isAccessibilitySupported = isSupported;
        _isAdminActive = isActive;
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to check status: '${e.message}'.");
    }
  }

  Future<void> _lockScreen() async {
    try {
      await platform.invokeMethod('lockScreen');
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

  Future<void> _createShortcut() async {
    try {
      await platform.invokeMethod('createShortcut');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shortcut request sent to Home Screen')),
        );
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to create shortcut: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Lock Setup'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.phonelink_lock, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Quick Lock',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'This app allows you to lock your screen instantly without using the physical power button.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              
              _buildSection(
                title: 'Step 1: Enable Accessibility',
                description: 'Required to lock the screen while keeping Fingerprint unlock working.',
                status: _isAdminActive ? 'Enabled' : 'Not Enabled',
                statusColor: _isAdminActive ? Colors.green : Colors.orange,
                buttonLabel: 'Open Accessibility Settings',
                icon: Icons.accessibility_new,
                onPressed: _requestAdmin,
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: 'Step 2: Create Shortcut',
                description: 'Add a "Lock" button to your Home Screen for instant access.',
                buttonLabel: 'Add to Home Screen',
                icon: Icons.add_to_home_screen,
                onPressed: _createShortcut,
                enabled: _isAdminActive,
              ),

              const SizedBox(height: 40),
              
              if (_isAdminActive)
                ElevatedButton(
                  onPressed: _lockScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Test Lock Now', style: TextStyle(fontSize: 18)),
                ),
                
              const SizedBox(height: 20),
              const Text(
                'Note: If you are on Android 13+, you might need to "Allow restricted settings" in App Info before you can enable the Accessibility Service.',
                style: TextStyle(fontSize: 12, color: Colors.white54, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    String? status,
    Color? statusColor,
    required String buttonLabel,
    required IconData icon,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor?.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor ?? Colors.grey),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: enabled ? onPressed : null,
                icon: Icon(icon),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
