import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/api/app_config.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:booking_app_mobile/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../hotel/presentation/cubit/hotel_detail/hotel_detail_cubit.dart';
import '../../../hotel/presentation/cubit/hotel_detail/hotel_detail_state.dart';

@RoutePage()
class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  late final HotelDetailCubit _cubit;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _cubit = HotelDetailCubit(getIt<HotelRepository>());
    _cubit.fetch(widget.hotel.id);
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
      child: BlocBuilder<HotelDetailCubit, HotelDetailState>(
        builder: (context, state) {
          final hotel = state.hotel ?? widget.hotel;
          final imageUrl = (hotel.pathImage.isNotEmpty)
              ? "${AppConfig().baseURL}${hotel.pathImage}"
              : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop';

          return Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.router.back(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.status == HotelDetailStatus.loading)
                          const LinearProgressIndicator(minHeight: 2),

                        Text(
                          hotel.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: primaryBlue),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(hotel.address,
                                  style: const TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),

                        const Divider(height: 40),

                        // --- MÔ TẢ ---
                        const Text("Mô tả khách sạn",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                            hotel.description.isNotEmpty
                                ? hotel.description
                                : "Đang cập nhật...",
                            style: const TextStyle(
                                color: Colors.black87, height: 1.5)),

                        const SizedBox(height: 24),

                        // --- TIỆN ÍCH (Lấy từ list amenities trong JSON) ---
                        if (hotel.amenities.isNotEmpty) ...[
                          const Text("Tiện ích",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _buildAmenitiesList(hotel.amenities, primaryBlue),
                          const SizedBox(height: 24),
                        ],

                        const Text("Chọn phòng",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (hotel.rooms.isEmpty)
                          const Text("Hiện tại khách sạn chưa cập nhật phòng.")
                        else
                          ...hotel.rooms
                              .map((room) => _buildRoomCard(room, primaryBlue)),

                        const SizedBox(height: 24),

                        // --- DỊCH VỤ (Lấy từ list services trong JSON) ---
                        if (hotel.services.isNotEmpty) ...[
                          const Text("Dịch vụ đi kèm",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...hotel.services.map((s) => _buildServiceItem(
                              s.name, s.unitPrice, Icons.star_outline)),
                        ],

                        const SizedBox(height: 100),
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

  // Widget hiển thị Tiện ích dạng Chip/Wrap
  Widget _buildAmenitiesList(List<dynamic> amenities, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities
          .map((a) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(a.name,
                        style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // Widget Card cho từng Phòng
  Widget _buildRoomCard(dynamic room, Color primaryBlue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Phòng ${room.roomNumber} - ${room.roomTypeName}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: room.status == "AVAILABLE"
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  room.status == "AVAILABLE" ? "Sẵn sàng" : "Hết phòng",
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
          Text(room.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people_outline, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 4),
              Text("Sức chứa: ${room.capacity} người",
                  style: const TextStyle(fontSize: 13)),
              const Spacer(),
              Text(
                currencyFormat.format(room.price),
                style: TextStyle(
                    color: primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const Text(" /đêm",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: room.status == "AVAILABLE" ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text("Chọn phòng này"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildServiceItem(String title, dynamic price, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(currencyFormat.format(price),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.orange)),
        ],
      ),
    );
  }
}
