import 'dart:async';

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

class BookingDetailScreen extends StatefulWidget {
  final BookingEntity booking;
  final bool allowActions;

  const BookingDetailScreen({
    super.key,
    required this.booking,
    this.allowActions = true,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late BookingEntity _booking;
  late Timer _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
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

  void _showSnack(SnackBar snackBar) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(snackBar);
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0 d';
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'd').format(amount);
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

  String _resolveImageUrl(String? path, {bool isAvatar = false}) {
    if (path == null || path.isEmpty) {
      return isAvatar
          ? 'https://ui-avatars.com/api/?background=random&name=User'
          : 'https://placehold.co/600x400/png?text=No+Image';
    }
    if (path.startsWith('http')) return path;
    return '${AppConfig().baseURL}$path';
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final raw = value.trim();
    return DateTime.tryParse(raw) ??
        DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }

  bool _isVnPay() => (_booking.paymentMethod ?? '').toUpperCase() == 'VN_PAY';

  bool _isPaid() => (_booking.paymentStatus ?? '').toUpperCase() == 'PAID';

  bool _isCancelled() {
    final status = (_booking.bookingStatus ?? '').toUpperCase();
    return status == 'CANCELED' || status == 'CANCELLED';
  }

  Duration? _remainingPaymentWindow() {
    final expireAt = _parseDateTime(_booking.paymentExpireAt);
    if (expireAt == null) return null;
    final diff = expireAt.difference(_now);
    if (diff.isNegative) return Duration.zero;
    return diff;
  }

  bool _isInPaymentWindow() {
    final remain = _remainingPaymentWindow();
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

  String? _paymentCountdownLabel() {
    if (!_isVnPay() || _isPaid()) return null;
    final remain = _remainingPaymentWindow();
    if (remain == null) return null;
    if (remain == Duration.zero) return 'Het han thanh toan';
    return 'Con lai: ${_formatDuration(remain)}';
  }

  Future<void> _openPaymentUrl(String paymentUrl) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(paymentUrl: paymentUrl),
      ),
    );

