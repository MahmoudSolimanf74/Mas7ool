package com.mas7ool.mas7ool.monitoring

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.mas7ool.mas7ool.MainActivity
import com.mas7ool.mas7ool.R
import com.mas7ool.mas7ool.overlay.NativeOverlayManager
import kotlinx.coroutines.*
import org.json.JSONObject

import android.os.SystemClock
import android.widget.RemoteViews

class ForegroundMonitoringService : Service() {

    companion object {
        const val ACTION_START = "com.mas7ool.action.START_MONITORING"
        const val ACTION_STOP = "com.mas7ool.action.STOP_MONITORING"
        const val ACTION_UPDATE_CONFIG = "com.mas7ool.action.UPDATE_CONFIG"
        const val ACTION_END_SESSION = "com.mas7ool.action.END_SESSION"
        const val ACTION_END_SESSION_BROADCAST = "com.mas7ool.action.END_SESSION_BROADCAST"
        const val ACTION_UPDATE_NOTIFICATION = "com.mas7ool.action.UPDATE_NOTIFICATION"
        const val EXTRA_PACKAGE_NAME = "extra_package_name"
        const val EXTRA_APP_NAME = "extra_app_name"
        const val EXTRA_EXPIRES_AT = "extra_expires_at"

        const val CHANNEL_ID = "mas7ool_service_v10"
        const val NOTIFICATION_ID = 1001

        var isRunning: Boolean = false
            private set

        private var instance: ForegroundMonitoringService? = null

        fun start(context: Context) {
            val intent = Intent(context, ForegroundMonitoringService::class.java).apply {
                action = ACTION_START
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, ForegroundMonitoringService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }

        fun endSessionFromAction(context: Context, packageName: String) {
            instance?.handleEndSession(packageName) ?: run {
                val intent = Intent(context, ForegroundMonitoringService::class.java).apply {
                    action = ACTION_END_SESSION
                    putExtra(EXTRA_PACKAGE_NAME, packageName)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            }
        }

        fun updateSessionNotification(context: Context, packageName: String, appName: String, expiresAt: Long) {
            instance?.let { service ->
                service.showSessionNotificationDirect(packageName, appName, expiresAt)
                return
            }
            val intent = Intent(context, ForegroundMonitoringService::class.java).apply {
                action = ACTION_UPDATE_NOTIFICATION
                putExtra(EXTRA_PACKAGE_NAME, packageName)
                putExtra(EXTRA_APP_NAME, appName)
                putExtra(EXTRA_EXPIRES_AT, expiresAt)
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                // Ignore
            }
        }

        fun resetNotification(context: Context) {
            instance?.let { service ->
                service.resetNotificationToDefault()
                return
            }
            val intent = Intent(context, ForegroundMonitoringService::class.java).apply {
                action = ACTION_UPDATE_NOTIFICATION
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                // Ignore
            }
        }
    }

    private var serviceJob: Job? = null
    private val serviceScope = CoroutineScope(Dispatchers.Default + Job())
    private lateinit var detector: ForegroundAppDetector
    private var isShowingSessionNotification = false
    private var lastActivePkg: String = ""
    private var lastExpiresAt: Long = 0L
    private var lastNotifiedSeconds: Long = -1L

    override fun onCreate() {
        super.onCreate()
        instance = this
        detector = ForegroundAppDetector(this)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopMonitoring()
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_END_SESSION -> {
                val pkg = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: ""
                handleEndSession(pkg)
                return START_STICKY
            }
            ACTION_UPDATE_NOTIFICATION -> {
                val pkg = intent.getStringExtra(EXTRA_PACKAGE_NAME)
                val appName = intent.getStringExtra(EXTRA_APP_NAME) ?: ""
                val expiresAt = intent.getLongExtra(EXTRA_EXPIRES_AT, 0L)
                if (!pkg.isNullOrEmpty() && expiresAt > System.currentTimeMillis()) {
                    showSessionNotificationDirect(pkg, appName, expiresAt)
                } else {
                    resetNotificationToDefault()
                }
                return START_STICKY
            }
            ACTION_START, null -> {
                startMonitoring()
            }
        }
        return START_STICKY
    }

    private fun startMonitoring() {
        if (isRunning) return
        isRunning = true

        val notification = buildForegroundNotification("المراقبة نشطة - الحفاظ على وقتك")
        startForeground(NOTIFICATION_ID, notification)

        // Save running state to SharedPreferences for BootReceiver
        val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("monitoring_enabled", true).apply()

        serviceJob = serviceScope.launch {
            while (isActive && isRunning) {
                try {
                    val event = detector.detectForegroundApp()
                    if (event != null) {
                        handleForegroundApp(event)
                    }
                    checkNativeSessionExpirations()
                    updateForegroundNotificationIfNeeded()
                } catch (e: Exception) {
                    // Loop protection
                }
                delay(800L)
            }
        }
    }

    private fun handleForegroundApp(event: ForegroundEvent) {
        val eventMap = mapOf(
            "packageName" to event.packageName,
            "appName" to event.appName,
            "timestamp" to event.timestamp,
            "eventType" to event.eventType
        )

        // 1. If Flutter eventSink is alive, deliver event to Dart
        if (MainActivity.isEventSinkAvailable()) {
            MainActivity.sendForegroundEvent(eventMap)
            return
        }

        // 2. Flutter is backgrounded/inactive -> Native fallback
        val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
        val monitoredListJson = prefs.getString("monitored_packages", "[]") ?: "[]"
        val activeSessionsJson = prefs.getString("active_sessions", "{}") ?: "{}"

        val isMonitored = try {
            val jsonArray = org.json.JSONArray(monitoredListJson)
            var found = false
            for (i in 0 until jsonArray.length()) {
                if (jsonArray.getString(i) == event.packageName) {
                    found = true
                    break
                }
            }
            found
        } catch (e: Exception) {
            false
        }

        val hasActiveValidSession = try {
            val sessionsObj = JSONObject(activeSessionsJson)
            if (sessionsObj.has(event.packageName)) {
                val expiresAt = sessionsObj.getLong(event.packageName)
                expiresAt > System.currentTimeMillis()
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }

        // If Flutter UI is not active and this app is monitored without active session, trigger overlay
        android.util.Log.d(
            "Mas7oolService",
            "App check: ${event.packageName} (isMonitored=$isMonitored, activeSession=$hasActiveValidSession, overlayShowing=${NativeOverlayManager.isShowing()})"
        )

        if (isMonitored && !hasActiveValidSession && !NativeOverlayManager.isShowing()) {
            android.util.Log.i("Mas7oolService", "Triggering native overlay for ${event.packageName}")
            NativeOverlayManager.showDurationPickerOverlay(
                context = this,
                packageName = event.packageName,
                appName = event.appName
            )
        }
    }

    private fun checkNativeSessionExpirations() {
        if (MainActivity.isEventSinkAvailable()) return

        val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
        val activeSessionsJson = prefs.getString("active_sessions", "{}") ?: "{}"
        if (activeSessionsJson == "{}") return

        try {
            val sessionsObj = JSONObject(activeSessionsJson)
            val keys = sessionsObj.keys()
            val now = System.currentTimeMillis()
            val expiredKeys = mutableListOf<String>()

            while (keys.hasNext()) {
                val pkg = keys.next()
                val expiresAt = sessionsObj.getLong(pkg)
                if (now >= expiresAt) {
                    expiredKeys.add(pkg)
                }
            }

            for (pkg in expiredKeys) {
                sessionsObj.remove(pkg)
                prefs.edit().putString("active_sessions", sessionsObj.toString()).apply()

                val currentForeground = detector.getRawForegroundPackage()
                if (currentForeground == pkg) {
                    NativeOverlayManager.showSessionExpiredOverlay(
                        context = this,
                        packageName = pkg,
                        appName = detector.getAppName(pkg)
                    )
                }
            }
        } catch (e: Exception) {
            // Ignore parse errors
        }
    }

    private fun stopMonitoring() {
        isRunning = false
        serviceJob?.cancel()
        detector.resetState()

        val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("monitoring_enabled", false).apply()

        stopForeground(STOP_FOREGROUND_REMOVE)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)

            // Delete legacy channels so the system re-creates clean channels
            try {
                manager?.deleteNotificationChannel("mas7ool_monitoring_service_channel")
                manager?.deleteNotificationChannel("mas7ool_session_active_v3")
                manager?.deleteNotificationChannel("mas7ool_channel_v7")
                manager?.deleteNotificationChannel("mas7ool_service_v9")
            } catch (e: Exception) {
                // Ignore
            }

            // High importance channel ensures action buttons are visible by default
            val channel = NotificationChannel(
                CHANNEL_ID,
                "جلسة ومراقبة التطبيقات (Mas7ool)",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "إشعار المراقبة وتتبع وقت الجلسات النشطة"
                setSound(null, null) // Silent!
                enableVibration(false)
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            manager?.createNotificationChannel(channel)
        }
    }

    private fun buildForegroundNotification(contentText: String): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Mas7ool")
            .setContentText(contentText)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)

