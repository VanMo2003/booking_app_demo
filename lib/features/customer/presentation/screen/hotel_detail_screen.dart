import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.primaryColor;
    final imageUrl = (hotel.pathImage.isNotEmpty)
        ? hotel.pathImage
        : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.router.back(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên và Giá
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "2000000",
                        style: TextStyle(color: primaryBlue, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Địa chỉ
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

                  // Mô tả
                  const Text(
                    "Mô tả khách sạn",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Trải nghiệm sự sang trọng và thoải mái bậc nhất tại Mường Thanh. Với không gian thiết kế hiện đại, tinh tế cùng dịch vụ đẳng cấp quốc tế, chúng tôi cam kết mang lại kỳ nghỉ khó quên cho bạn và gia đình.",
                    style: TextStyle(color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Tiện ích (Amenities)
                  const Text(
                    "Tiện ích khách sạn",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildAmenities(primaryBlue),

                  const SizedBox(height: 24),

                  // Dịch vụ kèm theo (Services từ JSON của bạn)
                  const Text(
                    "Dịch vụ đi kèm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildServiceItem("Thuê xe máy/ô tô", "180.000đ/ngày", Icons.directions_car),
                  _buildServiceItem("Giặt ủi lấy ngay", "50.000đ/kg", Icons.local_laundry_service),

                  const SizedBox(height: 100), // Khoảng trống để không bị đè bởi nút đặt
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("ĐẶT PHÒNG NGAY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildAmenities(Color color) {
    final List<Map<String, dynamic>> ams = [
      {"icon": Icons.wifi, "label": "Wifi miễn phí"},
      {"icon": Icons.pool, "label": "Hồ bơi"},
      {"icon": Icons.restaurant, "label": "Nhà hàng"},
      {"icon": Icons.spa, "label": "Spa & Massage"},
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 15,
      children: ams
          .map((a) => Column(
                children: [
                  Icon(a['icon'], color: color),
                  const SizedBox(height: 4),
                  Text(a['label'], style: const TextStyle(fontSize: 12)),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildServiceItem(String title, String price, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        ],
      ),
    );
  }
}
