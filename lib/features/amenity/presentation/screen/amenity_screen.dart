import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/create_amenity.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/delete_amenity.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/get_by_hotel.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/get_by_room.dart';
import 'package:booking_app_mobile/features/amenity/domain/use_case/update_amenity.dart';
import 'package:booking_app_mobile/features/amenity/presentation/cubit/amenity_bloc.dart';
import 'package:booking_app_mobile/features/amenity/presentation/cubit/amenity_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/widgets/app_scaffold.dart';

import 'package:booking_app_mobile/features/amenity/data/models/request/amenity_create_request.dart';
import 'package:booking_app_mobile/features/amenity/data/models/request/amenity_update_request.dart';

import '../../domain/entity/amenity.dart';
import '../cubit/amenity_state.dart';

@RoutePage()
class AmenityScreen extends StatelessWidget {
  const AmenityScreen({super.key, this.hotelId = 1, this.roomId});

  final int hotelId;
  final int? roomId; // Nếu có roomId thì đây là quản lý tiện ích riêng của phòng

  Future<void> _showEditSheet(BuildContext context, Amenity? amenity) async {
    final isEdit = amenity != null;
    final nameController = TextEditingController(text: amenity?.name ?? '');
    final descController = TextEditingController(text: amenity?.description ?? '');

    bool isCommon = amenity?.common ?? true;

    final formKey = GlobalKey<FormState>();
    final bloc = context.read<AmenityBloc>();
    final primaryColor = Theme.of(context).primaryColor;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Text(isEdit ? 'Cập nhật tiện ích' : 'Thêm tiện ích mới',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: nameController,
                    // decoration: _inputDecoration('Tên tiện ích', Icons.benevolence),
                    decoration: _inputDecoration('Tên tiện ích', Icons.eighteen_mp),
                    validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: descController,
                    decoration: _inputDecoration('Mô tả', Icons.description_outlined),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Switch chọn loại tiện ích (Chung hoặc Riêng)
                  SwitchListTile(
                    title: const Text('Tiện ích chung (Khách sạn)'),
                    subtitle: Text(isCommon ? 'Mọi phòng đều có' : 'Chỉ dành cho thực thể cụ thể'),
                    value: isCommon,
                    activeColor: primaryColor,
                    onChanged: (val) => setModalState(() => isCommon = val),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        if (isEdit) {
                          bloc.add(AmenityUpdated(
                              id: amenity.id,
                              request: AmenityUpdateRequest(
                                name: nameController.text.trim(),
                                description: descController.text.trim(),
                                common: isCommon,
                              )));
                        } else {
                          bloc.add(AmenityCreated(
                            AmenityCreateRequest(
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                              common: isCommon,
                              hotelId: hotelId,
                              roomId: isCommon ? null : roomId, // Gửi roomId nếu không phải tiện ích chung
                            ),
                          ));
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Xác nhận', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    final primaryColor = Theme.of(context).primaryColor;

    return BlocProvider(
      create: (context) => AmenityBloc(
          createAmenity: getIt<CreateAmenity>(),
          deleteAmenity: getIt<DeleteAmenity>(),
          updateAmenity: getIt<UpdateAmenity>(),
          getAmenityByRoom: getIt<GetAmenityByRoom>(),
          getAmenityByHotel: getIt<GetAmenityByHotel>())
        ..add(AmenitiesByHotelFetched(hotelId)), // Bạn có thể truyền hotelId vào đây nếu API yêu cầu lọc
      child: BlocConsumer<AmenityBloc, AmenityState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          return AppScaffold(
            title: 'Quản lý Tiện ích',
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showEditSheet(context, null),
              backgroundColor: primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: _buildContent(context, state, primaryColor),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AmenityState state, Color primaryColor) {
    if (state.status == AmenityStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = state.items;
    if (items == null || items.isEmpty) {
      return const Center(child: Text('Chưa có tiện ích nào.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: item.common ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              child: Icon(
                item.common ? Icons.hotel : Icons.meeting_room,
                color: item.common ? Colors.orange : Colors.blue,
              ),
            ),
            title: Text(item.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.active ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.active ? 'Đang hoạt động' : 'Ngưng',
                    style: TextStyle(fontSize: 11, color: item.active ? Colors.green : Colors.grey),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') _showEditSheet(context, item);
                if (val == 'delete') _confirmDelete(context, item);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Amenity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận'),
        content: Text('Bạn muốn xóa tiện ích ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AmenityBloc>().add(AmenityDeleted(item.id));
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 22),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