        return builder.build()
    }

    private fun buildSessionNotification(
        packageName: String,
        appName: String,
        expiresAt: Long
    ): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val endIntent = Intent(this, EndSessionReceiver::class.java).apply {
            action = ACTION_END_SESSION_BROADCAST
            setPackage(applicationContext.packageName)
            putExtra(EXTRA_PACKAGE_NAME, packageName)
        }
        val endPendingIntent = PendingIntent.getBroadcast(
            this,
            201,
            endIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val remainingMs = (expiresAt - System.currentTimeMillis()).coerceAtLeast(0L)
        val totalSecs = remainingMs / 1000L
        val mins = totalSecs / 60L
        val secs = totalSecs % 60L
        val timeFormatted = String.format(java.util.Locale.US, "%02d:%02d", mins, secs)

        val displayName = if (appName.isNotBlank()) appName else detector.getAppName(packageName)

        // 1. Custom RemoteViews with exact remaining time
        val collapsedView = RemoteViews(applicationContext.packageName, R.layout.notification_session_small).apply {
            setTextViewText(R.id.notif_title, "جلسة نشطة: $displayName")
            setTextViewText(R.id.notif_timer_text, timeFormatted)
            setOnClickPendingIntent(R.id.btn_end_session, endPendingIntent)
        }

        val expandedView = RemoteViews(applicationContext.packageName, R.layout.notification_session_big).apply {
            setTextViewText(R.id.notif_title, "جلسة نشطة: $displayName")
            setTextViewText(R.id.notif_timer_text, timeFormatted)
            setOnClickPendingIntent(R.id.btn_end_session, endPendingIntent)
        }

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("جلسة نشطة: $displayName")
            .setContentText("الوقت المتبقي: $timeFormatted")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setContentIntent(pendingIntent)
            .setShowWhen(false)
            .setCustomContentView(collapsedView)
            .setCustomBigContentView(expandedView)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())

        return builder.build()
    }

    fun showSessionNotificationDirect(packageName: String, appName: String, expiresAt: Long) {
        val notification = buildSessionNotification(packageName, appName, expiresAt)
        val manager = getSystemService(NotificationManager::class.java)
        manager?.notify(NOTIFICATION_ID, notification)
        isShowingSessionNotification = true
        lastActivePkg = packageName
        lastExpiresAt = expiresAt
        val remainingMs = (expiresAt - System.currentTimeMillis()).coerceAtLeast(0L)
        lastNotifiedSeconds = remainingMs / 1000L
    }

    fun resetNotificationToDefault() {
        if (!isRunning) return
        val notification = buildForegroundNotification("المراقبة نشطة - الحفاظ على وقتك")
        val manager = getSystemService(NotificationManager::class.java)
        manager?.notify(NOTIFICATION_ID, notification)
        isShowingSessionNotification = false
        lastActivePkg = ""
        lastExpiresAt = 0L
        lastNotifiedSeconds = -1L
    }

    private fun updateForegroundNotificationIfNeeded() {
        val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
        val activeSessionsJson = prefs.getString("active_sessions", "{}") ?: "{}"
        if (activeSessionsJson == "{}" || activeSessionsJson.isEmpty()) {
            if (isShowingSessionNotification) {
                resetNotificationToDefault()
            }
            return
        }

        try {
            val sessionsObj = JSONObject(activeSessionsJson)
            val keys = sessionsObj.keys()
            val now = System.currentTimeMillis()
            var foundActive = false
            var activePkg = ""
            var activeExpiresAt = 0L

            while (keys.hasNext()) {
                val pkg = keys.next()
                val expiresAt = sessionsObj.getLong(pkg)
                if (expiresAt > now) {
                    foundActive = true
                    activePkg = pkg
                    activeExpiresAt = expiresAt
                    break
                }
            }

            if (foundActive) {
                val remainingMs = (activeExpiresAt - now).coerceAtLeast(0L)
                val currentSecs = remainingMs / 1000L
                val isExpiryChanged = Math.abs(activeExpiresAt - lastExpiresAt) > 1500L
                val isSecondChanged = currentSecs != lastNotifiedSeconds

                if (!isShowingSessionNotification || activePkg != lastActivePkg || isExpiryChanged || isSecondChanged) {
                    val appNamesJson = prefs.getString("active_session_app_names", "{}") ?: "{}"
                    val namesObj = JSONObject(appNamesJson)
                    val appName = if (namesObj.has(activePkg)) namesObj.getString(activePkg) else detector.getAppName(activePkg)

                    val notification = buildSessionNotification(activePkg, appName, activeExpiresAt)
                    val manager = getSystemService(NotificationManager::class.java)
                    manager?.notify(NOTIFICATION_ID, notification)

                    isShowingSessionNotification = true
                    lastActivePkg = activePkg
                    lastExpiresAt = activeExpiresAt
                    lastNotifiedSeconds = currentSecs
                }
            } else {
                if (isShowingSessionNotification) {
                    resetNotificationToDefault()
                }
            }
        } catch (e: Exception) {
            // Loop protection
        }
    }

    fun handleEndSession(packageName: String) {
        android.util.Log.i("ForegroundMonitoringService", "Ending session from notification: $packageName")
        val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
        val currentJson = prefs.getString("active_sessions", "{}") ?: "{}"
        var targetPkg = packageName

        try {
            val obj = JSONObject(currentJson)
            if (targetPkg.isEmpty() && obj.keys().hasNext()) {
                targetPkg = obj.keys().next()
            }
            if (targetPkg.isNotEmpty()) {
                obj.remove(targetPkg)
                prefs.edit().putString("active_sessions", obj.toString()).apply()
            }
            val appNamesJson = prefs.getString("active_session_app_names", "{}") ?: "{}"
            val namesObj = JSONObject(appNamesJson)
            if (targetPkg.isNotEmpty()) {
                namesObj.remove(targetPkg)
                prefs.edit().putString("active_session_app_names", namesObj.toString()).apply()
            }
        } catch (e: Exception) {
            // Ignore
        }

        // Close any native overlay
        NativeOverlayManager.closeOverlay(this)

        // If user is currently inside this app, redirect to home screen safely
        val currentForeground = detector.getRawForegroundPackage()
        if (targetPkg.isNotEmpty() && currentForeground == targetPkg) {
            NativeOverlayManager.sendToHomeScreen(this)
        }

        // Send event to Flutter (if running) so SessionEngine can end session in SQLite database
        if (MainActivity.isEventSinkAvailable()) {
            MainActivity.sendForegroundEvent(mapOf(
                "action" to "endSession",
                "packageName" to targetPkg
            ))
        }

        resetNotificationToDefault()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
        val isMonitoringEnabled = prefs.getBoolean("monitoring_enabled", true)

        if (isMonitoringEnabled) {
            val restartIntent = Intent(applicationContext, RestartServiceReceiver::class.java).apply {
                action = "com.mas7ool.action.RESTART_SERVICE"
            }
            val pendingIntent = PendingIntent.getBroadcast(
                applicationContext,
                101,
                restartIntent,
                PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
            )
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            alarmManager?.set(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                SystemClock.elapsedRealtime() + 1000,
                pendingIntent
            )
        }
    }

    override fun onDestroy() {
        if (instance == this) {
            instance = null
        }
        val prefs = getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
        val isMonitoringEnabled = prefs.getBoolean("monitoring_enabled", true)
        if (isMonitoringEnabled && isRunning) {
            val restartIntent = Intent(applicationContext, RestartServiceReceiver::class.java).apply {
                action = "com.mas7ool.action.RESTART_SERVICE"
            }
            val pendingIntent = PendingIntent.getBroadcast(
                applicationContext,
                102,
                restartIntent,
                PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
            )
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            alarmManager?.set(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                SystemClock.elapsedRealtime() + 1000,
                pendingIntent
            )
        }
        isRunning = false
        serviceJob?.cancel()
        detector.resetState()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
