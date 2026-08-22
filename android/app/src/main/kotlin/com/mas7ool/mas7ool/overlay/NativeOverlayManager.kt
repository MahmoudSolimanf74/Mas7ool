package com.mas7ool.mas7ool.overlay

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.*
import com.mas7ool.mas7ool.permissions.PermissionHelper
import org.json.JSONObject

object NativeOverlayManager {

    private const val TAG = "MAS7OOL_OVERLAY"
    private var activeOverlayView: View? = null
    private var isOverlayShowing = false
    private val mainHandler = Handler(Looper.getMainLooper())

    interface OverlayListener {
        fun onDurationSelected(packageName: String, durationMinutes: Int)
        fun onExtendRequested(packageName: String, additionalMinutes: Int)
        fun onCloseAppRequested(packageName: String)
        fun onOverlayDismissed(packageName: String)
    }

    private var listener: OverlayListener? = null

    fun setListener(listener: OverlayListener?) {
        this.listener = listener
    }

    /**
     * Safely closes the monitored app by redirecting to the Android Home screen.
     */
    fun sendToHomeScreen(context: Context) {
        try {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
            }
            context.startActivity(homeIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send to home screen", e)
        }
    }

    /**
     * Shows Duration Picker Overlay when a monitored app is opened.
     */
    @SuppressLint("InflateParams", "SetTextI18n")
    fun showDurationPickerOverlay(
        context: Context,
        packageName: String,
        appName: String
    ) {
        val appContext = context.applicationContext

        mainHandler.post {
            if (activeOverlayView != null || isOverlayShowing) {
                Log.d(TAG, "Duration overlay already showing, ignoring duplicate request")
                return@post
            }

            if (!PermissionHelper.hasOverlayPermission(appContext)) {
                Log.w(TAG, "Overlay permission missing, cannot show overlay")
                return@post
            }

            val windowManager = appContext.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
            if (windowManager == null) {
                Log.e(TAG, "WindowManager is null")
                return@post
            }

            val windowParams = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                else
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.CENTER
                softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
            }

            // Root Dimmed Background
            val rootLayout = FrameLayout(appContext).apply {
                setBackgroundColor(Color.parseColor("#B3000000"))
                layoutDirection = View.LAYOUT_DIRECTION_RTL
                isClickable = true
                isFocusable = true
            }

            // Dialog Card Container
            val cardBackground = GradientDrawable().apply {
                setColor(Color.parseColor("#1E222A"))
                cornerRadius = dpToPx(appContext, 24f)
                setStroke(dpToPx(appContext, 1f).toInt(), Color.parseColor("#334155"))
            }

            val cardContainer = LinearLayout(appContext).apply {
                orientation = LinearLayout.VERTICAL
                background = cardBackground
                setPadding(
                    dpToPx(appContext, 24f).toInt(),
                    dpToPx(appContext, 24f).toInt(),
                    dpToPx(appContext, 24f).toInt(),
                    dpToPx(appContext, 24f).toInt()
                )
                gravity = Gravity.CENTER_HORIZONTAL
                isClickable = true
                isFocusable = true
            }

            val cardParams = FrameLayout.LayoutParams(
                dpToPx(appContext, 340f).toInt(),
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }

            // App Icon
            val iconView = ImageView(appContext).apply {
                try {
                    val appIcon = appContext.packageManager.getApplicationIcon(packageName)
                    setImageDrawable(appIcon)
                } catch (e: Exception) {
                    setImageResource(android.R.drawable.ic_dialog_info)
                }
            }
            val iconParams = LinearLayout.LayoutParams(
                dpToPx(appContext, 54f).toInt(),
                dpToPx(appContext, 54f).toInt()
            ).apply {
                bottomMargin = dpToPx(appContext, 12f).toInt()
            }

            // Header Title
            val titleView = TextView(appContext).apply {
                text = "كم تريد استخدام $appName؟"
                setTextColor(Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 19f)
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
            }
            val titleParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(appContext, 6f).toInt()
            }

