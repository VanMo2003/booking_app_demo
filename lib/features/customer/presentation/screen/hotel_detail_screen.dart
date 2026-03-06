import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/api/app_config.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/navigation/app_routes.dart';
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
  final String? checkinDate;
  final String? checkoutDate;

  const HotelDetailScreen({
    super.key,
    required this.hotel,
    this.checkinDate,
    this.checkoutDate,
  });

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  int _currentImageIndex = 0;
  late final HotelDetailCubit _cubit;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
  final Set<int> _selectedServiceIds = <int>{};

  @override
  void initState() {
    super.initState();
    _cubit = HotelDetailCubit(getIt<HotelRepository>());
    _cubit.fetch(
      widget.hotel.id,
      checkinDate: widget.checkinDate,
      checkoutDate: widget.checkoutDate,
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  int _selectedServiceTotal(Hotel hotel) {
    return hotel.services
        .where((s) => _selectedServiceIds.contains(s.id))
        .fold<int>(0, (sum, s) => sum + s.unitPrice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.primaryColor;

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<HotelDetailCubit, HotelDetailState>(
        builder: (context, state) {
          if (state.status == HotelDetailStatus.loading ||
              state.status == HotelDetailStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == HotelDetailStatus.failure) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(
                  'Loi tai thong tin khach san:\n${state.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final hotel = state.hotel ?? widget.hotel;
          const fallbackImageUrl =
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop';
          final imageUrls = _getHotelImageUrls(hotel, fallbackImageUrl);
          final currentIndex = _currentImageIndex.clamp(0, imageUrls.length - 1);

          return Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          itemCount: imageUrls.length,
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            final url = imageUrls[index];
                            return Image.network(url, fit: BoxFit.cover);
                          },
                        ),
                        if (imageUrls.length > 1)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(imageUrls.length, (i) {
                                final isActive = i == currentIndex;
                                return Container(
                                  width: isActive ? 18 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white : Colors.white70,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
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
                            Icon(Icons.location_on, size: 16, color: primaryBlue),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hotel.address,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 40),

                        const Text(
                          'Mo ta khach san',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hotel.description.isNotEmpty
                              ? hotel.description
                              : 'Dang cap nhat...',
                          style: const TextStyle(color: Colors.black87, height: 1.5),
                        ),

                        const SizedBox(height: 24),

                        if (hotel.amenities.isNotEmpty) ...[
                          const Text(
                            'Tien ich',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildAmenitiesList(hotel.amenities, primaryBlue),
                          const SizedBox(height: 24),
                        ],

                        if (hotel.services.isNotEmpty) ...[
                          const Text(
                            'Dich vu di kem',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Chon dich vu de them vao don dat phong',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          ...hotel.services.map(
                            (s) => _buildServiceItem(
                              title: s.name,
                              price: s.unitPrice,
                              icon: Icons.star_outline,
                              selected: _selectedServiceIds.contains(s.id),
                              onTap: () {
                                setState(() {
                                  if (_selectedServiceIds.contains(s.id)) {
                                    _selectedServiceIds.remove(s.id);
                                  } else {
                                    _selectedServiceIds.add(s.id);
                                  }
                                });
                              },
                            ),
                          ),
                          if (_selectedServiceIds.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Tong dich vu da chon: ${currencyFormat.format(_selectedServiceTotal(hotel))}',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],

                        const Text(
                          'Chon phong',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (hotel.rooms.isEmpty)
                          const Text('Hien tai khach san chua cap nhat phong.')
                        else
                          ...hotel.rooms
                              .map((room) => _buildRoomCard(room, primaryBlue, hotel)),

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

  List<String> _getHotelImageUrls(Hotel hotel, String fallback) {
    final rawImages = hotel.images.isNotEmpty
        ? hotel.images
        : (hotel.pathImage.isNotEmpty ? [hotel.pathImage] : <String>[]);
    if (rawImages.isEmpty) return [fallback];
    return rawImages.map((path) => _resolveImageUrl(path, fallback)).toList();
  }

  String _resolveImageUrl(String path, String fallback) {
    if (path.isEmpty) return fallback;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '${AppConfig().baseURL}$path';
  }

  Widget _buildAmenitiesList(List<dynamic> amenities, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities
          .map((a) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(
                      a.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildRoomCard(HotelRoom room, Color primaryBlue, Hotel hotel) {
    final imageUrl = room.pathImage.isNotEmpty
        ? '${AppConfig().baseURL}${room.pathImage}'
        : 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?q=80&w=1000&auto=format&fit=crop';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: room.status == 'AVAILABLE'
            ? () => context.router.push(
                  RoomDetailRoute(
                    roomId: room.id,
                    statusRoom: room.status,
                    checkinDate: widget.checkinDate,
                    checkoutDate: widget.checkoutDate,
                    selectedServiceIds: _selectedServiceIds.toList(),
                    selectedServiceTotal: _selectedServiceTotal(hotel),
                  ),
                )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phong ${room.roomNumber} - ${room.roomTypeName}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: room.status == 'AVAILABLE'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    room.status == 'AVAILABLE' ? 'San sang' : 'Het phong',
                    style: TextStyle(
                      color: room.status == 'AVAILABLE' ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              room.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people_outline, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text('Suc chua: ${room.capacity} nguoi',
                    style: const TextStyle(fontSize: 13)),
                const Spacer(),
                Text(
                  currencyFormat.format(room.price),
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(' /dem', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: room.status == 'AVAILABLE'
                    ? () => context.router.push(
                          RoomDetailRoute(
                            roomId: room.id,
                            statusRoom: room.status,
                            checkinDate: widget.checkinDate,
                            checkoutDate: widget.checkoutDate,
                            selectedServiceIds: _selectedServiceIds.toList(),
                            selectedServiceTotal: _selectedServiceTotal(hotel),
                          ),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Chon phong nay'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required String title,
    required dynamic price,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withValues(alpha: 0.08) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : icon,
              color: selected ? Colors.blue : Colors.blueGrey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Text(
              currencyFormat.format(price),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
