class AppConfig {
  bool isProduction = true;
  String baseURL = 'http://192.168.35.7:8080/booking-app/api/v1';
  // String baseURL = 'http://10.0.2.2:8080/booking-app/api/v1';
  int connectTimeout = 60000;
  int receiveTimeout = 60000;
  int sendTimeout = 60000;
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
}
