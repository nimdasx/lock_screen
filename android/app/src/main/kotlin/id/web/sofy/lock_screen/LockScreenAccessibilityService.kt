package id.web.sofy.lock_screen

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Build

class LockScreenAccessibilityService : AccessibilityService() {
    companion object {
        var instance: LockScreenAccessibilityService? = null
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onUnbind(intent: Intent?): Boolean {
        instance = null
        return super.onUnbind(intent)
    }

    override fun onAccessibilityEvent(event: android.view.accessibility.AccessibilityEvent?) {
        // Not required for locking screen
    }

    override fun onInterrupt() {
        // Not required
    }

    fun lockDeviceScreen(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return performGlobalAction(GLOBAL_ACTION_LOCK_SCREEN)
        }
        return false
    }
}
