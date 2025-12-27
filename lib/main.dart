import 'package:booking_app_mobile/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';

import 'core/config_setup.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  await configSetup();
  runApp(BookingHotelManagerApp());
}

class BookingHotelManagerApp extends StatelessWidget {
  const BookingHotelManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRoutes(includeAuthRoutes: true);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Manager',
      theme: AppTheme.light,
      routerConfig: router.config(),
    );
  }
}
