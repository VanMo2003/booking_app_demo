// features/position/presentation/screens/position_screen.dart
import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/features/position/domain/entity/position.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/get_positions.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/create_position.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/update_position.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/delete_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/position_cubit.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/widgets/app_scaffold.dart';

@RoutePage()
class PositionScreen extends StatelessWidget {
  const PositionScreen({super.key});

  // Thay Dialog bằng BottomSheet
  Future<void> _showEditSheet(BuildContext context, Position? position) async {
    final nameController = TextEditingController(text: position?.name ?? '');
    final descController =
        TextEditingController(text: position?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<PositionCubit>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để đẩy lên khi có bàn phím
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
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
                position == null ? 'Thêm chức vụ mới' : 'Chỉnh sửa chức vụ',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên chức vụ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.badge),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập thông tin' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Chi tiết',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description),
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final pos = Position(
                      id: position?.id,
                      name: nameController.text.trim(),
                      description: descController.text.trim(),
                    );
                    try {
                      if (position == null) {
                        await cubit.addPosition(pos);
                      } else {
                        await cubit.editPosition(pos);
                      }
                      Navigator.of(context).pop();
                    } catch (e) {
                      // Handle error
                    }
                  },
                  child: const Text('Lưu thay đổi',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PositionCubit(
        getPositions: getIt<GetPositions>(),
        createPosition: getIt<CreatePosition>(),
        updatePosition: getIt<UpdatePosition>(),
        deletePosition: getIt<DeletePosition>(),
      )..fetchPositions(),
      child: BlocConsumer<PositionCubit, PositionState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          return AppScaffold(
            title: 'Quản lý Chức vụ',
            body: _buildContent(context, state: state),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showEditSheet(context, null),
              backgroundColor: const Color(0xFF0B84FF),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required PositionState state}) {
    if (state.status.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.positions == null || state.positions!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    final items = state.positions!;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Text(
                (p.name ?? '-').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(p.name ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(p.description ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _showEditSheet(context, p);
                if (value == 'delete') _confirmDelete(context, p);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Sửa')
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: Colors.red))
                    ])),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Position p) async {
    // Logic xóa cũ, giữ nguyên
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa chức vụ này không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true && p.id != null) {
      context.read<PositionCubit>().removePosition(p.id!);
    }
  }
}
