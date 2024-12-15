package com.example.kachow_app

import android.app.Service
import android.content.Intent
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.os.IBinder
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import java.util.Timer
import java.util.TimerTask
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngineCache

class ForegroundService : Service() {
    private val notificationId = 1
    private var serviceRunning = false
    private lateinit var builder: NotificationCompat.Builder
    private lateinit var channel: NotificationChannel
    private lateinit var manager: NotificationManager

    private val handler: Handler by lazy { Handler(Looper.getMainLooper()) } // Lazy initialization
    private lateinit var obdTask: Runnable
    private lateinit var geoTask: Runnable
    private lateinit var tratarDadosTask: Runnable
    private lateinit var enviarDadosTask: Runnable

    private val channelName = "foregroundOBD_service"
    private lateinit var methodChannel: MethodChannel

    override fun onCreate() {
        super.onCreate()
        startForegroundService()
        serviceRunning = true
        val flutterEngine = FlutterEngineCache.getInstance().get("shared_engine")
            ?: throw IllegalStateException("FlutterEngine not initialized")
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        iniciarServicos() // Inicializa os serviços corretamente
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceRunning = false
        pararServicos() // Para os serviços corretamente
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(channelId: String, channelName: String): String {
        channel = NotificationChannel(
            channelId,
            channelName, NotificationManager.IMPORTANCE_NONE
        )
        channel.lightColor = Color.BLUE
        channel.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
        return channelId
    }

    private fun startForegroundService() {
        val channelId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel("foregroundOBD_service", "Foreground Service")
        } else {
            ""
        }
        builder = NotificationCompat.Builder(this, channelId)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Foreground Service")
            .setContentText("Foreground Service is running")
            .setCategory(Notification.CATEGORY_SERVICE)
        startForeground(notificationId, builder.build())
    }

    private fun updateNotification(text: String) {
        builder.setContentText(text)
        manager.notify(notificationId, builder.build())
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun coletarDadosOBD() {
        try {
            methodChannel.invokeMethod("coletarDadosOBD", null)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun coletarDadosGeolocalizao() {
        try {
            methodChannel.invokeMethod("coletarDadosGeolocalizao", null)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun tratarDadosOBD() {
        try {
            methodChannel.invokeMethod("tratarDadosOBD", null)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun enviarDadosFIWARE() {
        try {
            methodChannel.invokeMethod("enviarDadosFIWARE", null)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun iniciarServicos() {
        obdTask = Runnable {
            coletarDadosOBD()
            handler.postDelayed(obdTask, 1000) // Reposta a tarefa após 1 segundo
        }
        handler.post(obdTask)

        geoTask = Runnable {
            coletarDadosGeolocalizao()
            handler.postDelayed(geoTask, 1000) // Reposta a tarefa após 1 segundo
        }
        handler.post(geoTask)
        

        tratarDadosTask = Runnable {
            tratarDadosOBD()
            handler.postDelayed(tratarDadosTask, 5000) // Reposta a tarefa após 5 segundos
        }
        handler.post(tratarDadosTask)

        enviarDadosTask = Runnable {
            enviarDadosFIWARE()
            handler.postDelayed(enviarDadosTask, 15000) // Reposta a tarefa após 15 segundos
        }
        handler.post(enviarDadosTask)
    }

    private fun pararServicos() {
        handler.removeCallbacks(obdTask)
        handler.removeCallbacks(geoTask)
        handler.removeCallbacks(tratarDadosTask)
        handler.removeCallbacks(enviarDadosTask)
    }
}