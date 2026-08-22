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

class ForegroundMonitoringService : Service() {

    companion object {
        const val ACTION_START = "com.mas7ool.action.START_MONITORING"
        const val ACTION_STOP = "com.mas7ool.action.STOP_MONITORING"
        const val ACTION_UPDATE_CONFIG = "com.mas7ool.action.UPDATE_CONFIG"

        const val CHANNEL_ID = "mas7ool_monitoring_service_channel"
        const val NOTIFICATION_ID = 1001

        var isRunning: Boolean = false
            private set

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
    }

    private var serviceJob: Job? = null
    private val serviceScope = CoroutineScope(Dispatchers.Default + Job())
    private lateinit var detector: ForegroundAppDetector

    override fun onCreate() {
        super.onCreate()
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
        if (isMonitored && !hasActiveValidSession && !NativeOverlayManager.isShowing()) {
            NativeOverlayManager.showDurationPickerOverlay(
                context = this,
                packageName = event.packageName,
                appName = event.appName
            )
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
            val channel = NotificationChannel(
                CHANNEL_ID,
                "خدمة مراقبة استخدام التطبيقات (مسؤول)",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "إشعار دائم لتشغيل خدمة المراقبة في الخلفية"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
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
            .setContentTitle("مسؤول (Mas7ool)")
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)

        return builder.build()
    }

    override fun onDestroy() {
        stopMonitoring()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
