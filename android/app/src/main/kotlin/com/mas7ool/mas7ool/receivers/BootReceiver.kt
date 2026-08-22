package com.mas7ool.mas7ool.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.mas7ool.mas7ool.monitoring.ForegroundMonitoringService
import com.mas7ool.mas7ool.permissions.PermissionHelper

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            val prefs = context.getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
            val monitoringEnabled = prefs.getBoolean("monitoring_enabled", false)

            if (monitoringEnabled && PermissionHelper.hasUsageStatsPermission(context)) {
                ForegroundMonitoringService.start(context)
            }
        }
    }
}
