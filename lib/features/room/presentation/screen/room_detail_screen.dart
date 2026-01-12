import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/api/app_config.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/room/domain/repositories/room_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/room_detail/room_detail_cubit.dart';
import '../cubit/room_detail/room_detail_state.dart';

@RoutePage()
class RoomDetailScreen extends StatefulWidget {
  final int roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late final RoomDetailCubit _cubit;
  // Đổi locale sang vi_VN và symbol ₫ cho đồng bộ với màn Hotel
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _cubit = RoomDetailCubit(getIt<RoomRepository>());
    _cubit.fetch(widget.roomId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.primaryColor;

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<RoomDetailCubit, RoomDetailState>(
        builder: (context, state) {
          final room = state.room;

          // Logic lấy ảnh đại diện
          final mainImagePath = room?.pathImage?.isNotEmpty == true
              ? room?.pathImage
              : (room?.images?.isNotEmpty == true ? room?.images?.first : null);
          final imageUrl = mainImagePath != null && mainImagePath.isNotEmpty
              ? "${AppConfig().baseURL}$mainImagePath"
              : 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?q=80&w=1000&auto=format&fit=crop';

          return Scaffold(
            backgroundColor: Colors.white,
            // Sử dụng CustomScrollView để có hiệu ứng SliverAppBar giống màn Hotel
            body: state.status == RoomDetailStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 250,
                        pinned: true,
                        leading: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.black26,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => context.router.back(),
                            ),
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background:
                              Image.network(imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                      if (state.status == RoomDetailStatus.failure)
                        SliverFillRemaining(
                          child: Center(
                            child: Text(
                              state.errorMessage ?? "Lỗi tải thông tin phòng.",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      if (room != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- TITLE & TRẠNG THÁI ---
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Phòng ${room.roomNumber ?? '-'}"
                                        "${room.roomTypeName != null ? " - ${room.roomTypeName}" : ""}",
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: room.status == "AVAILABLE"
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        room.status == "AVAILABLE"
                                            ? "Sẵn sàng"
                                            : "Hết phòng",
                                        style: TextStyle(
                                            color: room.status == "AVAILABLE"
                                                ? Colors.green
                                                : Colors.red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // --- GIÁ & SỨC CHỨA ---
                                Row(
                                  children: [
                                    Text(
                                      currencyFormat.format(room.price ?? 0),
                                      style: TextStyle(
                                          color: primaryBlue,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Text(" /đêm",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 14)),
                                    const Spacer(),
                                    Icon(Icons.people_outline,
                                        size: 20, color: Colors.grey[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Sức chứa: ${room.capacity ?? 0} người",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),

                                const Divider(height: 40),

                                // --- MÔ TẢ ---
                                const Text("Mô tả phòng",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(
                                  room.description?.isNotEmpty == true
                                      ? room.description!
                                      : "Chưa có mô tả chi tiết.",
                                  style: const TextStyle(
                                      color: Colors.black87, height: 1.5),
                                ),

                                const SizedBox(height: 24),

                                // --- TIỆN ÍCH RIÊNG CỦA PHÒNG (Yêu cầu của bạn) ---
                                // Giả sử model HotelRoom có field `amenities` (List)
                                // Nếu trong model tên khác, bạn hãy đổi lại nhé
                                if (room.amenities != null &&
                                    room.amenities!.isNotEmpty) ...[
                                  const Text("Tiện ích phòng",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  _buildAmenitiesList(
                                      room.amenities!, primaryBlue),
                                  const SizedBox(height: 24),
                                ],

                                // --- HÌNH ẢNH KHÁC ---
                                if (room.images?.isNotEmpty == true) ...[
                                  const Text(
                                    "Hình ảnh chi tiết",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 120,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: room.images!.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 12),
                                      itemBuilder: (context, index) {
                                        final path = room.images![index];
                                        final url = path.isNotEmpty
                                            ? "${AppConfig().baseURL}$path"
                                            : imageUrl;
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            url,
                                            width: 160,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // --- NÚT ĐẶT PHÒNG ---
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: room.status == "AVAILABLE"
                                        ? () {
                                            // TODO: Xử lý logic đặt phòng tại đây
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: const Text("Đặt phòng ngay",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // Helper widget để hiển thị amenities giống màn HotelDetail
  Widget _buildAmenitiesList(List<dynamic> amenities, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.map((a) {
        // Xử lý an toàn nếu a là String hoặc Object có thuộc tính name
        final name = (a is String) ? a : (a.name ?? "");
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 14, color: color),
              const SizedBox(width: 6),
              Text(name,
                  style: TextStyle(
                      fontSize: 13, color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
