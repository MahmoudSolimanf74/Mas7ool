package com.mas7ool.mas7ool.monitoring

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.mas7ool.mas7ool.permissions.PermissionHelper

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "Mas7oolBootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d(TAG, "Received broadcast action: $action")

        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            val prefs = context.getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
            val isMonitoringEnabled = prefs.getBoolean("monitoring_enabled", true)

            Log.d(TAG, "Boot check: monitoring_enabled=$isMonitoringEnabled")

            if (isMonitoringEnabled) {
                val hasUsage = PermissionHelper.hasUsageStatsPermission(context)
                val hasOverlay = PermissionHelper.hasOverlayPermission(context)

                if (hasUsage && hasOverlay) {
                    Log.i(TAG, "Starting ForegroundMonitoringService after reboot...")
                    ForegroundMonitoringService.start(context)
                } else {
                    Log.w(TAG, "Permissions missing on boot: usage=$hasUsage, overlay=$hasOverlay")
                }
            }
        }
    }
}