    if (result == true) {
      final bookingId = _booking.id;
      if (bookingId != null) {
        await PaymentSessionStore.clear(bookingId);
      }

      if (!mounted) return;
      setState(() {
        _booking = BookingEntity(
          id: _booking.id,
          checkinDate: _booking.checkinDate,
          checkoutDate: _booking.checkoutDate,
          bookingStatus: _booking.bookingStatus,
          paymentMethod: _booking.paymentMethod,
          paymentStatus: 'PAID',
          paymentExpireAt: _booking.paymentExpireAt,
          paidAt: DateTime.now().toIso8601String(),
          hotel: _booking.hotel,
          customer: _booking.customer,
          bookingRooms: _booking.bookingRooms,
          bookingServices: _booking.bookingServices,
          totalAmount: _booking.totalAmount,
          note: _booking.note,
          onCreate: _booking.onCreate,
          onUpdate: _booking.onUpdate,
        );
      });
      Navigator.pop(context, true);
    } else if (result == false) {
      _showSnack(const SnackBar(content: Text('Thanh toan that bai')));
    }
  }

  Future<void> _requestAndOpenPayment() async {
    final amount = _booking.totalAmount ?? 0;
    final bookingId = _booking.id;
    if (bookingId == null) {
      _showSnack(const SnackBar(content: Text('Khong tim thay bookingId')));
      return;
    }
    if (amount <= 0) {
      _showSnack(const SnackBar(content: Text('Khong co so tien can thanh toan')));
      return;
    }

    try {
      final dio = getIt<Dio>();
      final resp = await dio.get(
        '/payment/vn-pay',
        queryParameters: {
          'bookingId': bookingId,
          'amount': amount,
          'bankCode': 'NCB',
        },
      );
      final paymentUrl = resp.data?['data']?['paymentUrl']?.toString();
      if (paymentUrl == null || paymentUrl.isEmpty) {
        _showSnack(const SnackBar(content: Text('Khong nhan duoc link thanh toan')));
        return;
      }

      final expireAt = _parseDateTime(_booking.paymentExpireAt) ??
          DateTime.now().add(const Duration(minutes: 15));
      await PaymentSessionStore.save(
        bookingId: bookingId,
        paymentUrl: paymentUrl,
        expireAt: expireAt,
      );

      if (!mounted) return;
      await _openPaymentUrl(paymentUrl);
    } catch (e) {
      _showSnack(SnackBar(content: Text('Loi thanh toan: $e')));
    }
  }

  Future<void> _handlePaymentAction() async {
    final bookingId = _booking.id;
    if (bookingId == null) return;

    final session = await PaymentSessionStore.get(bookingId);
    if (session != null && !session.isExpired) {
      if (!mounted) return;
      await _openPaymentUrl(session.paymentUrl);
      return;
    }

    await _requestAndOpenPayment();
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCustomerPay = !widget.allowActions && _isVnPay() && !_isPaid() && !_isCancelled();

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
            _showSnack(
              const SnackBar(
                content: Text('Thao tac thanh cong'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state.status.isFailure) {
            _showSnack(
              SnackBar(
                content: Text(state.errorMessage ?? 'Loi'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status.isLoading;
          final countdown = _paymentCountdownLabel();

          return AppScaffold(
            title: 'Chi tiet don #${_booking.id}',
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: _buildBigStatusChip(_booking.bookingStatus)),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Thong tin khach hang'),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(
                              _resolveImageUrl(_booking.customer?.pathImage, isAvatar: true),
                            ),
                          ),
                          title: Text(
                            _booking.customer?.fullName ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(_booking.customer?.phoneNumber ?? 'Khong co SDT'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('Thoi gian luu tru'),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildDateBox(context, 'Nhan phong', _booking.checkinDate),
                              ),
                              const Icon(Icons.arrow_forward, color: Colors.grey),
                              Expanded(
                                child: _buildDateBox(context, 'Tra phong', _booking.checkoutDate),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle('Phong da dat (${_booking.bookingRooms?.length ?? 0})'),
                      if (_booking.bookingRooms != null)
                        ..._booking.bookingRooms!.map(
                          (bookingRoom) {
                            final imageUrl = _resolveImageUrl(bookingRoom.roomInfo?.pathImage);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade100,
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.meeting_room,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withValues(alpha: 0.5),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                title: Text(
                                  'Phong ${bookingRoom.roomInfo?.roomNumber ?? "N/A"}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(bookingRoom.roomInfo?.roomTypeName ?? 'Loai phong thuong'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 20),

                      _buildSectionTitle('Thanh toan'),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow('Phuong thuc', _booking.paymentMethod ?? 'Tien mat'),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Trang thai thanh toan',
                                      style: TextStyle(color: Colors.grey)),
                                  _buildPaymentStatusChip(_booking.paymentStatus),
                                ],
                              ),
                              if (countdown != null) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    countdown,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isInPaymentWindow() ? Colors.orange : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tong tien',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(
                                    _formatCurrency(_booking.totalAmount),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (canCustomerPay) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: FutureBuilder<bool>(
                                    future: (_booking.id == null)
                                        ? Future.value(false)
                                        : PaymentSessionStore.get(_booking.id!).then(
                                            (session) => session != null && !session.isExpired,
                                          ),
                                    builder: (context, snapshot) {
                                      final hasLocalSession = snapshot.data == true;
                                      final isContinue = hasLocalSession || _isInPaymentWindow();
                                      final label = isContinue
                                          ? 'Tiep tuc thanh toan VNPay'
                                          : 'Thanh toan lai VNPay';

                                      return ElevatedButton(
                                        onPressed: _handlePaymentAction,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          backgroundColor: Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(label),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                if (widget.allowActions &&
                    (_booking.bookingStatus == 'PENDING' ||
                        _booking.bookingStatus == 'CONFIRMED'))
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          )
                        ],
                      ),
                      child: _buildActionButtons(context, _booking.id!),
                    ),
                  ),

                if (isLoading)
                  Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, int bookingId) {
    final cubit = context.read<BookingCubit>();

    if (_booking.bookingStatus == 'PENDING') {
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
              child: const Text('Tu choi'),
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
              child: const Text('Xac nhan'),
            ),
          ),
        ],
      );
    }

    if (_booking.bookingStatus == 'CONFIRMED') {
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
          child: const Text('Check-in / Hoan tat'),
        ),
      );
    }

    return const SizedBox.shrink();
  }

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
        Text(
          _formatDate(dateStr),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildBigStatusChip(String? status) {
    Color color;
    String label;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        label = 'CHO DUYET';
        break;
      case 'CONFIRMED':
        color = Colors.blue;
        label = 'DA XAC NHAN';
        break;
      case 'COMPLETED':
        color = Colors.green;
        label = 'HOAN THANH';
        break;
      case 'CANCELED':
      case 'CANCELLED':
        color = Colors.red;
        label = 'DA HUY';
        break;
      default:
        color = Colors.grey;
        label = status ?? 'UNKNOWN';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
