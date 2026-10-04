plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Thông báo đẩy: tải google-services.json từ Firebase console đặt vào thư mục này.
// Chưa có file thì app vẫn build và chạy, thông báo chỉ hiện trong app.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

android {
    namespace = "com.example.booking_app_demo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.booking_app_demo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Điện thoại thật gọi BE chạy trên laptop: mỗi lần build Android, lấy dòng "IPv4 Address" của card
// Wi-Fi trong `ipconfig` (máy build) ghi vào lib/core/config/dev_host.dart để AppConfig ghép URL.
// Chạy trước bước biên dịch Dart, nên bấm Run trong IDE hay `flutter run` đều lấy IP mới nhất.
val writeDevHost by tasks.registering {
    val target = rootProject.projectDir.parentFile.resolve("lib/core/config/dev_host.dart")
    outputs.upToDateWhen { false }
    doLast {
        val ip = wifiIpv4FromIpconfig()
        val content = """
            |// Sinh tự động khi build Android (android/app/build.gradle.kts, task writeDevHost) từ dòng
            |// "IPv4 Address" của card Wi-Fi trong `ipconfig` trên máy build. Không sửa tay.
            |// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
            |const String? devHost = ${if (ip == null) "null" else "'$ip'"};
            |""".trimMargin()
        // Chỉ ghi khi IP đổi, để Dart không phải biên dịch lại vô ích.
        if (!target.exists() || target.readText() != content) target.writeText(content)
        logger.lifecycle("BE cho điện thoại thật: ${ip ?: "không thấy dòng IPv4 Address trong ipconfig"}")
    }
}
tasks.named("preBuild") { dependsOn(writeDevHost) }
tasks.matching { it.name.startsWith("compileFlutterBuild") }.configureEach { dependsOn(writeDevHost) }

/**
 * Dòng `IPv4 Address. . . : 192.168.35.4` của `ipconfig`: ưu tiên mục "Wireless LAN adapter Wi-Fi",
 * bỏ card ảo (VMware, VirtualBox, WSL, VPN, Bluetooth) và địa chỉ tự cấp 169.254.x.x.
 * Không phải Windows hoặc không có mạng thì trả null.
 */
fun wifiIpv4FromIpconfig(): String? {
    if (!System.getProperty("os.name").lowercase().contains("windows")) return null
    val output = try {
        ProcessBuilder("ipconfig").redirectErrorStream(true).start().inputStream.bufferedReader().readText()
    } catch (e: Exception) {
        return null
    }
    val virtualCard = Regex("(?i)vmware|virtualbox|vethernet|wsl|hyper-v|loopback|bluetooth|vpn")
    val ipv4 = Regex("""\d{1,3}(\.\d{1,3}){3}""")
    var adapter = ""
    val found = mutableListOf<Pair<String, String>>() // (tên card, IPv4)
    for (line in output.lines()) {
        if (line.isNotBlank() && !line.first().isWhitespace()) adapter = line.trim().removeSuffix(":")
        if (line.contains("IPv4")) ipv4.find(line)?.let { found += adapter to it.value }
    }
    val usable = found.filter { (card, ip) ->
        !virtualCard.containsMatchIn(card) && !ip.startsWith("169.254.") && !ip.startsWith("127.")
    }
    return (usable.firstOrNull { it.first.contains("Wi-Fi", ignoreCase = true) } ?: usable.firstOrNull())?.second
}
