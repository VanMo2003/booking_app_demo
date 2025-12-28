import 'package:booking_app_mobile/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';

import 'core/config_setup.dart';
import 'core/theme/app_theme.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  await configSetup();

  // check if access token exists to decide initial route
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');

  runApp(BookingHotelManagerApp(initialAuthenticated: (token != null && token.isNotEmpty)));
}

class BookingHotelManagerApp extends StatelessWidget {
  final bool initialAuthenticated;

  const BookingHotelManagerApp({super.key, this.initialAuthenticated = false});

  @override
  Widget build(BuildContext context) {
    final router = AppRoutes(includeAuthRoutes: initialAuthenticated);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Manager',
      theme: AppTheme.light,
      routerConfig: router.config(),
    );
  }
}
