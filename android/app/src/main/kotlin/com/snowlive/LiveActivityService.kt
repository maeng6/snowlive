package com.snowlive

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import android.os.SystemClock
import android.text.SpannableString
import android.text.style.StyleSpan
import android.graphics.Typeface
import android.text.Html
import android.os.Build as AndroidBuild
import java.text.SimpleDateFormat
import java.util.*

class LiveActivityService : Service() {

    companion object {
        const val CHANNEL_ID = "live_activity_channel"
        const val NOTIFICATION_ID = 9999
        const val ACTION_START = "ACTION_START"
        const val ACTION_UPDATE = "ACTION_UPDATE"
        const val ACTION_STOP = "ACTION_STOP"

        private var isRunning = false
        private var startTimeMs: Long = 0
        private var todayRideCount: Int = 0
        private var sessionRideCount: Int = 0
        private var lastSlopeName: String = "-"
        private var liveFriendCount: Int = 0
        private var lastRideAtMs: Long? = null
        private var resortName: String = "-"

        fun isServiceRunning(): Boolean = isRunning
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                startTimeMs = intent.getLongExtra("liveOnStartAtMs", System.currentTimeMillis())
                todayRideCount = intent.getIntExtra("todayRideCount", 0)
                sessionRideCount = intent.getIntExtra("sessionRideCount", 0)
                lastSlopeName = intent.getStringExtra("lastSlopeName") ?: "-"
                liveFriendCount = intent.getIntExtra("liveFriendCount", 0)
                lastRideAtMs = if (intent.hasExtra("lastRideAtMs")) intent.getLongExtra("lastRideAtMs", 0) else null
                resortName = intent.getStringExtra("resortName") ?: "-"

                isRunning = true
                startForeground(NOTIFICATION_ID, buildNotification())
            }
            ACTION_UPDATE -> {
                if (intent.hasExtra("todayRideCount")) {
                    todayRideCount = intent.getIntExtra("todayRideCount", todayRideCount)
                }
                if (intent.hasExtra("sessionRideCount")) {
                    sessionRideCount = intent.getIntExtra("sessionRideCount", sessionRideCount)
                }
                if (intent.hasExtra("lastSlopeName")) {
                    lastSlopeName = intent.getStringExtra("lastSlopeName") ?: lastSlopeName
                }
                if (intent.hasExtra("liveFriendCount")) {
                    liveFriendCount = intent.getIntExtra("liveFriendCount", liveFriendCount)
                }
                if (intent.hasExtra("lastRideAtMs")) {
                    lastRideAtMs = intent.getLongExtra("lastRideAtMs", 0)
                }
                if (intent.hasExtra("resortName")) {
                    resortName = intent.getStringExtra("resortName") ?: resortName
                }

                updateNotification()
            }
            ACTION_STOP -> {
                isRunning = false
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "라이브 활동",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "라이브온 상태를 표시합니다"
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // 축소 레이아웃 (3개 컬럼만 표시)
        val collapsedView = RemoteViews(packageName, R.layout.notification_live_activity_collapsed)
        collapsedView.setTextViewText(R.id.today_ride_count, todayRideCount.toString())
        collapsedView.setTextViewText(R.id.session_ride_count, sessionRideCount.toString())
        collapsedView.setTextViewText(R.id.last_slope, if (lastSlopeName.isEmpty() || lastSlopeName == "-") "-" else lastSlopeName)

        // 확장 레이아웃 (전체 정보 표시)
        val expandedView = RemoteViews(packageName, R.layout.notification_live_activity)
        expandedView.setTextViewText(R.id.resort_name, if (resortName.isEmpty()) "-" else resortName)
        expandedView.setTextViewText(R.id.friend_count, liveFriendCount.toString())
        expandedView.setTextViewText(R.id.today_ride_count, todayRideCount.toString())
        expandedView.setTextViewText(R.id.session_ride_count, sessionRideCount.toString())
        expandedView.setTextViewText(R.id.last_slope, if (lastSlopeName.isEmpty() || lastSlopeName == "-") "-" else lastSlopeName)

        // Chronometer 설정 (경과 시간 표시)
        val elapsedSinceStart = System.currentTimeMillis() - startTimeMs
        val chronometerBase = SystemClock.elapsedRealtime() - elapsedSinceStart
        expandedView.setChronometer(R.id.timer, chronometerBase, null, true)

        // 경과 시간 계산 (contentText용)
        val elapsedMs = System.currentTimeMillis() - startTimeMs
        val elapsedMinutes = (elapsedMs / 1000 / 60).toInt()
        val hours = elapsedMinutes / 60
        val minutes = elapsedMinutes % 60
        val elapsedText = if (hours > 0) "${hours}시간 ${minutes}분" else "${minutes}분"

        val contentText = "라이딩 $sessionRideCount 회 | $elapsedText 경과"

        // 볼드 처리된 subText
        val boldSubText = if (AndroidBuild.VERSION.SDK_INT >= AndroidBuild.VERSION_CODES.N) {
            Html.fromHtml("<b>스노우라이브</b>", Html.FROM_HTML_MODE_LEGACY)
        } else {
            @Suppress("DEPRECATION")
            Html.fromHtml("<b>스노우라이브</b>")
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentTitle("스노우라이브")
            .setContentText(contentText)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(collapsedView)
            .setCustomBigContentView(expandedView)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setShowWhen(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    private fun updateNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, buildNotification())
    }

    override fun onDestroy() {
        isRunning = false
        super.onDestroy()
    }
}