package com.example.booking_app_demo

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NotificationSetup.CHANNEL)
            .setMethodCallHandler(NotificationSetup(this))
    }

    /**
     * Kênh thông báo mức ưu tiên cao: thông báo đẩy (tin nhắn, đơn tour, xét duyệt hồ sơ…) bật lên đầu màn
     * hình kèm âm thanh khi app chạy nền hoặc đã tắt, thay vì nằm im trong kênh mặc định "Miscellaneous".
     * BE gửi FCM vào đúng kênh này (FcmPushNotificationSender.ANDROID_CHANNEL_ID). Tạo lại nhiều lần không sao.
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(CHANNEL_ID, "Tin nhắn và đơn đặt", NotificationManager.IMPORTANCE_HIGH)
            .apply {
                description = "Tin nhắn với khách sạn, đơn tour, kết quả xét duyệt"
                enableVibration(true)
            }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    companion object {
        const val CHANNEL_ID = "booking_app_alerts"
    }
}
