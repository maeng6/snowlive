package com.snowlive

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
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
    private val APP_ICON_CHANNEL = "app_icon"

    // 서버 변형 키 → activity-alias 컴포넌트명. (매니페스트의 android:name과 일치)
    private val iconAliases = mapOf(
        "default" to ".DefaultAlias",
        "xmas"    to ".XmasAlias",
        "newyear" to ".NewyearAlias"
    )

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
                            val snowballCount = call.argument<Int>("snowballCount") ?: -1
                            val lastRideAtMs = call.argument<Long>("lastRideAtMs")
                            val resortName = call.argument<String>("resortName") ?: "-"

                            val intent = Intent(this, LiveActivityService::class.java).apply {
                                action = LiveActivityService.ACTION_START
                                putExtra("liveOnStartAtMs", liveOnStartAtMs)
                                putExtra("todayRideCount", todayRideCount)
                                putExtra("sessionRideCount", sessionRideCount)
                                putExtra("lastSlopeName", lastSlopeName)
                                putExtra("liveFriendCount", liveFriendCount)
                                putExtra("snowballCount", snowballCount)
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
                            val snowballCount = call.argument<Int>("snowballCount")
                            val lastRideAtMs = call.argument<Long>("lastRideAtMs")

                            val intent = Intent(this, LiveActivityService::class.java).apply {
                                action = LiveActivityService.ACTION_UPDATE
                                todayRideCount?.let { putExtra("todayRideCount", it) }
                                sessionRideCount?.let { putExtra("sessionRideCount", it) }
                                lastSlopeName?.let { putExtra("lastSlopeName", it) }
                                liveFriendCount?.let { putExtra("liveFriendCount", it) }
                                snowballCount?.let { putExtra("snowballCount", it) }
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

        // MethodChannel 설정 - App Icon (대체 런처 아이콘 전환: activity-alias enable/disable)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_ICON_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setIcon" -> {
                        try {
                            val variant = call.argument<String>("variant") ?: "default"
                            applyIconAlias(variant)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SET_ICON_ERROR", e.message, null)
                        }
                    }
                    "currentIcon" -> {
                        try {
                            result.success(currentEnabledVariant())
                        } catch (e: Exception) {
                            result.error("CURRENT_ICON_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /// 선택 변형의 alias만 enable, 나머지는 disable (항상 정확히 1개만 켜진다).
    /// DONT_KILL_APP으로 앱을 죽이지 않고 런처 아이콘만 교체한다.
    private fun applyIconAlias(variant: String) {
        val target = if (iconAliases.containsKey(variant)) variant else "default"
        val pm = packageManager
        // 1) 먼저 목표 alias를 켠다 (전환 순간 런처에 아이콘이 비는 것을 최소화).
        iconAliases[target]?.let { alias ->
            pm.setComponentEnabledSetting(
                ComponentName(packageName, packageName + alias),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        }
        // 2) 나머지 alias는 끈다.
        for ((key, alias) in iconAliases) {
            if (key == target) continue
            pm.setComponentEnabledSetting(
                ComponentName(packageName, packageName + alias),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }
    }

    /// 현재 enabled 상태인 alias의 변형 키를 반환(판별 불가 시 'default').
    private fun currentEnabledVariant(): String {
        val pm = packageManager
        for ((key, alias) in iconAliases) {
            val state = pm.getComponentEnabledSetting(ComponentName(packageName, packageName + alias))
            if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) return key
            // DefaultAlias는 매니페스트 기본 enabled=true라 DEFAULT 상태도 '켜짐'으로 본다.
            if (key == "default" && state == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT) return "default"
        }
        return "default"
    }
}
