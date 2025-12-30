import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../core/navigation/app_routes.dart';

@RoutePage()
class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  final List<Map<String, dynamic>> hotels = const [
    {
      "id": 1,
      "name": "Mường Thanh Holiday Hội An",
      "address": "Khu Cửa Đại, TP. Hội An, Quảng Nam",
      "description": "Khách sạn nghỉ dưỡng gần biển Cửa Đại.",
      "rating": 4.5,
      "pathImage":
          "https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop",
      "price": "1.200.000đ"
    },
    {
      "id": 2,
      "name": "Vinpearl Resort & Spa",
      "address": "Đảo Hòn Tre, Nha Trang",
      "description": "Trải nghiệm nghỉ dưỡng đẳng cấp 5 sao.",
      "rating": 5.0,
      "pathImage":
          "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=1000&auto=format&fit=crop",
      "price": "2.500.000đ"
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. CUSTOM HEADER
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withValues(alpha: 0.8)
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Chào mừng bạn,',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 16)),
                              Text('Khám phá ngay! 👋',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.router.push(
                                const ProfileRoute()), // Điều hướng đến màn Profile
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?img=68'), // Avatar mẫu
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search Bar giả
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10)
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 10),
                            Text('Bạn muốn đi đâu?',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final hotel = hotels[index];
                  return _buildHotelCard(context, hotel);
                },
                childCount: hotels.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Map<String, dynamic> hotel) {
    return GestureDetector(
      // onTap: () => context.router.push(HotelDetailRoute(hotel: hotel)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh khách sạn
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    hotel['pathImage'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child:
                          const Icon(Icons.hotel, size: 50, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(hotel['rating'].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Thông tin khách sạn
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel['name'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel['address'],
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hotel['price'],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Đăt phòng ngày'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
