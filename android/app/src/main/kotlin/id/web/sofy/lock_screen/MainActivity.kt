package id.web.sofy.lock_screen

import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "lock_screen_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.action == "id.web.sofy.lock_screen.ACTION_SHORTCUT_LOCK") {
            lockDeviceScreen()
            finish()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "lockScreen" -> {
                    val success = lockDeviceScreen()
                    result.success(success)
                }
                "isDeviceAdmin" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAdmin" -> {
                    requestAccessibilityPrivileges()
                    result.success(null)
                }
                "isAccessibilitySupported" -> {
                    result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
                }
                "createShortcut" -> {
                    createShortcut()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        var accessibilityEnabled = 0
        val service = packageName + "/" + LockScreenAccessibilityService::class.java.canonicalName
        try {
            accessibilityEnabled = Settings.Secure.getInt(
                applicationContext.contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED
            )
        } catch (e: Settings.SettingNotFoundException) {
            // Ignore
        }

        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        if (accessibilityEnabled == 1) {
            val settingValue = Settings.Secure.getString(
                applicationContext.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            if (settingValue != null) {
                colonSplitter.setString(settingValue)
                while (colonSplitter.hasNext()) {
                    val accessibilityService = colonSplitter.next()
                    if (accessibilityService.equals(service, ignoreCase = true)) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private fun lockDeviceScreen(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val intent = Intent(LockScreenAccessibilityService.ACTION_LOCK)
            intent.setPackage(packageName)
            sendBroadcast(intent)
            return true
        }
        return false
    }

    private fun requestAccessibilityPrivileges() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun createShortcut() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val shortcutManager = getSystemService(ShortcutManager::class.java)
            if (shortcutManager != null && shortcutManager.isRequestPinShortcutSupported) {
                val intent = Intent(this, MainActivity::class.java)
                intent.action = "id.web.sofy.lock_screen.ACTION_SHORTCUT_LOCK"
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)

                val pinShortcutInfo = ShortcutInfo.Builder(this, "lock-shortcut-id")
                    .setShortLabel("Lock Screen")
                    .setLongLabel("Instant Lock")
                    .setIcon(Icon.createWithResource(this, R.mipmap.ic_launcher))
                    .setIntent(intent)
                    .build()

                shortcutManager.requestPinShortcut(pinShortcutInfo, null)
            }
        }
    }
}
