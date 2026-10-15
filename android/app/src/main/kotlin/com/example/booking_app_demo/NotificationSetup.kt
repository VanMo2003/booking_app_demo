package com.example.booking_app_demo

import android.app.AppOpsManager
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Những gì quyết định app còn nhận thông báo đẩy sau khi bị vuốt tắt: quyền thông báo, tối ưu pin, và trên
 * máy Xiaomi/Redmi/POCO, Oppo/Realme, Vivo, Huawei/Honor… quyền "Tự khởi chạy" — thiếu nó, hệ điều hành
 * chặn Google Play Services đánh thức app nên thông báo FCM bị bỏ. Kênh `booking_app/notification_setup`.
 */
class NotificationSetup(private val activity: MainActivity) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> result.success(status())
            "openNotificationSettings" -> result.success(openNotificationSettings())
            "openAutoStart" -> result.success(openAutoStart())
            "requestUnrestrictedBattery" -> result.success(requestUnrestrictedBattery())
            else -> result.notImplemented()
        }
    }

    private val packageName: String get() = activity.packageName

    private val manufacturer: String get() = Build.MANUFACTURER.lowercase()

    private fun status(): Map<String, Any> = mapOf(
        "manufacturer" to Build.MANUFACTURER,
        "notificationsEnabled" to notificationsEnabled(),
        "batteryUnrestricted" to batteryUnrestricted(),
        // allowed | denied | unknown (hãng có mục này nhưng không đọc được) | notNeeded
        "autoStart" to autoStartState(),
    )

    private fun notificationsEnabled(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.N ||
            activity.getSystemService(NotificationManager::class.java).areNotificationsEnabled()

    private fun batteryUnrestricted(): Boolean =
        activity.getSystemService(PowerManager::class.java).isIgnoringBatteryOptimizations(packageName)

    private fun autoStartState(): String {
        if (AUTO_START_BRANDS.none { manufacturer.contains(it) }) return "notNeeded"
        if (manufacturer != "xiaomi") return "unknown"
        // MIUI lưu "Tự khởi chạy" ở app-op riêng 10008 (không có API công khai, đọc qua reflection).
        return try {
            val appOps = activity.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val check = AppOpsManager::class.java.getMethod(
                "checkOpNoThrow",
                Int::class.javaPrimitiveType,
                Int::class.javaPrimitiveType,
                String::class.java,
            )
            val mode = check.invoke(appOps, MIUI_OP_AUTO_START, activity.applicationInfo.uid, packageName) as Int
            if (mode == AppOpsManager.MODE_ALLOWED) "allowed" else "denied"
        } catch (e: Exception) {
            "unknown"
        }
    }

    private fun openNotificationSettings(): Boolean {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        } else {
            appDetails()
        }
        return start(intent) || start(appDetails())
    }

    /** Trang "Tự khởi chạy" của từng hãng; không mở được thì về trang thông tin app (MIUI cũng có mục ở đó). */
    private fun openAutoStart(): Boolean =
        AUTO_START_SCREENS.any { start(Intent().setComponent(it)) } || start(appDetails())

    private fun requestUnrestrictedBattery(): Boolean {
        if (batteryUnrestricted()) return true
        val ask = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:$packageName"))
        return start(ask) || start(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)) || start(appDetails())
    }

    private fun appDetails() =
        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))

    private fun start(intent: Intent): Boolean = try {
        activity.startActivity(intent)
        true
    } catch (e: Exception) {
        // Không có màn này trên máy (hãng khác, phiên bản khác) hoặc bị chặn quyền mở.
        false
    }

    companion object {
        const val CHANNEL = "booking_app/notification_setup"
        private const val MIUI_OP_AUTO_START = 10008

        private val AUTO_START_BRANDS =
            listOf("xiaomi", "oppo", "realme", "oneplus", "vivo", "iqoo", "huawei", "honor", "letv", "asus", "meizu")

        private val AUTO_START_SCREENS = listOf(
            ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
            ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
            ComponentName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity"),
            ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"),
            ComponentName("com.oneplus.security", "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"),
            ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
            ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager"),
            ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"),
            ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
            ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"),
            ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.AutobootManageActivity"),
            ComponentName("com.asus.mobilemanager", "com.asus.mobilemanager.entry.FunctionActivity"),
        )
    }
}
