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

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MethodChannel 설정
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
                    else -> result.notImplemented()
                }
            }
    }
}
