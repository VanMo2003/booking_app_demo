// Sinh tự động khi build Android (android/app/build.gradle.kts, task writeDevHost) từ dòng
// "IPv4 Address" của card Wi-Fi trong `ipconfig` trên máy build. Không sửa tay.
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
const String? devHost = '192.168.35.4';
