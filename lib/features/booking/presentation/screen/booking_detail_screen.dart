// booking_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Import lại các dependencies cần thiết như màn hình Admin
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/api/app_config.dart';
import '../../domain/entity/booking_entity.dart';
import '../cubit/booking_cubit.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingEntity booking;

  const BookingDetailScreen({super.key, required this.booking});

  // Copy các helper functions (formatCurrency, formatDate, resolveAvatar)
  // hoặc move chúng vào class Utils chung.
  String _formatCurrency(num? amount) {
    if (amount == null) return '0 đ';
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '--/--/----';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _resolveAvatarUrl(String? path) {
    const fallbackUrl =
        'https://ui-avatars.com/api/?background=random&name=User';
    if (path == null || path.isEmpty) return fallbackUrl;
    if (path.startsWith('http')) return path;
    return "${AppConfig().baseURL}$path";
  }

  @override
  Widget build(BuildContext context) {
    // Cần BlocProvider riêng ở đây để handle các action Confirm/Cancel
    return BlocProvider(
      create: (_) => BookingCubit(
        getBookings: getIt(),
        createBooking: getIt(),
        confirmBooking: getIt(),
        cancelBooking: getIt(),
        completeBooking: getIt(),
      ),
      child: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state.status.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Thao tác thành công'),
                  backgroundColor: Colors.green),
            );
            Navigator.pop(context, true); // Pop và báo cần refresh
          } else if (state.status.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ?? 'Lỗi'),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status.isLoading;

          return AppScaffold(
            title: 'Chi tiết đơn #${booking.id}',
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Status Section
                      Center(child: _buildBigStatusChip(booking.bookingStatus)),
                      const SizedBox(height: 24),

                      // 2. Customer Info
                      _buildSectionTitle('Thông tin khách hàng'),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(
                                _resolveAvatarUrl(booking.customer?.pathImage)),
                          ),
                          title: Text(booking.customer?.fullName ?? 'N/A',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(booking.customer?.phoneNumber ??
                                  'Không có SĐT'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Stay Info
                      _buildSectionTitle('Thời gian lưu trú'),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _buildDateBox(context, 'Nhận phòng',
                                      booking.checkinDate)),
                              const Icon(Icons.arrow_forward,
                                  color: Colors.grey),
                              Expanded(
                                  child: _buildDateBox(context, 'Trả phòng',
                                      booking.checkoutDate)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Rooms List
                      _buildSectionTitle(
                          'Phòng đã đặt (${booking.bookingRooms?.length ?? 0})'),
                      if (booking.bookingRooms != null)
                        ...booking.bookingRooms!.map((bookingRoom) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              "${AppConfig().baseURL}${bookingRoom.roomInfo?.pathImage}"))),
                                  // child: Icon(Icons.meeting_room,
                                  //     color: Theme.of(context).primaryColor),
                                ),
                                title: Text(
                                    'Phòng ${bookingRoom.roomInfo?.roomNumber ?? "N/A"}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    bookingRoom.roomInfo?.roomTypeName ??
                                        "Loại phòng thường"),
                              ),
                            )),

                      const SizedBox(height: 20),

                      // 5. Payment Info
                      _buildSectionTitle('Thanh toán'),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow('Phương thức',
                                  booking.paymentMethod ?? 'Tiền mặt'),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tổng tiền',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    _formatCurrency(booking.totalAmount),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 80), // Space for bottom buttons
                    ],
                  ),
                ),

                // Bottom Buttons (Floating)
                if (booking.bookingStatus == 'PENDING' ||
                    booking.bookingStatus == 'CONFIRMED')
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, -2))
                        ],
                      ),
                      child: _buildActionButtons(context, booking.id!),
                    ),
                  ),

                // Loading Overlay
                if (isLoading)
                  Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, int bookingId) {
    final cubit = context.read<BookingCubit>();

    if (booking.bookingStatus == 'PENDING') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => cubit.cancel(bookingId),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Từ chối'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => cubit.confirm(bookingId),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Xác nhận'),
            ),
          ),
        ],
      );
    }

    if (booking.bookingStatus == 'CONFIRMED') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => cubit.complete(bookingId),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Check-in / Hoàn tất'),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // --- Widget Helpers ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDateBox(BuildContext context, String label, String? dateStr) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(_formatDate(dateStr),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontSize: 15)),
      ],
    );
  }

  Widget _buildBigStatusChip(String? status) {
    Color color;
    String label;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        label = 'CHỜ DUYỆT';
        break;
      case 'CONFIRMED':
        color = Colors.blue;
        label = 'ĐÃ XÁC NHẬN';
        break;
      case 'COMPLETED':
        color = Colors.green;
        label = 'HOÀN THÀNH';
        break;
      case 'CANCELED':
        color = Colors.red;
        label = 'ĐÃ HỦY';
        break;
      default:
        color = Colors.grey;
        label = status ?? 'UNKNOWN';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }
}
