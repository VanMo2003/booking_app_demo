import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/auth/domain/entity/auth.dart';
import 'package:booking_app_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

import '../../../../core/navigation/app_routes.dart';
import 'account_settings_screen.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xac nhan'),
        content: const Text('Ban co muon dang xuat khoi ung dung?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Huy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              try {
                await getIt<AuthRepository>().logout();
                if (!context.mounted) return;
                Navigator.pop(context);
                context.router.replaceAll([const LoginRoute()]);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Loi: ${e.toString()}')),
                );
              }
            },
            child: const Text('Dang xuat'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAccountSettings() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
    );

    if (changed == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandGold = Color(0xFF8B7355);
    final customer = Auth.current?.customer;
    final fullName = customer?.fullName?.trim();
    final username = customer?.username?.trim();
    final subtitle = customer?.phoneNumber?.trim();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AutoLeadingButton(color: Colors.black87),
        title: const Text('Cai dat tai khoan',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?img=68'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (fullName != null && fullName.isNotEmpty)
                              ? fullName
                              : ((username != null && username.isNotEmpty)
                                  ? username
                                  : 'Ten nguoi dung'),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          (subtitle != null && subtitle.isNotEmpty)
                              ? subtitle
                              : 'So dien thoai',
                          style:
                              const TextStyle(color: brandGold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_note_rounded, color: brandGold),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildMenuItem(
                      Icons.help_outline_rounded, 'Huong dan dung app'),
                  _buildDivider(),
                  _buildMenuItem(Icons.hotel_outlined, 'Thong tin khach san'),
                  _buildDivider(),
                  _buildMenuItem(
                      Icons.loyalty_outlined, 'Goi uu dai dang dung'),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.manage_accounts_outlined,
                    'Thiet lap tai khoan',
                    onTap: _openAccountSettings,
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                      Icons.color_lens_outlined, 'Thay doi giao dien'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                onTap: () => _handleLogout(context),
                leading: const Icon(Icons.power_settings_new_rounded,
                    color: Colors.redAccent),
                title: const Text('Dang xuat',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B7355)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 56, color: Colors.grey[100]);
  }
}
