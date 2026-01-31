import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/api/app_config.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:booking_app_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:booking_app_mobile/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../hotel/presentation/cubit/hotel_detail/hotel_detail_cubit.dart';
import '../../../hotel/presentation/cubit/hotel_detail/hotel_detail_state.dart';

class DailyReport {
  final String date;
  final int totalRevenue;
  final int totalBooking;

  const DailyReport({
    required this.date,
    required this.totalRevenue,
    required this.totalBooking,
  });
}

class MonthlyReport {
  final int year;
  final int month;
  final int totalRevenue;
  final int totalBooking;

  const MonthlyReport({
    required this.year,
    required this.month,
    required this.totalRevenue,
    required this.totalBooking,
  });
}

@RoutePage()
class HotelManageScreen extends StatefulWidget {
  const HotelManageScreen({super.key});

  @override
  State<HotelManageScreen> createState() => _HotelManageScreenState();
}

class _HotelManageScreenState extends State<HotelManageScreen> {
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');
  DateTime _dailyFrom = DateTime.now().subtract(const Duration(days: 6));
  DateTime _dailyTo = DateTime.now();
  int _year = DateTime.now().year;

  int? _hotelId;
  bool _loadingDaily = false;
  bool _loadingMonthly = false;
  String? _dailyError;
  String? _monthlyError;
  List<DailyReport> _daily = [];
  List<MonthlyReport> _monthly = [];

