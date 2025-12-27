// core/widgets/app_scaffold.dart
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const AppScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: actions,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // 1. Background Gradient (Header)
          Container(
            height: 250, // Chiều cao của phần header
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF0B84FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 2. Main Content (White Sheet)
          SafeArea(
            bottom: false,
            child: Container(
              margin:
                  const EdgeInsets.only(top: 60), // Để hở header ra một chút
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA), // Màu nền xám nhẹ dịu mắt
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
