package com.mas7ool.mas7ool

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.mas7ool.mas7ool.compatibility.ManufacturerHelper
import com.mas7ool.mas7ool.monitoring.ForegroundAppDetector
import com.mas7ool.mas7ool.monitoring.ForegroundMonitoringService
import com.mas7ool.mas7ool.overlay.NativeOverlayManager
import com.mas7ool.mas7ool.permissions.PermissionHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class MainActivity : FlutterActivity(), NativeOverlayManager.OverlayListener {

    companion object {
        private const val TAG = "MainActivity"
        const val METHOD_CHANNEL = "com.mas7ool/native_bridge"
        const val EVENT_CHANNEL = "com.mas7ool/monitoring_events"

        private var eventSink: EventChannel.EventSink? = null
        private val mainHandler = Handler(Looper.getMainLooper())
        var isFlutterActive: Boolean = false
            private set

        fun isEventSinkAvailable(): Boolean = isFlutterActive && eventSink != null

        fun sendForegroundEvent(eventData: Map<String, Any>) {
            if (!isEventSinkAvailable()) return
            mainHandler.post {
                try {
                    if (isFlutterActive && eventSink != null) {
                        eventSink?.success(eventData)
                    }
                } catch (e: Exception) {
                    android.util.Log.w(TAG, "EventSink delivery failed: ${e.message}")
                    isFlutterActive = false
                    eventSink = null
                }
            }
        }
    }

    private val bgExecutor = Executors.newSingleThreadExecutor()
    private lateinit var detector: ForegroundAppDetector

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        isFlutterActive = true

        detector = ForegroundAppDetector(this)
        NativeOverlayManager.setListener(this)

        // Setup EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    isFlutterActive = true
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    isFlutterActive = false
                }
            }
        )

        // Setup MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkPermission" -> {
                val typeStr = call.argument<String>("type")
                val state = when (typeStr) {
                    "usageAccess" -> PermissionHelper.checkPermission(this, PermissionHelper.AppPermissionType.USAGE_ACCESS)
                    "overlay" -> PermissionHelper.checkPermission(this, PermissionHelper.AppPermissionType.OVERLAY)
                    "notifications" -> PermissionHelper.checkPermission(this, PermissionHelper.AppPermissionType.NOTIFICATIONS)
                    "batteryOptimization" -> PermissionHelper.checkPermission(this, PermissionHelper.AppPermissionType.BATTERY_OPTIMIZATION)
                    else -> PermissionHelper.PermissionState.UNKNOWN
                }
                result.success(state.name.lowercase())
            }

            "openSettings" -> {
                val typeStr = call.argument<String>("type")
                val success = when (typeStr) {
                    "usageAccess" -> PermissionHelper.openUsageAccessSettings(this)
                    "overlay" -> PermissionHelper.openOverlaySettings(this)
                    "notifications" -> PermissionHelper.openNotificationSettings(this)
                    "batteryOptimization" -> PermissionHelper.openBatteryOptimizationSettings(this)
                    "appDetails" -> PermissionHelper.openAppDetailsSettings(this)
                    else -> false
                }
                result.success(success)
            }

            "startMonitoringService" -> {
                ForegroundMonitoringService.start(this)
                result.success(true)
            }

            "stopMonitoringService" -> {
                ForegroundMonitoringService.stop(this)
                result.success(true)
            }

            "isMonitoringServiceRunning" -> {
                result.success(ForegroundMonitoringService.isRunning)
            }

            "getInstalledApps" -> {
                val includeSystem = call.argument<Boolean>("includeSystem") ?: false
                bgExecutor.execute {
                    val appsList = fetchInstalledApps(includeSystem)
                    runOnUiThread {
                        result.success(appsList)
                    }
                }
            }

            "sendToHomeScreen" -> {
                NativeOverlayManager.sendToHomeScreen(this)
                result.success(true)
            }

            "showDurationPickerOverlay" -> {
                val packageName = call.argument<String>("packageName") ?: ""
                val appName = call.argument<String>("appName") ?: ""
                NativeOverlayManager.showDurationPickerOverlay(this, packageName, appName)
                result.success(true)
            }

            "showSessionExpiredOverlay" -> {
                val packageName = call.argument<String>("packageName") ?: ""
                val appName = call.argument<String>("appName") ?: ""
                NativeOverlayManager.showSessionExpiredOverlay(this, packageName, appName)
                result.success(true)
            }

            "closeOverlay" -> {
                NativeOverlayManager.closeOverlay(this)
                result.success(true)
            }

            "syncMonitoredPackages" -> {
                val list = call.argument<List<String>>("packages") ?: emptyList()
                val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
                val jsonArr = JSONArray(list)
                prefs.edit().putString("monitored_packages", jsonArr.toString()).apply()
                result.success(true)
            }

            "syncActiveSession" -> {
                val packageName = call.argument<String>("packageName") ?: ""
                val appName = call.argument<String>("appName") ?: ""
                val expiresAt = (call.argument<Number>("expiresAt"))?.toLong() ?: 0L
                val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
                val currentJson = prefs.getString("active_sessions", "{}") ?: "{}"
                val json = JSONObject(currentJson)
                json.put(packageName, expiresAt)
                prefs.edit().putString("active_sessions", json.toString()).apply()

                val appNamesJson = prefs.getString("active_session_app_names", "{}") ?: "{}"
                val namesObj = JSONObject(appNamesJson)
                val finalAppName = if (appName.isNotEmpty()) appName else detector.getAppName(packageName)
                namesObj.put(packageName, finalAppName)
                prefs.edit().putString("active_session_app_names", namesObj.toString()).apply()

                ForegroundMonitoringService.updateSessionNotification(this, packageName, finalAppName, expiresAt)
                result.success(true)
            }

            "isSessionActiveInNative" -> {
                val packageName = call.argument<String>("packageName") ?: ""
                val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
                val currentJson = prefs.getString("active_sessions", "{}") ?: "{}"
                val json = JSONObject(currentJson)
                val isActive = if (json.has(packageName)) {
                    val expiresAt = json.getLong(packageName)
                    expiresAt > System.currentTimeMillis()
                } else {
                    false
                }
                result.success(isActive)
            }

            "removeActiveSession" -> {
                val packageName = call.argument<String>("packageName") ?: ""
                val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
                val currentJson = prefs.getString("active_sessions", "{}") ?: "{}"
                val json = JSONObject(currentJson)
                json.remove(packageName)
                prefs.edit().putString("active_sessions", json.toString()).apply()

                val appNamesJson = prefs.getString("active_session_app_names", "{}") ?: "{}"
                val namesObj = JSONObject(appNamesJson)
                namesObj.remove(packageName)
                prefs.edit().putString("active_session_app_names", namesObj.toString()).apply()

                ForegroundMonitoringService.resetNotification(this)
                result.success(true)
            }

            "getDeviceInfo" -> {
                result.success(ManufacturerHelper.getDeviceInfo())
            }

            "openManufacturerAutostart" -> {
                result.success(ManufacturerHelper.openAutostartSettings(this))
            }

            "openXiaomiBackgroundPopup" -> {
                result.success(ManufacturerHelper.openXiaomiBackgroundPopupSettings(this))
            }

            "getCurrentForegroundPackage" -> {
                val pkg = detector.getRawForegroundPackage()
                result.success(pkg)
            }

            "getAppIcon" -> {
                val packageName = call.argument<String>("packageName") ?: ""
                bgExecutor.execute {
                    val bytes = fetchAppIcon(packageName)
                    runOnUiThread {
                        result.success(bytes)
                    }
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun fetchAppIcon(packageName: String): ByteArray? {
        if (packageName.isBlank()) return null
        return try {
            val pm = packageManager
            val drawable: Drawable = try {
                val launchIntent = pm.getLaunchIntentForPackage(packageName)
                if (launchIntent != null) {
                    val resolveInfo = pm.resolveActivity(launchIntent, 0)
                    resolveInfo?.loadIcon(pm) ?: pm.getApplicationIcon(packageName)
                } else {
                    pm.getApplicationIcon(packageName)
                }
            } catch (e: Exception) {
                try {
                    pm.getApplicationIcon(packageName)
                } catch (e2: Exception) {
                    pm.defaultActivityIcon
                }
            }
            val bitmap = drawableToBitmap(drawable)
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            android.util.Log.w(TAG, "Failed to fetch icon for $packageName: ${e.message}")
            null
        }
    }

    private fun fetchInstalledApps(includeSystem: Boolean): List<Map<String, Any?>> {
        val appsList = mutableListOf<Map<String, Any?>>()
        val pm = packageManager

        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(intent, 0)
        }

        val seenPackages = mutableSetOf<String>()

        for (info in resolveInfos) {
            val appInfo = info.activityInfo.applicationInfo
            val packageName = appInfo.packageName

            // Skip self and already added
            if (packageName == this.packageName || seenPackages.contains(packageName)) continue

            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            if (isSystem && !includeSystem) {
                // Skip system launcher or framework apps unless user wants them
                continue
            }

            val appName = try {
                info.loadLabel(pm).toString()
            } catch (e: Exception) {
                packageName
            }

            val iconBytes = try {
                val drawable = info.loadIcon(pm)
                val bitmap = drawableToBitmap(drawable)
                val stream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
                stream.toByteArray()
            } catch (e: Exception) {
                null
            }

            seenPackages.add(packageName)
            appsList.add(
                mapOf(
                    "packageName" to packageName,
                    "appName" to appName,
                    "isSystemApp" to isSystem,
                    "iconBytes" to iconBytes
                )
            )
        }

        return appsList.sortedBy { (it["appName"] as? String)?.lowercase() ?: "" }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth.coerceIn(48, 144) else 96
        val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight.coerceIn(48, 144) else 96
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    // Overlay Listeners to stream back to Flutter
    override fun onDurationSelected(packageName: String, durationMinutes: Int) {
        val data = mapOf(
            "action" to "durationSelected",
            "packageName" to packageName,
            "durationMinutes" to durationMinutes
        )
        sendForegroundEvent(data)
    }

    override fun onExtendRequested(packageName: String, additionalMinutes: Int) {
        val data = mapOf(
            "action" to "extendSession",
            "packageName" to packageName,
            "additionalMinutes" to additionalMinutes
        )
        sendForegroundEvent(data)
    }

    override fun onCloseAppRequested(packageName: String) {
        val data = mapOf(
            "action" to "closeApp",
            "packageName" to packageName
        )
        sendForegroundEvent(data)
    }

    override fun onOverlayDismissed(packageName: String) {
        val data = mapOf(
            "action" to "overlayDismissed",
            "packageName" to packageName
        )
        sendForegroundEvent(data)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        isFlutterActive = false
        eventSink = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onDestroy() {
        isFlutterActive = false
        eventSink = null
        NativeOverlayManager.setListener(null)
        super.onDestroy()
    }
}
