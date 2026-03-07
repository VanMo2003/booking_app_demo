import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/widgets/app_scaffold.dart';
import 'package:booking_app_mobile/core/constants/constant.dart';
import 'package:booking_app_mobile/features/service/domain/entity/service.dart';
import 'package:booking_app_mobile/features/service/presentation/cubit/service_cubit.dart';
import 'package:booking_app_mobile/features/service/domain/usecases/get_services.dart';
import 'package:booking_app_mobile/features/service/domain/usecases/create_service.dart';
import 'package:booking_app_mobile/features/service/domain/usecases/update_service.dart';
import 'package:booking_app_mobile/features/service/domain/usecases/delete_service.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ServiceScreen extends StatefulWidget {
  final int? hotelId;
  const ServiceScreen({super.key, this.hotelId});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  int? _hotelId;
  bool _loadingHotelId = true;

  @override
  void initState() {
    super.initState();
    _initHotelId();
  }

  Future<void> _initHotelId() async {
    int? resolvedId = widget.hotelId;
    if (resolvedId == null) {
      final storage = const FlutterSecureStorage();
      final stored = await storage.read(key: Constants.hotelId);
      resolvedId = int.tryParse(stored ?? '');
    }
    if (!mounted) return;
    setState(() {
      _hotelId = resolvedId;
      _loadingHotelId = false;
    });
  }

  // Định dạng tiền tệ VNĐ
  String _formatPrice(num? price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
        .format(price ?? 0);
  }

  Future<void> _showEditDialog(BuildContext context, ServiceEntity? item,
      {required int hotelId}) async {
    final serviceCubit = context.read<ServiceCubit>();
    final nameCtrl = TextEditingController(text: item?.name);
    final priceCtrl = TextEditingController(text: item?.unitPrice?.toString());
    final descCtrl = TextEditingController(text: item?.description);
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (innerContext) => BlocProvider.value(
        value: serviceCubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(innerContext).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item == null ? 'Thêm dịch vụ mới' : 'Cập nhật dịch vụ',
                    style: Theme.of(innerContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tên dịch vụ',
                      prefixIcon: const Icon(Icons.room_service),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        v?.trim().isEmpty ?? true ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceCtrl,
                    decoration: InputDecoration(
                      labelText: 'Đơn giá',
                      prefixIcon: const Icon(Icons.payments_outlined),
                      suffixText: 'VNĐ',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v?.trim().isEmpty ?? true ? 'Vui lòng nhập giá' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: 'Mô tả dịch vụ',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(innerContext).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final s = ServiceEntity(
                          id: item?.id,
                          name: nameCtrl.text.trim(),
                          unitPrice: int.tryParse(priceCtrl.text) ?? 0,
                          description: descCtrl.text.trim(),
                          hotelId: item?.hotelId ?? hotelId,
                        );

                        if (item == null) {
                          await serviceCubit.add(s);
                        } else {
                          await serviceCubit.edit(s);
                        }

                        if (innerContext.mounted) Navigator.pop(innerContext);
                      },
                      child: const Text('Lưu thông tin',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingHotelId) {
      return const AppScaffold(
          title: "Quản lý dịch vụ",
          body: Center(child: CircularProgressIndicator()));
    }
    if (_hotelId == null) {
      return const AppScaffold(
          title: "Quản lý dịch vụ",
          body: Center(child: Text("Chưa xác định thông tin khách sạn")));
    }
    return BlocProvider(
      create: (context) => ServiceCubit(
        getServices: getIt<GetServices>(),
        createService: getIt<CreateService>(),
        updateService: getIt<UpdateService>(),
        deleteService: getIt<DeleteService>(),
      )..fetch(hotelId: _hotelId!),
      child: Builder(
        // Sử dụng Builder để lấy context nằm dưới BlocProvider
        builder: (newContext) => BlocConsumer<ServiceCubit, ServiceState>(
          listener: (context, state) {
            if (state.status.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
                    backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return AppScaffold(
              title: 'Quản lý dịch vụ',
              body: _buildContent(context, state: state),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (_hotelId == null) return;
                  _showEditDialog(context, null, hotelId: _hotelId!);
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required ServiceState state}) {
    if (state.status.isLoading || state.status.isInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    final items = state.items ?? [];
    if (items.isEmpty) {
      return const Center(
          child: Text('Không có dịch vụ nào',
              style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<ServiceCubit>().fetch(hotelId: _hotelId!),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final it = items[i];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.room_service_outlined,
                        color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.name ?? '-',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(it.description ?? 'Không có mô tả',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(_formatPrice(it.unitPrice),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () => _showEditDialog(context, it,
                        hotelId: it.hotelId ?? _hotelId!),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async => _confirmDelete(context, it),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ServiceEntity it) async {
    final cubit = context.read<ServiceCubit>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa dịch vụ "${it.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true && it.id != null) {
      await cubit.remove(it.id!);
    }
  }
}
