import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/navigation/app_routes.dart';
import 'package:booking_app_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:booking_app_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:booking_app_mobile/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HotelManageListScreen extends StatefulWidget {
  const HotelManageListScreen({super.key});

  @override
  State<HotelManageListScreen> createState() => _HotelManageListScreenState();
}

class _HotelManageListScreenState extends State<HotelManageListScreen> {
  final HotelRepository _hotelRepository = getIt<HotelRepository>();
  bool _isLoading = true;
  bool _isCreating = false;
  String? _errorMessage;
  List<Hotel> _hotels = [];

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _hotelRepository.getAllHotels(page: 0, size: 100);
      if (!mounted) return;
      setState(() => _hotels = result.content);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                await getIt<AuthRepository>().logout();
                if (!mounted) return;
                Navigator.pop(context);
                context.router.replaceAll([const LoginRoute()]);
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đăng xuất thất bại: $e')),
                );
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateHotelDialog() async {
    final nameCtl = TextEditingController();
    final addressCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    final descriptionCtl = TextEditingController();
    final categoryCtl = TextEditingController();
    final pathImageCtl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: !_isCreating,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> createHotel() async {
              if (!formKey.currentState!.validate()) return;
              setDialogState(() => _isCreating = true);
              try {
                final created = await _hotelRepository.createHotel(
                  name: nameCtl.text.trim(),
                  address: addressCtl.text.trim(),
                  phone: phoneCtl.text.trim(),
                  description: descriptionCtl.text.trim(),
                  category: categoryCtl.text.trim(),
                  pathImage: pathImageCtl.text.trim(),
                );
                if (!mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã tạo cơ sở: ${created.name}')),
                );
                await _loadHotels();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tạo cơ sở thất bại: $e')),
                );
              } finally {
                if (mounted) {
                  setDialogState(() => _isCreating = false);
                }
              }
            }

            InputDecoration _inputDecoration(String label) {
              return InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Thêm cơ sở mới',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameCtl,
                        decoration: _inputDecoration('Tên cơ sở'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Nhập tên' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: addressCtl,
                        decoration: _inputDecoration('Địa chỉ'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nhập địa chỉ'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneCtl,
                        decoration: _inputDecoration('Số điện thoại'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nhập số điện thoại'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionCtl,
                        decoration: _inputDecoration('Mô tả'),
                        minLines: 2,
                        maxLines: 3,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nhập mô tả'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: categoryCtl,
                        decoration: _inputDecoration('Category'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nhập category'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: pathImageCtl,
                        decoration:
                            _inputDecoration('Đường dẫn ảnh (Tùy chọn)'),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actions: [
                TextButton(
                  onPressed:
                      _isCreating ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Hủy',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: _isCreating ? null : createHotel,
                  child: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Tạo mới', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Đồng bộ background với màn detail
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Danh sách cơ sở',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadHotels,
            icon: const Icon(Icons.refresh, color: Colors.black87),
            tooltip: 'Làm mới',
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Đăng xuất',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateHotelDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_business, color: Colors.white),
        label: const Text(
          'Thêm cơ sở mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : _hotels.isEmpty
                  ? const Center(
                      child: Text('Chưa có cơ sở khách sạn nào',
                          style: TextStyle(color: Colors.grey, fontSize: 16)))
                  : RefreshIndicator(
                      onRefresh: _loadHotels,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                            top: 16, bottom: 84, left: 16, right: 16),
                        itemCount: _hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = _hotels[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => context.router.push(
                                  HotelManageRoute(hotelId: hotel.id),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(
                                              alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.domain,
                                            color: primaryColor, size: 28),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hotel.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on,
                                                    size: 14,
                                                    color: Colors.grey[500]),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    hotel.address,
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 13),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.phone,
                                                    size: 14,
                                                    color: Colors.grey[500]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${hotel.phone} • ${hotel.category}',
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color: Colors.grey[400]),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