  @override
  void initState() {
    super.initState();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(amount);
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
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
                if (!context.mounted) return;
                Navigator.pop(context);
                context.router.replaceAll([const LoginRoute()]);
              } catch (e) {
                if (!context.mounted) return;
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

  Future<void> _fetchDaily() async {
    if (_hotelId == null) return;
    setState(() {
      _loadingDaily = true;
      _dailyError = null;
    });
    try {
      final dio = getIt<Dio>();
      final resp = await dio.get(
        '/reports/daily',
        queryParameters: {
          'hotelId': _hotelId,
          'from': _apiDateFormat.format(_dailyFrom),
          'to': _apiDateFormat.format(_dailyTo),
        },
      );
      final list = (resp.data['data'] as List)
          .map((e) => DailyReport(
                date: e['date'] as String,
                totalRevenue: (e['totalRevenue'] as num).toInt(),
                totalBooking: (e['totalBooking'] as num).toInt(),
              ))
          .toList();
      if (!mounted) return;
      setState(() {
        _daily = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dailyError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingDaily = false;
      });
    }
  }

  Future<void> _fetchMonthly() async {
    if (_hotelId == null) return;
    setState(() {
      _loadingMonthly = true;
      _monthlyError = null;
    });
    try {
      final dio = getIt<Dio>();
      final resp = await dio.get(
        '/reports/monthly',
        queryParameters: {
          'hotelId': _hotelId,
          'year': _year,
        },
      );
      final list = (resp.data['data'] as List)
          .map((e) => MonthlyReport(
                year: (e['year'] as num).toInt(),
                month: (e['month'] as num).toInt(),
                totalRevenue: (e['totalRevenue'] as num).toInt(),
                totalBooking: (e['totalBooking'] as num).toInt(),
              ))
          .toList();
      if (!mounted) return;
      setState(() {
        _monthly = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _monthlyError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingMonthly = false;
      });
    }
  }

  Future<void> _pickDailyFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dailyFrom,
      firstDate: DateTime(2020),
      lastDate: _dailyTo,
    );
    if (picked == null) return;
    setState(() => _dailyFrom = picked);
    _fetchDaily();
  }

  Future<void> _pickDailyTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dailyTo,
      firstDate: _dailyFrom,
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _dailyTo = picked);
    _fetchDaily();
  }

  void _changeYear(int year) {
    setState(() => _year = year);
    _fetchMonthly();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return BlocProvider(
      create: (context) => HotelDetailCubit(getIt<HotelRepository>())..fetch(1),
      child: BlocBuilder<HotelDetailCubit, HotelDetailState>(
        builder: (context, state) {
          final resolvedHotelId = state.hotel?.id;
          if (resolvedHotelId != null && resolvedHotelId != _hotelId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _hotelId = resolvedHotelId);
              _fetchDaily();
              _fetchMonthly();
            });
          }
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
                  // --- PHẦN DOANH THU (OVERVIEW) ---
                  _buildRevenueCard(primaryColor),

                  const SizedBox(height: 24),

                  const Text(
                    'Doanh thu theo ngày',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDailySection(primaryColor),

                  const SizedBox(height: 28),

                  const Text(
                    'Doanh thu theo tháng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMonthlySection(primaryColor),

                  const SizedBox(height: 28),

                  const Text(
                    'Thông tin khách sạn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildHotelInfoCard(context, state),

                  const SizedBox(height: 28),

                  // --- DANH MỤC QUẢN LÝ ---
                  const Text(
                    'Quản lý',
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
                      _buildTile(context, Icons.meeting_room, 'Phòng',
                          () => context.router.push(RoomRoute(hotelId: 1))),
                      _buildTile(context, Icons.room_service, 'Dịch vụ',
                          () => context.router.push(const ServiceRoute())),
                      _buildTile(
                          context,
                          Icons.assignment,
                          'Đơn đặt phòng',
                          () => context.router
                              .push(BookingAdminRoute(hotelId: 1))),
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

  Widget _buildDailySection(Color primaryColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDailyFrom,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_displayDateFormat.format(_dailyFrom)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDailyTo,
                    icon: const Icon(Icons.event_outlined, size: 16),
                    label: Text(_displayDateFormat.format(_dailyTo)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loadingDaily)
              const LinearProgressIndicator(minHeight: 2)
            else if (_dailyError != null)
              Text(_dailyError!, style: const TextStyle(color: Colors.red))
            else if (_daily.isEmpty)
              const Center(
                  child: Text('Chưa có dữ liệu trong khoảng thời gian này'))
            else ...[
              _buildTotalRow(
                totalRevenue: _daily.fold<int>(0, (s, e) => s + e.totalRevenue),
                totalBooking: _daily.fold<int>(0, (s, e) => s + e.totalBooking),
              ),
              const SizedBox(height: 20),
              _buildBarChart(
                _daily
                    .map((e) =>
                        DateFormat('dd/MM').format(DateTime.parse(e.date)))
                    .toList(),
                _daily.map((e) => e.totalRevenue).toList(),
                primaryColor,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySection(Color primaryColor) {
    // Chuẩn bị dữ liệu cho đủ 12 tháng
    List<String> labels = [];
    List<int> values = [];

    // Tạo danh sách 12 tháng cố định
    for (int i = 1; i <= 12; i++) {
      labels.add('T$i');

      // Tìm dữ liệu của tháng i trong danh sách _monthly
      // Nếu không có thì trả về object ảo với revenue = 0
      final report = _monthly.firstWhere(
        (m) => m.month == i,
        orElse: () => MonthlyReport(
            year: _year, month: i, totalRevenue: 0, totalBooking: 0),
      );
      values.add(report.totalRevenue);
    }

    final totalRevenue = values.fold(0, (sum, item) => sum + item);
    final totalBooking =
        _monthly.fold(0, (sum, item) => sum + item.totalBooking);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Năm',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _year,
                  underline: const SizedBox(),
                  items: List.generate(5, (i) {
                    final y = DateTime.now().year - 2 + i;
                    return DropdownMenuItem(value: y, child: Text('$y'));
                  }),
                  onChanged: (v) {
                    if (v == null) return;
                    _changeYear(v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loadingMonthly)
              const LinearProgressIndicator(minHeight: 2)
            else if (_monthlyError != null)
              Text(_monthlyError!, style: const TextStyle(color: Colors.red))
            else ...[
              _buildTotalRow(
                totalRevenue: totalRevenue,
                totalBooking: totalBooking,
              ),
              const SizedBox(height: 20),
              // Truyền đủ 12 tháng vào biểu đồ
              _buildBarChart(labels, values, Colors.orange),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
      {required int totalRevenue, required int totalBooking}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            'Tổng doanh thu: ${NumberFormat.compact(locale: 'vi').format(totalRevenue)}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('Đơn: $totalBooking',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // --- HÀM VẼ BIỂU ĐỒ ĐÃ CẬP NHẬT ---
  Widget _buildBarChart(List<String> labels, List<int> values, Color color) {
    if (values.isEmpty) return const SizedBox();

    // Tìm giá trị lớn nhất để chia tỷ lệ
    final int maxValue = values.fold(0, (max, e) => e > max ? e : max);
    // Tránh chia cho 0
    final double safeMax = maxValue == 0 ? 1 : maxValue.toDouble();

    // Số lượng đường kẻ ngang (grid lines)
    const int steps = 4;

    return SizedBox(
      height: 250, // Chiều cao tổng thể của khu vực biểu đồ
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TRỤC Y (Doanh thu)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(steps + 1, (index) {
              // Tính giá trị hiển thị cho từng mốc (từ trên xuống dưới)
              final value = (safeMax / steps) * (steps - index);
              return Text(
                NumberFormat.compact(locale: 'en_US')
                    .format(value), // Ví dụ: 1M, 500k
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
          const SizedBox(width: 10), // Khoảng cách giữa trục Y và biểu đồ

          // KHU VỰC CỘT VÀ TRỤC X
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Dành ra 20px chiều cao ở dưới cùng cho nhãn trục X
                final double chartAreaHeight = constraints.maxHeight - 20;

                return Column(
                  children: [
                    // Phần lưới và cột
                    SizedBox(
                      height: chartAreaHeight,
                      child: Stack(
                        children: [
                          // Lớp 1: Vẽ các đường kẻ ngang (Grid lines)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(steps + 1, (index) {
                              return Container(
                                height: 1,
                                color: Colors.grey
                                    .withValues(alpha: 0.1), // Đường kẻ mờ
                              );
                            }),
                          ),
                          // Lớp 2: Vẽ các cột
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(labels.length, (index) {
                              final value = values[index];
                              final heightFactor = value / safeMax;

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Tooltip(
                                    preferBelow: false,
                                    message:
                                        '${labels[index]}: ${_formatCurrency(value.toDouble())}',
                                    child: FractionallySizedBox(
                                      heightFactor: heightFactor == 0
                                          ? 0.0
                                          : heightFactor,
                                      widthFactor: 0.5,
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          // Gradient từ nhạt đến đậm
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              color.withValues(alpha: 0.6),
                                              color,
                                            ],
                                          ),
                                          // Bo tròn góc trên của cột
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Phần nhãn TRỤC X (Tháng/Ngày)
                    SizedBox(
                      height: 14,
                      child: Row(
                        children: List.generate(labels.length, (index) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                labels[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Card doanh thu với Gradient
  Widget _buildRevenueCard(Color primaryColor) {
    final now = DateTime.now();
    MonthlyReport? current;
    MonthlyReport? previous;

    if (_monthly.isNotEmpty) {
      MonthlyReport? fallback;
      for (final item in _monthly) {
        if (fallback == null ||
            item.year > fallback.year ||
            (item.year == fallback.year && item.month > fallback.month)) {
          fallback = item;
        }
      }

      if (_year == now.year) {
        for (final item in _monthly) {
          if (item.year == now.year && item.month == now.month) {
            current = item;
            break;
          }
        }
      }
      current ??= fallback;

      if (current != null) {
        var prevMonth = current.month - 1;
        var prevYear = current.year;
        if (prevMonth <= 0) {
          prevMonth = 12;
          prevYear -= 1;
        }
        for (final item in _monthly) {
          if (item.year == prevYear && item.month == prevMonth) {
            previous = item;
            break;
          }
        }
      }
    }

    final revenue = current?.totalRevenue ?? 0;
    final booking = current?.totalBooking ?? 0;
    final title = (current != null &&
            current.year == now.year &&
            current.month == now.month)
        ? 'Doanh thu tháng này'
        : (current == null
            ? 'Doanh thu tháng này'
            : 'Doanh thu tháng ${current.month.toString().padLeft(2, '0')}/${current.year}');

    String deltaText;
    if (previous == null || previous.totalRevenue == 0) {
      deltaText = 'Chưa có dữ liệu tháng trước';
    } else {
      final delta =
          ((revenue - previous.totalRevenue) / previous.totalRevenue) * 100;
      deltaText =
          '${delta >= 0 ? "tăng" : "giảm"} ${delta.toStringAsFixed(1)}% so với tháng trước';
    }

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
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Icon(Icons.trending_up,
                  color: Colors.white.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(revenue.toDouble()),
            style: const TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Đơn đặt phòng: $booking',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              deltaText,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          )
        ],
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
              hotel?.name ?? 'Tên khách sạn',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(hotel?.address ?? '-',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(hotel?.phone ?? '-',
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
                    Text(state.isUploadingImages ? 'Đang tải...' : 'Thêm ảnh'),
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
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '${AppConfig().baseURL}$path';
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

    if (!context.mounted) return;
    final cubit = context.read<HotelDetailCubit>();
    final success =
        await cubit.uploadImages(hotelId: hotelId, filePaths: paths);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Thêm ảnh thành công'),
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
