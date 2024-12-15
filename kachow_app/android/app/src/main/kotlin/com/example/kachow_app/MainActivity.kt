package com.example.kachow_app

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.FlutterEngineCache


class MainActivity: FlutterActivity(){
    private val CHANNEL = "foregroundOBD_service"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Cache do FlutterEngine para ser usado pelo serviço
        FlutterEngineCache.getInstance().put("shared_engine", flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    startService(Intent(this, ForegroundService::class.java))
                    result.success("Started!")
                }
                "stopForegroundService" -> {
                    stopService(Intent(this, ForegroundService::class.java))
                    result.success("Stopped!")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
