package com.mas7ool.mas7ool.monitoring

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.mas7ool.mas7ool.permissions.PermissionHelper

class RestartServiceReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "Mas7oolRestartReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Received restart broadcast from AlarmManager")
        val prefs = context.getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
        val isMonitoringEnabled = prefs.getBoolean("monitoring_enabled", true)

        if (isMonitoringEnabled) {
            val hasUsage = PermissionHelper.hasUsageStatsPermission(context)
            val hasOverlay = PermissionHelper.hasOverlayPermission(context)

            if (hasUsage && hasOverlay) {
                Log.i(TAG, "Reviving ForegroundMonitoringService...")
                ForegroundMonitoringService.start(context)
            }
        }
    }
}