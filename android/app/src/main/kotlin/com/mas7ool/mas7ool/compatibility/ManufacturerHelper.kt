package com.mas7ool.mas7ool.compatibility

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.Locale

object ManufacturerHelper {

    enum class Manufacturer {
        XIAOMI,
        SAMSUNG,
        HUAWEI,
        OPPO,
        VIVO,
        REALME,
        ONEPLUS,
        GOOGLE,
        OTHER
    }

    fun getManufacturer(): Manufacturer {
        val manufacturer = Build.MANUFACTURER.lowercase(Locale.ROOT)
        return when {
            manufacturer.contains("xiaomi") || manufacturer.contains("redmi") || manufacturer.contains("poco") -> Manufacturer.XIAOMI
            manufacturer.contains("samsung") -> Manufacturer.SAMSUNG
            manufacturer.contains("huawei") || manufacturer.contains("honor") -> Manufacturer.HUAWEI
            manufacturer.contains("oppo") -> Manufacturer.OPPO
            manufacturer.contains("vivo") -> Manufacturer.VIVO
            manufacturer.contains("realme") -> Manufacturer.REALME
            manufacturer.contains("oneplus") -> Manufacturer.ONEPLUS
            manufacturer.contains("google") -> Manufacturer.GOOGLE
            else -> Manufacturer.OTHER
        }
    }

    fun getDeviceInfo(): Map<String, Any> {
        val oem = getManufacturer()
        return mapOf(
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "brand" to Build.BRAND,
            "device" to Build.DEVICE,
            "sdkInt" to Build.VERSION.SDK_INT,
            "oemType" to oem.name,
            "requiresSpecialAutostart" to (oem == Manufacturer.XIAOMI || oem == Manufacturer.HUAWEI || oem == Manufacturer.OPPO || oem == Manufacturer.VIVO)
        )
    }

    /**
     * Attempts to open manufacturer-specific autostart or background protection screen.
     */
    fun openAutostartSettings(activity: Activity): Boolean {
        val intentList = listOf(
            // Xiaomi / MIUI / HyperOS AutoStart
            Intent().setComponent(ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")),
            Intent().setComponent(ComponentName("com.miui.securitycenter", "com.miui.powercenter.PowerSettings")),
            
            // Samsung Device Care / Battery
            Intent().setComponent(ComponentName("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity")),
            Intent().setComponent(ComponentName("com.samsung.android.sm", "com.samsung.android.sm.ui.battery.BatteryActivity")),
            Intent().setComponent(ComponentName("com.samsung.android.sm", "com.samsung.android.sm.ui.dashboard.SmartManagerDashBoardActivity")),

            // Huawei Protected Apps
            Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity")),
            Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity")),

            // Oppo / ColorOS
            Intent().setComponent(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")),
            Intent().setComponent(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity")),
            Intent().setComponent(ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity")),

            // Vivo / Funtouch OS
            Intent().setComponent(ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")),
            Intent().setComponent(ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager")),

            // Realme
            Intent().setComponent(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")),
            
            // OnePlus
            Intent().setComponent(ComponentName("com.oneplus.security", "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"))
        )

        for (intent in intentList) {
            try {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                activity.startActivity(intent)
                return true
            } catch (ignored: Exception) {
                // Try next
            }
        }

        // Fallback to application details
        return try {
            val intent = Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.parse("package:${activity.packageName}")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            activity.startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * For Xiaomi devices specifically, opens the "Display pop-up windows while running in the background" permission.
     */
    fun openXiaomiBackgroundPopupSettings(activity: Activity): Boolean {
        return try {
            val intent = Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
                putExtra("extra_pkgname", activity.packageName)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            activity.startActivity(intent)
            true
        } catch (e: Exception) {
            openAutostartSettings(activity)
        }
    }
}
