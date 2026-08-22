package com.mas7ool.mas7ool.permissions

import android.app.Activity
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat

object PermissionHelper {

    enum class AppPermissionType {
        USAGE_ACCESS,
        OVERLAY,
        NOTIFICATIONS,
        BATTERY_OPTIMIZATION
    }

    enum class PermissionState {
        GRANTED,
        DENIED,
        RESTRICTED,
        UNKNOWN
    }

    /**
     * Checks if Usage Stats permission (PACKAGE_USAGE_STATS) is granted.
     */
    fun hasUsageStatsPermission(context: Context): Boolean {
        return try {
            val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    context.packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    context.packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Opens Android Usage Access settings screen.
     */
    fun openUsageAccessSettings(activity: Activity): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                // Attempt to deep link directly to this app's setting if supported by the OS
                data = Uri.fromParts("package", activity.packageName, null)
            }
            activity.startActivity(intent)
            true
        } catch (e: Exception) {
            try {
                val fallbackIntent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                activity.startActivity(fallbackIntent)
                true
            } catch (e2: Exception) {
                false
            }
        }
    }

    /**
     * Checks if Display Over Other Apps (SYSTEM_ALERT_WINDOW) is granted.
     */
    fun hasOverlayPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    /**
     * Opens Android Display Over Other Apps settings screen.
     */
    fun openOverlaySettings(activity: Activity): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:${activity.packageName}")
                ).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                activity.startActivity(intent)
                true
            } catch (e: Exception) {
                try {
                    val fallbackIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    activity.startActivity(fallbackIntent)
                    true
                } catch (e2: Exception) {
                    false
                }
            }
        } else {
            true
        }
    }

    /**
     * Checks if Notification permission is granted.
     */
    fun hasNotificationPermission(context: Context): Boolean {
        return NotificationManagerCompat.from(context).areNotificationsEnabled()
    }

    /**
     * Opens Notification Settings screen.
     */
    fun openNotificationSettings(activity: Activity): Boolean {
        return try {
            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
            } else {
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:${activity.packageName}")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
            }
            activity.startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Checks if app is exempt from Battery Optimizations.
     */
    fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
            powerManager?.isIgnoringBatteryOptimizations(context.packageName) ?: false
        } else {
            true
        }
    }

    /**
     * Requests Battery Optimization exemption or opens the settings screen.
     */
    fun openBatteryOptimizationSettings(activity: Activity): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:${activity.packageName}")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            activity.startActivity(intent)
            true
        } catch (e: Exception) {
            try {
                val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                activity.startActivity(fallbackIntent)
                true
            } catch (e2: Exception) {
                false
            }
        }
    }

    /**
     * Opens general App Details Settings.
     */
    fun openAppDetailsSettings(activity: Activity): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:${activity.packageName}")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            activity.startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    fun checkPermission(context: Context, type: AppPermissionType): PermissionState {
        return when (type) {
            AppPermissionType.USAGE_ACCESS -> if (hasUsageStatsPermission(context)) PermissionState.GRANTED else PermissionState.DENIED
            AppPermissionType.OVERLAY -> if (hasOverlayPermission(context)) PermissionState.GRANTED else PermissionState.DENIED
            AppPermissionType.NOTIFICATIONS -> if (hasNotificationPermission(context)) PermissionState.GRANTED else PermissionState.DENIED
            AppPermissionType.BATTERY_OPTIMIZATION -> if (isIgnoringBatteryOptimizations(context)) PermissionState.GRANTED else PermissionState.DENIED
        }
    }
}
