import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/navigation/app_routes.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận'),
        content: const Text('Bạn có muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              try {
                await getIt<AuthRepository>().logout();
                Navigator.pop(context);
                context.router.replaceAll([const LoginRoute()]);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${e.toString()}')),
                );
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandGold = Color(0xFF8B7355);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AutoLeadingButton(color: Colors.black87),
        title: const Text('Cài đặt tài khoản', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // USER INFO CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=68'),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nguyễn Văn A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Thành viên Mường Thanh Gold', style: TextStyle(color: brandGold, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_note_rounded, color: brandGold),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildMenuItem(Icons.help_outline_rounded, 'Hướng dẫn dùng app'),
                  _buildDivider(),
                  _buildMenuItem(Icons.hotel_outlined, 'Thông tin khách sạn'),
                  _buildDivider(),
                  _buildMenuItem(Icons.loyalty_outlined, 'Gói ưu đãi đang dùng'),
                  _buildDivider(),
                  _buildMenuItem(Icons.manage_accounts_outlined, 'Thiết lập tài khoản'),
                  _buildDivider(),
                  _buildMenuItem(Icons.color_lens_outlined, 'Thay đổi giao diện'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                onTap: () => _handleLogout(context),
                leading: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent),
                title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B7355)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 56, color: Colors.grey[100]);
  }
}
