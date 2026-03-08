class AppConfig {
  String baseURL = 'http://172.20.10.10:8080/booking-app/api/v1';
  // String baseURL = 'http://172.20.10.10:8080/booking-app/api/v1';
  // String baseURL = 'http://10.0.2.2:8080/booking-app/api/v1';
  // String baseURL = 'https://vanmo.onrender.com/booking-app/api/v1';
  int connectTimeout = 30000;
  int receiveTimeout = 30000;
  int sendTimeout = 30000;
  String contentType = 'application/json';

  Map<String, String> standardHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static final AppConfig _instance = AppConfig._privateConstructor();

  AppConfig._privateConstructor();

  factory AppConfig() {
    return _instance;
  }

  // Future<void> init() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final cached = prefs.getString("baseURL");
  //   if (cached != null) {
  //     baseURL = cached;
  //     return;
  //   }
  //
  //   // 2) Nếu không có thì tự tìm server LAN
  //   final found = await findServer();
  //   baseURL = found ?? "http://10.0.2.2:8080/booking-app/api/v1";
  //
  //   await prefs.setString("baseURL", baseURL);
  // }
  //
  // Future<String?> findServer() async {
  //   final info = NetworkInfo();
  //   final ip = await info.getWifiIP(); // e.g. 192.168.35.15
  //   if (ip == null) return null;
  //
  //   final prefix = ip.substring(0, ip.lastIndexOf('.') + 1); // 192.168.35.
  //
  //   for (int i = 1; i < 255; i++) {
  //     final candidate = "$prefix$i";
  //     final url = "http://$candidate:8080/booking-app/api/v1/health";
  //
  //     try {
  //       final res = await Dio().get(url, options: Options(
  //         sendTimeout: Duration(milliseconds: 500),
  //         receiveTimeout: Duration(milliseconds: 500),
  //       ));
  //       if (res.statusCode == 200) return "http://$candidate:8080/booking-app/api/v1";
  //     } catch (_) {}
  //   }
  //   return null;
  // }
}
