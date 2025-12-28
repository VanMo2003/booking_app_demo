import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:flutter/material.dart';

Future<void> configSetup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencyInjection();
}

Future<void> initDependencyInjection() async {
  await configureDependencies();
}
