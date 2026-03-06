import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/api/app_config.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/storage/payment_session_store.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../payment/presentation/screen/payment_webview_screen.dart';
import '../../domain/entity/booking_entity.dart';
import '../cubit/booking_cubit.dart';
import 'booking_detail_screen.dart';

@RoutePage()
class BookingAdminScreen extends StatefulWidget {
  final int? customerId;
  final int? hotelId;

  const BookingAdminScreen({super.key, this.customerId, this.hotelId});

  @override
  State<BookingAdminScreen> createState() => _BookingAdminScreenState();
}

class _BookingAdminScreenState extends State<BookingAdminScreen> {
  late Timer _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0 d';
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'd').format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--/--';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _resolveAvatarUrl(String? path) {
    const fallbackUrl =
        'https://ui-avatars.com/api/?background=random&name=Khach';
    if (path == null || path.isEmpty) return fallbackUrl;
    if (path.startsWith('http')) return path;
    return '${AppConfig().baseURL}$path';
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final raw = value.trim();
    final parsed = DateTime.tryParse(raw) ??
        DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    return parsed;
  }

  bool _isVnPay(BookingEntity booking) {
    return (booking.paymentMethod ?? '').toUpperCase() == 'VN_PAY';
  }

  bool _isPaid(BookingEntity booking) {
    return (booking.paymentStatus ?? '').toUpperCase() == 'PAID';
  }

  bool _isCancelled(BookingEntity booking) {
    final status = (booking.bookingStatus ?? '').toUpperCase();
    return status == 'CANCELED' || status == 'CANCELLED';
  }

  Duration? _remainingPaymentWindow(BookingEntity booking) {
    final expireAt = _parseDateTime(booking.paymentExpireAt);
    if (expireAt == null) return null;
    final diff = expireAt.difference(_now);
    if (diff.isNegative) return Duration.zero;
    return diff;
  }

  bool _isInPaymentWindow(BookingEntity booking) {
    final remain = _remainingPaymentWindow(booking);
    return remain != null && remain > Duration.zero;
  }

  String _formatDuration(Duration d) {
    final total = d.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String? _paymentCountdownLabel(BookingEntity booking) {
    if (!_isVnPay(booking) || _isPaid(booking)) return null;
    final remain = _remainingPaymentWindow(booking);
    if (remain == null) return null;
    if (remain == Duration.zero) return 'Het han thanh toan';
    return 'Con lai: ${_formatDuration(remain)}';
  }

  bool _canShowPaymentAction(BookingEntity booking, bool isCustomerView) {
    if (!isCustomerView) return false;
    if (!_isVnPay(booking) || _isPaid(booking) || _isCancelled(booking)) {
      return false;
    }
    return true;
  }

  Future<void> _openPaymentUrl(BuildContext context, String paymentUrl,
      {required VoidCallback onSuccess}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(paymentUrl: paymentUrl),
      ),
    );

    if (result == true && context.mounted) {
      onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toan thanh cong'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (result == false && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toan that bai')),
      );
    }
  }

  Future<void> _requestAndOpenPayment(
    BuildContext context,
    BookingEntity booking,
    VoidCallback onSuccess,
  ) async {
    final amount = booking.totalAmount ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong co so tien can thanh toan')),
      );
      return;
    }

    try {
      final dio = getIt<Dio>();
      final resp = await dio.get(
        '/payment/vn-pay',
        queryParameters: {
          'bookingId': booking.id,
          'amount': amount,
          'bankCode': 'NCB',
        },
      );

      final paymentUrl = resp.data?['data']?['paymentUrl']?.toString();
      if (paymentUrl == null || paymentUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Khong nhan duoc link thanh toan')),
        );
        return;
      }

      final expireAt = _parseDateTime(booking.paymentExpireAt) ??
          DateTime.now().add(const Duration(minutes: 15));
      if (booking.id != null) {
        await PaymentSessionStore.save(
          bookingId: booking.id!,
          paymentUrl: paymentUrl,
          expireAt: expireAt,
        );
      }

      if (!context.mounted) return;
      await _openPaymentUrl(context, paymentUrl, onSuccess: onSuccess);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi thanh toan: $e')),
      );
    }
  }

  Future<void> _handlePaymentAction(
    BuildContext context,
    BookingEntity booking,
    VoidCallback onSuccess,
  ) async {
    final bookingId = booking.id;
    if (bookingId == null) return;

    if (_isInPaymentWindow(booking)) {
      final session = await PaymentSessionStore.get(bookingId);
      if (session != null && !session.isExpired) {
        if (!context.mounted) return;
        await _openPaymentUrl(context, session.paymentUrl, onSuccess: onSuccess);
        return;
      }
    }

    await _requestAndOpenPayment(context, booking, onSuccess);
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        label = 'Cho duyet';
        break;
      case 'CONFIRMED':
        color = Colors.blue;
        label = 'Da xac nhan';
        break;
      case 'CHECKED_IN':
        color = Colors.purple;
        label = 'Dang o';
        break;
      case 'COMPLETED':
        color = Colors.green;
        label = 'Hoan thanh';
        break;
      case 'CANCELLED':
      case 'CANCELED':
        color = Colors.red;
        label = 'Da huy';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String? status) {
    final value = (status ?? '').toUpperCase();
    Color color;
    String label;
    switch (value) {
      case 'PAID':
        color = Colors.green;
        label = 'Da thanh toan';
        break;
      case 'PENDING':
        color = Colors.orange;
        label = 'Dang cho thanh toan';
        break;
      case 'UNPAID':
        color = Colors.redAccent;
        label = 'Chua thanh toan';
        break;
      default:
        color = Colors.grey;
        label = status ?? 'Khong ro';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  int _statusPriority(String? status) {
    switch (status) {
      case 'PENDING':
        return 0;
      case 'CONFIRMED':
        return 1;
      case 'COMPLETED':
        return 2;
      case 'CANCELED':
        return 3;
      default:
        return 99;
    }
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    try {
      return DateTime.parse(value);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomerView = widget.customerId != null && widget.hotelId == null;

    return BlocProvider(
      create: (_) => BookingCubit(
        getBookings: getIt(),
        createBooking: getIt(),
        confirmBooking: getIt(),
        cancelBooking: getIt(),
        completeBooking: getIt(),
      )..fetch(hotelId: widget.hotelId, customerId: widget.customerId),
      child: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Co loi xay ra'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return AppScaffold(
            title: isCustomerView ? 'Don dat phong cua toi' : 'Quan ly dat phong',
            body: _buildContent(context, state, isCustomerView),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingState state,
    bool isCustomerView,
  ) {
    if (state.status.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final bookings = [...?state.items];
    bookings.sort((a, b) {
      final statusA = _statusPriority(a.bookingStatus);
      final statusB = _statusPriority(b.bookingStatus);
      if (statusA != statusB) return statusA.compareTo(statusB);
      final dateA = _parseDate(a.onCreate ?? a.checkinDate);
      final dateB = _parseDate(b.onCreate ?? b.checkinDate);
      return dateB.compareTo(dateA);
    });

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Chua co don dat phong nao',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<BookingCubit>()
            .fetch(hotelId: widget.hotelId, customerId: widget.customerId);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = bookings[index];
          final countdown = _paymentCountdownLabel(item);
          final canPay = _canShowPaymentAction(item, isCustomerView);
          final inWindow = _isInPaymentWindow(item);
          final payButtonLabel = inWindow
              ? 'Tiep tuc thanh toan VNPay'
              : 'Thanh toan lai VNPay';

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingDetailScreen(
                      booking: item,
                      allowActions: !isCustomerView,
                    ),
                  ),
                ).then((shouldRefresh) {
                  if (shouldRefresh == true) {
                    context.read<BookingCubit>().fetch(
                          hotelId: widget.hotelId,
                          customerId: widget.customerId,
                        );
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${item.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                          ),
                        ),
                        _buildStatusChip(item.bookingStatus ?? 'UNKNOWN'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildPaymentStatusChip(item.paymentStatus),
                      ],
                    ),
                    if (countdown != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          countdown,
                          style: TextStyle(
                            fontSize: 12,
                            color: inWindow ? Colors.orange : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Divider(height: 20, thickness: 0.5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              NetworkImage(_resolveAvatarUrl(item.customer?.pathImage)),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.customer?.fullName ?? 'Khach vang lai',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_formatDate(item.checkinDate)} - ${_formatDate(item.checkoutDate)}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(item.totalAmount),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.bookingRooms?.length ?? 0} phong',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (canPay) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _handlePaymentAction(
                            context,
                            item,
                            () => context.read<BookingCubit>().fetch(
                                  hotelId: widget.hotelId,
                                  customerId: widget.customerId,
                                ),
                          ),
                          icon: const Icon(Icons.payments_outlined),
                          label: Text(payButtonLabel),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
