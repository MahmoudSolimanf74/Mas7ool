package com.mas7ool.mas7ool.monitoring

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class EndSessionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val packageName = intent.getStringExtra(ForegroundMonitoringService.EXTRA_PACKAGE_NAME) ?: ""
        Log.i("EndSessionReceiver", "Received end session broadcast for: $packageName")
        ForegroundMonitoringService.endSessionFromAction(context, packageName)
    }
}
