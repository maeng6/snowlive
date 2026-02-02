package com.snowlive

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "detect_battery_saver"
    private val LIVE_ACTIVITY_CHANNEL = "live_activity"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MethodChannel 설정 - Battery Saver
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isBatterySaverOn" -> {
                        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
                        val isBatterySaverOn = powerManager.isPowerSaveMode
                        result.success(isBatterySaverOn)
                    }
                    "isIgnoringBatteryOptimizations" -> {
                        // 배터리 최적화 제외 상태 확인
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                            val isIgnoring = powerManager.isIgnoringBatteryOptimizations(packageName)
                            result.success(isIgnoring)
                        } else {
                            result.success(true) // API 23 미만은 제한 없음
                        }
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        // 배터리 최적화 제외 요청 (사용자에게 다이얼로그 표시)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            try {
                                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                                intent.data = Uri.parse("package:$packageName")
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        } else {
                            result.success(true)
                        }
                    }
                    "openBatteryOptimizationSettings" -> {
                        // 배터리 최적화 설정 화면으로 이동 (직접 요청이 거부된 경우)
                        try {
                            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "isMockLocationEnabled" -> {
                        // 1. 개발자 옵션이 활성화되어 있는지 확인
                        val developerOptionsEnabled = Settings.Global.getInt(
                            contentResolver,
                            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                            0
                        ) != 0

                        if (!developerOptionsEnabled) {
                            // 개발자 옵션이 꺼져 있으면 mock location 불가능
                            result.success(false)
                        } else {
                            // 2. 개발자 옵션이 켜져 있으면 mock location 앱 설정 확인
                            val mockLocationApp = Settings.Secure.getString(contentResolver, "mock_location")
                            result.success(!mockLocationApp.isNullOrEmpty())
                        }
                    }
                    "openDeveloperOptions" -> {
                        try {
                            val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            // 일부 기기에서 개발자 옵션 직접 이동이 안 될 경우 설정 메인으로
                            try {
                                val intent = Intent(Settings.ACTION_SETTINGS)
                                startActivity(intent)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.success(false)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // MethodChannel 설정 - Live Activity (라이브온 알림 표시)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LIVE_ACTIVITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        try {
                            val liveOnStartAtMs = call.argument<Long>("liveOnStartAtMs") ?: System.currentTimeMillis()
                            val todayRideCount = call.argument<Int>("todayRideCount") ?: 0
                            val sessionRideCount = call.argument<Int>("sessionRideCount") ?: 0
                            val lastSlopeName = call.argument<String>("lastSlopeName") ?: "-"
                            val liveFriendCount = call.argument<Int>("liveFriendCount") ?: 0
                            val lastRideAtMs = call.argument<Long>("lastRideAtMs")
                            val resortName = call.argument<String>("resortName") ?: "-"

                            val intent = Intent(this, LiveActivityService::class.java).apply {
                                action = LiveActivityService.ACTION_START
                                putExtra("liveOnStartAtMs", liveOnStartAtMs)
                                putExtra("todayRideCount", todayRideCount)
                                putExtra("sessionRideCount", sessionRideCount)
                                putExtra("lastSlopeName", lastSlopeName)
                                putExtra("liveFriendCount", liveFriendCount)
                                putExtra("resortName", resortName)
                                lastRideAtMs?.let { putExtra("lastRideAtMs", it) }
                            }

                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(intent)
                            } else {
                                startService(intent)
                            }

                            // Android에서는 고정 ID 반환 (iOS처럼 activity ID 사용)
                            result.success("android_live_activity")
                        } catch (e: Exception) {
                            result.error("START_ERROR", e.message, null)
                        }
                    }
                    "update" -> {
                        try {
                            val todayRideCount = call.argument<Int>("todayRideCount")
                            val sessionRideCount = call.argument<Int>("sessionRideCount")
                            val lastSlopeName = call.argument<String>("lastSlopeName")
                            val liveFriendCount = call.argument<Int>("liveFriendCount")
                            val lastRideAtMs = call.argument<Long>("lastRideAtMs")

                            val intent = Intent(this, LiveActivityService::class.java).apply {
                                action = LiveActivityService.ACTION_UPDATE
                                todayRideCount?.let { putExtra("todayRideCount", it) }
                                sessionRideCount?.let { putExtra("sessionRideCount", it) }
                                lastSlopeName?.let { putExtra("lastSlopeName", it) }
                                liveFriendCount?.let { putExtra("liveFriendCount", it) }
                                lastRideAtMs?.let { putExtra("lastRideAtMs", it) }
                            }

                            startService(intent)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("UPDATE_ERROR", e.message, null)
                        }
                    }
                    "end" -> {
                        try {
                            val intent = Intent(this, LiveActivityService::class.java).apply {
                                action = LiveActivityService.ACTION_STOP
                            }
                            startService(intent)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("END_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
