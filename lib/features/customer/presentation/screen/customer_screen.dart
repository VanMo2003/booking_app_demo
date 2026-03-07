import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/api/app_config.dart';
import 'package:booking_app_mobile/core/constants/constant.dart';
import 'package:booking_app_mobile/features/hotel/domain/use_case/get_hotel_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../hotel/domain/entities/hotel.dart';
import '../../../hotel/presentation/cubit/hotel_bloc.dart';
import '../../../hotel/presentation/cubit/hotel_event.dart';
import '../../../hotel/presentation/cubit/hotel_state.dart';

@RoutePage()
class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final _scroll = ScrollController();
  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _checkinDate;
  DateTime? _checkoutDate;
  int? _customerId;

  @override
  void initState() {
    super.initState();
    // _scroll.addListener(_onScroll);
    final now = DateTime.now();
    _checkinDate = DateTime(now.year, now.month, now.day);
    _checkoutDate = _checkinDate!.add(const Duration(days: 1));
  }

  void _onScroll() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) {
      final bloc = context.read<HotelBloc>();
      final st = bloc.state;
      if (!st.hasMore || st.status == HotelStatus.loading) return;
      bloc.add(
        HotelsFetched(
          page: st.page,
          size: st.size,
          checkinDate: _apiDateFormat.format(_checkinDate!),
          checkoutDate: _apiDateFormat.format(_checkoutDate!),
        ),
      );
    }
  }

  Future<void> _loadCustomerId() async {
    final storage = getIt<FlutterSecureStorage>();
    final raw = await storage.read(key: Constants.customerId);
    if (!mounted) return;
    setState(() {
      _customerId = int.tryParse(raw ?? '');
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày';
    return _displayDateFormat.format(date);
  }

  Future<void> _pickDate({required bool isCheckin}) async {
    final initialDate = isCheckin
        ? (_checkinDate ?? DateTime.now())
        : (_checkoutDate ??
            _checkinDate?.add(const Duration(days: 1)) ??
            DateTime.now().add(const Duration(days: 1)));
    final firstDate =
        isCheckin ? DateTime.now() : (_checkinDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked == null) return;
    setState(() {
      if (isCheckin) {
        _checkinDate = picked;
        if (_checkoutDate != null && _checkoutDate!.isBefore(picked)) {
          _checkoutDate = picked.add(const Duration(days: 1));
        }
      } else {
        _checkoutDate = picked;
      }
    });
  }

  void _fetchHotels(BuildContext context, {required int size}) {
    context.read<HotelBloc>().add(
          HotelsFetched(
            page: 0,
            size: size,
            refresh: true,
            checkinDate: _apiDateFormat.format(_checkinDate!),
            checkoutDate: _apiDateFormat.format(_checkoutDate!),
          ),
        );
  }

  void _applyFilter(BuildContext context, {required int size}) {
    if (_checkoutDate!.isBefore(_checkinDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày đi phải sau ngày đến'),
        ),
      );
      return;
    }
    _fetchHotels(context, size: size);
  }

  Future<void> _openBookingList(BuildContext context) async {
    await _loadCustomerId();
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa xác định thông tin khách hàng')),
      );
      return;
    }
    context.router.push(BookingAdminRoute(customerId: _customerId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<HotelBloc>(
      create: (context) => HotelBloc(getHotelUseCase: getIt<GetHotelUseCase>())
        ..add(
          HotelsFetched(
            page: 0,
            size: 10,
            refresh: true,
            checkinDate: _apiDateFormat.format(_checkinDate!),
            checkoutDate: _apiDateFormat.format(_checkoutDate!),
          ),
        ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: BlocConsumer<HotelBloc, HotelState>(
          listenWhen: (p, c) =>
              p.status != c.status || p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.status == HotelStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                _fetchHotels(context, size: state.size);
              },
              child: CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverAppBar(
                    expandedHeight: 260,
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
                              theme.primaryColor.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ClipRect(
                              child: SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20, top: 60),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Chào mừng bạn,',
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16)),
                                                Text(
                                                  'Khám phá ngay! 👋',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () =>
                                                      _openBookingList(context),
                                                  icon: const Icon(
                                                    Icons.receipt_long,
                                                    color: Colors.white,
                                                  ),
                                                  tooltip: 'Đơn đặt phòng',
                                                ),
                                                GestureDetector(
                                                  onTap: () => context.router
                                                      .push(
                                                          const ProfileRoute()),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2),
                                                    ),
                                                    child: const CircleAvatar(
                                                      radius: 24,
                                                      backgroundImage: NetworkImage(
                                                          'https://i.pravatar.cc/150?img=68'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 10)
                                                  ],
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.search,
                                                        color: Colors.grey),
                                                    SizedBox(width: 10),
                                                    Text('Bạn muốn đi đâu?',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            SizedBox(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _applyFilter(
                                                    context,
                                                    size: state.size),
                                                label: const Text('Lọc'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor:
                                                      theme.primaryColor,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    _pickDate(isCheckin: true),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: InputDecorator(
                                                  decoration: InputDecoration(
                                                    labelText: 'Ngày đến',
                                                    labelStyle: const TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white
                                                        .withValues(
                                                            alpha: 0.15),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.35),
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.white,
                                                        width: 1.6,
                                                      ),
                                                    ),
                                                    prefixIcon: Icon(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.9),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _formatDate(_checkinDate),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    _pickDate(isCheckin: false),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: InputDecorator(
                                                  decoration: InputDecoration(
                                                    labelText: 'Ngày đi',
                                                    labelStyle: const TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white
                                                        .withValues(
                                                            alpha: 0.15),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.35),
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.white,
                                                        width: 1.6,
                                                      ),
                                                    ),
                                                    prefixIcon: Icon(
                                                      Icons.event_outlined,
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.9),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _formatDate(_checkoutDate),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // footer loading / end
                          if (index == state.items.length) {
                            if (state.status == HotelStatus.loading &&
                                state.items.isNotEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            // if (!state.hasMore && state.items.isNotEmpty) {
                            //   return const Padding(
                            //     padding: EdgeInsets.symmetric(vertical: 16),
                            //     child: Center(child: Text('Hết dữ liệu')),
                            //   );
                            // }
                            return const SizedBox.shrink();
                          }

                          final hotel = state.items[index];
                          return _buildHotelCard(context, hotel);
                        },
                        childCount: state.items.length + 1,
                      ),
                    ),
                  ),
                  if (state.items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: state.status == HotelStatus.loading
                              ? const CircularProgressIndicator()
                              : const Text('Chưa có khách sạn'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Hotel hotel) {
    final imageUrl = (hotel.pathImage.isNotEmpty)
        ? '${AppConfig().baseURL}${hotel.pathImage}'
        : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop';

    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child:
                        const Icon(Icons.hotel, size: 50, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          hotel.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hotel.address,
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
                    // Backend chưa có price trong response bạn gửi → hiển thị category/rating hoặc để placeholder
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            hotel.category,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hotel.status.toUpperCase() == 'FULL') ...[
                            const SizedBox(width: 10),
                            const Text(
                              'Het phong',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.router.push(
                          HotelDetailRoute(
                              hotel: hotel,
                              checkinDate: _apiDateFormat.format(_checkinDate!),
                              checkoutDate:
                                  _apiDateFormat.format(_checkoutDate!)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Xem chi tiết'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
