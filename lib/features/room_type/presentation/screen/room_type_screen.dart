import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/widgets/app_scaffold.dart';
import 'package:booking_app_mobile/features/room_type/domain/entity/room_type.dart';
import 'package:booking_app_mobile/features/room_type/presentation/cubit/room_type_cubit.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/get_room_types.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/create_room_type.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/update_room_type.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/delete_room_type.dart';

@RoutePage()
class RoomTypeScreen extends StatelessWidget {
  const RoomTypeScreen({super.key});

  Future<void> _showEditDialog(BuildContext context, RoomType? item) async {
    final nameCtrl = TextEditingController(text: item?.name);
    final descCtrl = TextEditingController(text: item?.description);
    final formKey = GlobalKey<FormState>();

    final cubit = context.read<RoomTypeCubit>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item == null ? 'Thêm loại phòng' : 'Cập nhật loại phòng',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Tên loại phòng (VD: Deluxe, Standard)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true
                      ? 'Vui lòng nhập tên loại phòng'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final rt = RoomType(
                        id: item?.id,
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                      );

                      try {
                        if (item == null) {
                          await cubit.add(rt);
                        } else {
                          await cubit.edit(rt);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    item == null ? 'Đã thêm' : 'Đã cập nhật')),
                          );
                        }
                      } catch (e) {
                        // Error handled by BlocListener
                      }
                    },
                    child: const Text('Lưu', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomTypeCubit(
        getRoomTypes: getIt<GetRoomTypes>(),
        createRoomType: getIt<CreateRoomType>(),
        updateRoomType: getIt<UpdateRoomType>(),
        deleteRoomType: getIt<DeleteRoomType>(),
      )..fetch(), // Fetch all room types
      child: BlocConsumer<RoomTypeCubit, RoomTypeState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ?? 'Error'),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return AppScaffold(
            title: 'Quản lý loại phòng',
            body: _buildList(context, state),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showEditDialog(context, null),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, RoomTypeState state) {
    if (state.status.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = state.items ??
        []; // Assuming usecase returns List<RoomType> directly or in a wrapper

    if (list.isEmpty) {
      return const Center(child: Text('Chưa có loại phòng nào'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RoomTypeCubit>().fetch();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = list[index];
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Text(
                  (item.name ?? 'R').substring(0, 1).toUpperCase(),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                item.name ?? 'No Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: item.description != null && item.description!.isNotEmpty
                  ? Text(item.description!,
                      maxLines: 1, overflow: TextOverflow.ellipsis)
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(context, item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa loại phòng?'),
                          content: const Text(
                              'Lưu ý: Các phòng thuộc loại này có thể bị ảnh hưởng.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && item.id != null) {
                        if (context.mounted) {
                          context.read<RoomTypeCubit>().remove(item.id!);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
