import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/constant.dart';
import '../../core/di/injector.dart';
import '../../core/navigation/app_routes.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Giữ màn hình chào trong 1.5 giây để tăng nhận diện thương hiệu
    Future.delayed(const Duration(milliseconds: 2000), () {
      _redirect();
    });
  }

  Future<void> _redirect() async {
    if (!mounted) return;

    final storage = getIt<FlutterSecureStorage>();
    final token = await storage.read(key: Constants.accessToken);
    final role = await storage.read(key: Constants.role);

    if (token == null || token.isEmpty) {
      context.router.replace(const LoginRoute());
      return;
    }

    switch (role) {
      case 'CUSTOMER':
        context.router.replace(const CustomerRoute());
        break;
      case 'HOTEL':
      case 'HOTEL_MANAGER':
        context.router.replace(const HotelManageListRoute());
        break;
      case 'STAFF':
        context.router.replace(const EmployeeRoute());
        break;
      default:
        context.router.replace(const LoginRoute());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hotel_class_rounded,
                size: 70,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'BOOKING APP',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: Colors.black87,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.primaryColor.withValues(alpha: 0.3),
                ),
                minHeight: 3, // Thanh rất mảnh để tinh tế
              ),
            ),
          ],
        ),
      ),
    );
  }
}
