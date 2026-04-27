package id.web.sofy.lock_screen

import android.accessibilityservice.AccessibilityService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log

class LockScreenAccessibilityService : AccessibilityService() {
    companion object {
        const val ACTION_LOCK = "id.web.sofy.lock_screen.ACTION_LOCK"
    }

    private val lockReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == ACTION_LOCK) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    val success = performGlobalAction(GLOBAL_ACTION_LOCK_SCREEN)
                    Log.d("LockScreenService", "Lock action performed: $success")
                }
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("LockScreenService", "Accessibility Service Connected")
        val filter = IntentFilter(ACTION_LOCK)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(lockReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(lockReceiver, filter)
        }
    }

    override fun onUnbind(intent: Intent?): Boolean {
        Log.d("LockScreenService", "Accessibility Service Unbound")
        try {
            unregisterReceiver(lockReceiver)
        } catch (e: Exception) {
            Log.e("LockScreenService", "Error unregistering receiver", e)
        }
        return super.onUnbind(intent)
    }

    override fun onAccessibilityEvent(event: android.view.accessibility.AccessibilityEvent?) {
        // Not needed
    }

    override fun onInterrupt() {
        // Not needed
    }
}
