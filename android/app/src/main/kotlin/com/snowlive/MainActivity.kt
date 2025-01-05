package com.snowlive

import android.os.PowerManager
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
                if (call.method == "isBatterySaverOn") {
                    val powerManager = getSystemService(POWER_SERVICE) as PowerManager
                    val isBatterySaverOn = powerManager.isPowerSaveMode // 배터리 절약 모드 상태 확인
                    result.success(isBatterySaverOn)
                } else {
                    result.notImplemented()
                }
            }
    }
}
