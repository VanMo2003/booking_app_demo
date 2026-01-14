import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/api/app_config.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:booking_app_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:booking_app_mobile/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../hotel/presentation/cubit/hotel_detail/hotel_detail_cubit.dart';
import '../../../hotel/presentation/cubit/hotel_detail/hotel_detail_state.dart';

@RoutePage()
class HotelManageScreen extends StatelessWidget {
  const HotelManageScreen({super.key});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đăng xuất'),
        content: const Text(
            'Bạn có chắc chắn muốn thoát khỏi hệ thống quản trị không?'),
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
                Navigator.pop(context);
                context.router.replaceAll([const LoginRoute()]);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Đăng xuất thất bại: ${e.toString()}')),
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
    final primaryColor = Theme.of(context).primaryColor;

    return BlocProvider(
      create: (context) => HotelDetailCubit(getIt<HotelRepository>())..fetch(1),
      child: BlocBuilder<HotelDetailCubit, HotelDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              title: const Text(
                'Khách sạn Mường Thanh',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () => _handleLogout(context),
                  tooltip: 'Đăng xuất',
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PH???N DOANH THU (OVERVIEW) ---
                  _buildRevenueCard(primaryColor),

                  const SizedBox(height: 24),

                  const Text(
                    "Đơn hôm nay",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatItem(context, 'Đặt phòng', '12',
                          Icons.book_online, Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatItem(context, 'Phòng trống', '08', Icons.bed,
                          Colors.green),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Thông tin khách sạn",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildHotelInfoCard(context, state),

                  const SizedBox(height: 28),

                  // --- DANH M??§C QU???N LA? ---
                  const Text(
                    "Đơn hôm nay",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildTile(context, Icons.work, 'Chức vụ',
                          () => context.router.push(const PositionRoute())),
                      _buildTile(
                          context,
                          Icons.people,
                          'Nhân viên',
                          () =>
                              context.router.push(StaffAdminRoute(hotelId: 1))),
                      _buildTile(context, Icons.category, 'Loại phòng',
                          () => context.router.push(const RoomTypeRoute())),
                      // TODO : l???y hotelId qua api
                      _buildTile(context, Icons.meeting_room, 'Phòng',
                          () => context.router.push(RoomRoute(hotelId: 1))),
                      _buildTile(context, Icons.room_service, 'Dịch vụ',
                          () => context.router.push(const ServiceRoute())),
                      _buildTile(context, Icons.assignment, 'Đơn đặt phòng',
                          () => context.router.push(const BookingRoute())),
                      _buildTile(context, Icons.pool, 'Tiện ích',
                          () => context.router.push(AmenityRoute(hotelId: 1))),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Card doanh thu với Gradient
  Widget _buildRevenueCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Doanh thu tháng này',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Icon(Icons.trending_up,
                  color: Colors.white.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(25450000),
            style: const TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '↑ 12.5% so với tháng trước',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(label,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHotelInfoCard(BuildContext context, HotelDetailState state) {
    final hotel = state.hotel;
    final imageUrls = _getHotelImageUrls(hotel);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.status == HotelDetailStatus.loading)
              const LinearProgressIndicator(minHeight: 2),
            Text(
              hotel?.name ?? "Tên khách sạn",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(hotel?.address ?? "-",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(hotel?.phone ?? "-",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            if (imageUrls.isNotEmpty) ...[
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final url = imageUrls[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        width: 160,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: (state.isUploadingImages || hotel?.id == null)
                    ? null
                    : () => _pickAndUploadImages(context, hotel!.id),
                icon: const Icon(Icons.photo_library_outlined),
                label:
                    Text(state.isUploadingImages ? "Đang tải..." : "Thêm ảnh"),
              ),
            ),
            if (state.isUploadingImages)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(),
              ),
            if (state.uploadErrorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.uploadErrorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _getHotelImageUrls(Hotel? hotel) {
    const fallbackUrl =
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop';
    if (hotel == null) return [fallbackUrl];
    final rawImages = hotel.images.isNotEmpty
        ? hotel.images
        : (hotel.pathImage.isNotEmpty ? [hotel.pathImage] : <String>[]);
    if (rawImages.isEmpty) return [fallbackUrl];
    final urls = rawImages
        .map(_resolveHotelImageUrl)
        .where((url) => url.isNotEmpty)
        .toList();
    return urls.isEmpty ? [fallbackUrl] : urls;
  }

  String _resolveHotelImageUrl(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return "${AppConfig().baseURL}$path";
  }

  Future<void> _pickAndUploadImages(BuildContext context, int hotelId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final paths =
        result.files.map((file) => file.path).whereType<String>().toList();
    if (paths.isEmpty) return;

    final cubit = context.read<HotelDetailCubit>();
    final success =
        await cubit.uploadImages(hotelId: hotelId, filePaths: paths);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Thêm ảnh thành công"),
      ));
    }
  }

  Widget _buildTile(BuildContext context, IconData icon, String label,
      void Function() onTap) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(icon, size: 26, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
