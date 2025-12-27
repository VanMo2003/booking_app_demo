import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/navigation/app_routes.dart';

@RoutePage()
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Widget _buildTile(BuildContext context, IconData icon, String label,
      void Function() onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Admin',
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
      )),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildTile(context, Icons.work, 'Position',
                () => context.router.push(const PositionRoute())),
            _buildTile(context, Icons.person, 'Staff',
                () => context.router.push(const StaffRoute())),
            _buildTile(context, Icons.category, 'Room type',
                () => context.router.push(const RoomTypeRoute())),
            _buildTile(context, Icons.meeting_room, 'Room',
                () => context.router.push(const RoomRoute())),
            _buildTile(context, Icons.room_service, 'Service',
                () => context.router.push(const ServiceRoute())),
            _buildTile(context, Icons.book_online, 'Booking',
                () => context.router.push(const BookingRoute())),
          ],
        ),
      ),
    );
  }
}
