package com.mas7ool.mas7ool.monitoring

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import com.mas7ool.mas7ool.permissions.PermissionHelper

data class ForegroundEvent(
    val packageName: String,
    val appName: String,
    val timestamp: Long,
    val eventType: String
)

class ForegroundAppDetector(private val context: Context) {

    private val usageStatsManager: UsageStatsManager? =
        context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager

    private var lastForegroundPackage: String? = null
    private var lastDetectionTimestamp: Long = 0L
    private val debounceThresholdMs: Long = 400L

    private val systemPackagesToIgnore = setOf(
        "com.android.systemui",
        "android",
        "com.google.android.googlequicksearchbox",
        "com.android.settings"
    )

    /**
     * Retrieves the current launcher package to ignore when detecting app opens.
     */
    private fun getLauncherPackages(): Set<String> {
        val launcherSet = mutableSetOf<String>()
        try {
            val intent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
            }
            val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.packageManager.queryIntentActivities(
                    intent,
                    PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DEFAULT_ONLY.toLong())
                )
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
            }

            for (info in resolveInfos) {
                info.activityInfo?.packageName?.let { launcherSet.add(it) }
            }
        } catch (e: Exception) {
            // Ignore error
        }
        return launcherSet
    }

    /**
     * Polls UsageEvents for the most recent ACTIVITY_RESUMED or MOVE_TO_FOREGROUND event.
     */
    fun detectForegroundApp(): ForegroundEvent? {
        if (!PermissionHelper.hasUsageStatsPermission(context) || usageStatsManager == null) {
            return null
        }

        val currentTime = System.currentTimeMillis()
        // Query events from the last 15 seconds
        val startTime = currentTime - 15_000L

        val events: UsageEvents = try {
            usageStatsManager.queryEvents(startTime, currentTime)
        } catch (e: Exception) {
            return null
        }

        var latestPackageName: String? = null
        var latestTimestamp: Long = 0L
        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val isForeground = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
            } else {
                @Suppress("DEPRECATION")
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND || event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
            }

            if (isForeground) {
                if (event.timeStamp >= latestTimestamp) {
                    latestPackageName = event.packageName
                    latestTimestamp = event.timeStamp
                }
            }
        }

        val targetPackage = latestPackageName ?: return null
        val eventTimestamp = latestTimestamp

        currentForegroundPackage = targetPackage

        // Ignore self app
        if (targetPackage == context.packageName) {
            return null
        }

        // Ignore system packages and launchers
        if (systemPackagesToIgnore.contains(targetPackage) || getLauncherPackages().contains(targetPackage)) {
            return null
        }

        // Debounce if same package detected within threshold
        if (targetPackage == lastForegroundPackage && (currentTime - lastDetectionTimestamp) < debounceThresholdMs) {
            return null
        }

        // Update tracking state
        lastForegroundPackage = targetPackage
        lastDetectionTimestamp = currentTime

        val appName = getAppName(targetPackage)

        return ForegroundEvent(
            packageName = targetPackage,
            appName = appName,
            timestamp = eventTimestamp,
            eventType = "ACTIVITY_RESUMED"
        )
    }

    /**
     * Resolves human-readable application label from package name.
     */
    fun getAppName(packageName: String): String {
        return try {
            val pm = context.packageManager
            val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.getApplicationInfo(packageName, 0)
            }
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            packageName
        }
    }

    companion object {
        @Volatile
        var currentForegroundPackage: String? = null
    }

    fun getRawForegroundPackage(): String? {
        if (!PermissionHelper.hasUsageStatsPermission(context) || usageStatsManager == null) {
            return currentForegroundPackage
        }

        val currentTime = System.currentTimeMillis()
        // Query events from the last 2 hours to guarantee finding the most recent foreground app
        val startTime = currentTime - (2 * 60 * 60 * 1000L)

        val events: UsageEvents = try {
            usageStatsManager.queryEvents(startTime, currentTime)
        } catch (e: Exception) {
            return currentForegroundPackage
        }

        var latestPackageName: String? = null
        var latestTimestamp: Long = 0L
        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val isForeground = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
            } else {
                @Suppress("DEPRECATION")
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND || event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
            }

            if (isForeground && event.timeStamp >= latestTimestamp) {
                latestPackageName = event.packageName
                latestTimestamp = event.timeStamp
            }
        }

        if (latestPackageName != null) {
            currentForegroundPackage = latestPackageName
        }

        return latestPackageName ?: currentForegroundPackage
    }

    fun resetState() {
        lastForegroundPackage = null
        lastDetectionTimestamp = 0L
    }
}