            // Subtitle
            val subtitleView = TextView(appContext).apply {
                text = "حدد وقتاً واعياً لجلسة استخدامك الحالية"
                setTextColor(Color.parseColor("#94A3B8"))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                gravity = Gravity.CENTER
            }
            val subtitleParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(appContext, 20f).toInt()
            }

            // Grid / List of Duration Options
            val optionsLayout = LinearLayout(appContext).apply {
                orientation = LinearLayout.HORIZONTAL
                weightSum = 3f
            }
            val optionsParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(appContext, 12f).toInt()
            }

            val durations = listOf(1 to "1 دقيقة", 5 to "5 دقائق", 15 to "15 دقيقة")
            for ((minutes, label) in durations) {
                val btn = createOptionButton(appContext, label) {
                    Log.d(TAG, "Option clicked: $minutes mins for $packageName")
                    saveActiveSessionSync(appContext, packageName, minutes)
                    closeOverlay(appContext)
                    listener?.onDurationSelected(packageName, minutes)
                }
                val btnParams = LinearLayout.LayoutParams(
                    0,
                    dpToPx(appContext, 48f).toInt(),
                    1f
                ).apply {
                    setMargins(dpToPx(appContext, 4f).toInt(), 0, dpToPx(appContext, 4f).toInt(), 0)
                }
                optionsLayout.addView(btn, btnParams)
            }

            // Custom Duration & Dismiss Row
            val customRow = LinearLayout(appContext).apply {
                orientation = LinearLayout.HORIZONTAL
            }
            val customRowParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )

            val customInput = EditText(appContext).apply {
                hint = "مدة مخصصة"
                setHintTextColor(Color.parseColor("#64748B"))
                setTextColor(Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                inputType = android.text.InputType.TYPE_CLASS_NUMBER
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#0F172A"))
                    cornerRadius = dpToPx(appContext, 12f)
                    setStroke(dpToPx(appContext, 1f).toInt(), Color.parseColor("#334155"))
                }
                setPadding(
                    dpToPx(appContext, 12f).toInt(),
                    dpToPx(appContext, 8f).toInt(),
                    dpToPx(appContext, 12f).toInt(),
                    dpToPx(appContext, 8f).toInt()
                )
            }
            val inputParams = LinearLayout.LayoutParams(0, dpToPx(appContext, 46f).toInt(), 1f).apply {
                setMargins(0, 0, dpToPx(appContext, 8f).toInt(), 0)
            }

            val startCustomBtn = Button(appContext).apply {
                text = "بدء"
                setTextColor(Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                typeface = Typeface.DEFAULT_BOLD
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#3B82F6"))
                    cornerRadius = dpToPx(appContext, 12f)
                }
                setOnClickListener {
                    val inputStr = customInput.text.toString().trim()
                    val mins = inputStr.toIntOrNull() ?: 5
                    val validMinutes = if (mins in 1..180) mins else 5
                    Log.d(TAG, "Custom duration clicked: $validMinutes mins for $packageName")
                    saveActiveSessionSync(appContext, packageName, validMinutes)
                    closeOverlay(appContext)
                    listener?.onDurationSelected(packageName, validMinutes)
                }
            }
            val startCustomParams = LinearLayout.LayoutParams(
                dpToPx(appContext, 75f).toInt(),
                dpToPx(appContext, 46f).toInt()
            )

            customRow.addView(customInput, inputParams)
            customRow.addView(startCustomBtn, startCustomParams)

            // Dismiss Button (Safe Exit / Cancel)
            val cancelBtn = Button(appContext).apply {
                text = "الرجوع وإغلاق"
                setTextColor(Color.parseColor("#EF4444"))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                setBackgroundColor(Color.TRANSPARENT)
                setOnClickListener {
                    Log.d(TAG, "Cancel & Close clicked for $packageName")
                    closeOverlay(appContext)
                    sendToHomeScreen(appContext)
                    listener?.onCloseAppRequested(packageName)
                }
            }
            val cancelParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                dpToPx(appContext, 40f).toInt()
            ).apply {
                topMargin = dpToPx(appContext, 12f).toInt()
            }

            cardContainer.addView(iconView, iconParams)
            cardContainer.addView(titleView, titleParams)
            cardContainer.addView(subtitleView, subtitleParams)
            cardContainer.addView(optionsLayout, optionsParams)
            cardContainer.addView(customRow, customRowParams)
            cardContainer.addView(cancelBtn, cancelParams)

            rootLayout.addView(cardContainer, cardParams)

            try {
                windowManager.addView(rootLayout, windowParams)
                activeOverlayView = rootLayout
                isOverlayShowing = true
                Log.d(TAG, "Duration overlay successfully attached to WindowManager for $packageName")
            } catch (e: Exception) {
                Log.e(TAG, "WindowManager addView failed for $packageName", e)
            }
        }
    }

    /**
     * Shows Expired Overlay when the active session reaches zero.
     */
    @SuppressLint("SetTextI18n")
    fun showSessionExpiredOverlay(
        context: Context,
        packageName: String,
        appName: String
    ) {
        val appContext = context.applicationContext

        mainHandler.post {
            if (activeOverlayView != null || isOverlayShowing) {
                Log.d(TAG, "Expired overlay already showing, ignoring duplicate request")
                return@post
            }

            if (!PermissionHelper.hasOverlayPermission(appContext)) {
                Log.w(TAG, "Overlay permission missing for expired overlay!")
                return@post
            }

            val windowManager = appContext.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
            if (windowManager == null) {
                Log.e(TAG, "WindowManager service is null")
                return@post
            }

            val windowParams = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                else
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.CENTER
            }

            val rootLayout = FrameLayout(appContext).apply {
                setBackgroundColor(Color.parseColor("#CC000000"))
                layoutDirection = View.LAYOUT_DIRECTION_RTL
                isClickable = true
                isFocusable = true
            }

            val cardBackground = GradientDrawable().apply {
                setColor(Color.parseColor("#1C1917"))
                cornerRadius = dpToPx(appContext, 24f)
                setStroke(dpToPx(appContext, 2f).toInt(), Color.parseColor("#EF4444"))
            }

            val cardContainer = LinearLayout(appContext).apply {
                orientation = LinearLayout.VERTICAL
                background = cardBackground
                setPadding(
                    dpToPx(appContext, 24f).toInt(),
                    dpToPx(appContext, 24f).toInt(),
                    dpToPx(appContext, 24f).toInt(),
                    dpToPx(appContext, 24f).toInt()
                )
                gravity = Gravity.CENTER_HORIZONTAL
                isClickable = true
                isFocusable = true
            }

            val cardParams = FrameLayout.LayoutParams(
                dpToPx(appContext, 330f).toInt(),
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }

            // Warning Icon
            val warningIcon = ImageView(appContext).apply {
                setImageResource(android.R.drawable.ic_dialog_alert)
                setColorFilter(Color.parseColor("#EF4444"))
            }
            val iconParams = LinearLayout.LayoutParams(
                dpToPx(appContext, 54f).toInt(),
                dpToPx(appContext, 54f).toInt()
            ).apply {
                bottomMargin = dpToPx(appContext, 12f).toInt()
            }

            // Title
            val titleView = TextView(appContext).apply {
                text = "انتهى الوقت المحدد!"
                setTextColor(Color.parseColor("#FCA5A5"))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
            }
            val titleParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(appContext, 6f).toInt()
            }

            // Description
            val descView = TextView(appContext).apply {
                text = "لقد استنفدت وقت الجلسة لتطبيق $appName. حان وقت التركيز وإغلاق التطبيق."
                setTextColor(Color.parseColor("#D6D3D1"))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                gravity = Gravity.CENTER
            }
            val descParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(appContext, 24f).toInt()
            }

            // Actions Buttons Container
            val actionsLayout = LinearLayout(appContext).apply {
                orientation = LinearLayout.VERTICAL
            }
            val actionsParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )

            // Close App Button (Primary Action)
            val closeBtn = Button(appContext).apply {
                text = "إغلاق التطبيق"
                setTextColor(Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                typeface = Typeface.DEFAULT_BOLD
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#DC2626"))
                    cornerRadius = dpToPx(appContext, 14f)
                }
                setOnClickListener {
                    Log.d(TAG, "Expired: Close App clicked for $packageName")
                    removeActiveSessionSync(appContext, packageName)
                    closeOverlay(appContext)
                    sendToHomeScreen(appContext)
                    listener?.onCloseAppRequested(packageName)
                }
            }
            val closeBtnParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dpToPx(appContext, 50f).toInt()
            ).apply {
                bottomMargin = dpToPx(appContext, 10f).toInt()
            }

            // +1 Minute Extension Button
            val extendBtn = Button(appContext).apply {
                text = "+ تمديد دقيقة واحدة فقط"
                setTextColor(Color.parseColor("#F59E0B"))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                typeface = Typeface.DEFAULT_BOLD
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#292524"))
                    cornerRadius = dpToPx(appContext, 14f)
                    setStroke(dpToPx(appContext, 1f).toInt(), Color.parseColor("#78350F"))
                }
                setOnClickListener {
                    Log.d(TAG, "Expired: Extend +1m clicked for $packageName")
                    saveActiveSessionSync(appContext, packageName, 1)
                    closeOverlay(appContext)
                    listener?.onExtendRequested(packageName, 1)
                }
            }
            val extendBtnParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dpToPx(appContext, 46f).toInt()
            )

            actionsLayout.addView(closeBtn, closeBtnParams)
            actionsLayout.addView(extendBtn, extendBtnParams)

            cardContainer.addView(warningIcon, iconParams)
            cardContainer.addView(titleView, titleParams)
            cardContainer.addView(descView, descParams)
            cardContainer.addView(actionsLayout, actionsParams)

            rootLayout.addView(cardContainer, cardParams)

            try {
                windowManager.addView(rootLayout, windowParams)
                activeOverlayView = rootLayout
                isOverlayShowing = true
                Log.d(TAG, "Expired overlay successfully displayed for $packageName")
            } catch (e: Exception) {
                Log.e(TAG, "WindowManager addView failed for expired overlay $packageName", e)
            }
        }
    }

    /**
     * Closes any currently displayed overlay window.
     */
    fun closeOverlay(context: Context) {
        val appContext = context.applicationContext
        mainHandler.post {
            activeOverlayView?.let { view ->
                try {
                    val windowManager = appContext.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
                    if (view.isAttachedToWindow) {
                        windowManager?.removeViewImmediate(view)
                    }
                } catch (e: Exception) {
                    try {
                        val windowManager = appContext.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
                        windowManager?.removeView(view)
                    } catch (e2: Exception) {
                        Log.e(TAG, "Failed to remove overlay view", e2)
                    }
                }
            }
            activeOverlayView = null
            isOverlayShowing = false
            Log.d(TAG, "Overlay closed and removed from window")
        }
    }

    private fun saveActiveSessionSync(context: Context, packageName: String, minutes: Int) {
        try {
            val prefs = context.getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
            val currentJson = prefs.getString("active_sessions", "{}") ?: "{}"
            val json = JSONObject(currentJson)
            val expiresAt = System.currentTimeMillis() + (minutes * 60 * 1000L)
            json.put(packageName, expiresAt)
            prefs.edit().putString("active_sessions", json.toString()).apply()
        } catch (e: Exception) {
            Log.e(TAG, "Error saving active session sync", e)
        }
    }

    private fun removeActiveSessionSync(context: Context, packageName: String) {
        try {
            val prefs = context.getSharedPreferences("mas7ool_prefs", Context.MODE_PRIVATE)
            val currentJson = prefs.getString("active_sessions", "{}") ?: "{}"
            val json = JSONObject(currentJson)
            json.remove(packageName)
            prefs.edit().putString("active_sessions", json.toString()).apply()
        } catch (e: Exception) {
            Log.e(TAG, "Error removing active session sync", e)
        }
    }

    private fun createOptionButton(
        context: Context,
        text: String,
        onClick: () -> Unit
    ): Button {
        return Button(context).apply {
            this.text = text
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#2563EB"))
                cornerRadius = dpToPx(context, 12f)
            }
            setOnClickListener { onClick() }
        }
    }

    private fun dpToPx(context: Context, dp: Float): Float {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            context.resources.displayMetrics
        )
    }

    fun isShowing(): Boolean = isOverlayShowing || activeOverlayView != null
}
