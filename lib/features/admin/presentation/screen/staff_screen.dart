import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class StaffScreen extends StatelessWidget {
  const StaffScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý nhân viên')),
      body: const Center(
          child: Text('Chức năng quản lý nhân viên (chưa triển khai)')),
    );
  }
}
