package id.web.sofy.lock_screen

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "lock_screen_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "lockScreen" -> {
                    val success = lockDeviceScreen()
                    result.success(success)
                }
                "isDeviceAdmin" -> {
                    result.success(isDeviceAdminEnabled())
                }
                "requestAdmin" -> {
                    requestAdminPrivileges()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isDeviceAdminEnabled(): Boolean {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val compName = ComponentName(this, LockScreenAdminReceiver::class.java)
        return devicePolicyManager.isAdminActive(compName)
    }

    private fun lockDeviceScreen(): Boolean {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val compName = ComponentName(this, LockScreenAdminReceiver::class.java)

        return if (devicePolicyManager.isAdminActive(compName)) {
            devicePolicyManager.lockNow()
            true
        } else {
            false
        }
    }

    private fun requestAdminPrivileges() {
        val compName = ComponentName(this, LockScreenAdminReceiver::class.java)
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, compName)
        intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "This app requires device admin privileges to lock the screen.")
        startActivity(intent)
    }
}
