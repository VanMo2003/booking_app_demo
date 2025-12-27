import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/service/domain/entity/service.dart';
import 'package:booking_app_mobile/features/service/presentation/cubit/service_cubit.dart';
import 'package:booking_app_mobile/features/service/domain/usecases/get_services.dart';
import 'package:booking_app_mobile/features/service/domain/usecases/create_service.dart';
import 'package:booking_app_mobile/features/service/domain/usecases/update_service.dart';
import 'package:booking_app_mobile/features/service/domain/usecases/delete_service.dart';

@RoutePage()
class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  Future<void> _showEditDialog(BuildContext context, ServiceEntity? item,
      {required int hotelId}) async {
    final nameCtrl = TextEditingController(text: item?.name);
    final priceCtrl = TextEditingController(text: item?.unitPrice?.toString());
    final descCtrl = TextEditingController(text: item?.description);

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Thêm dịch vụ' : 'Chỉnh sửa dịch vụ'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Giá'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  minLines: 1,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final cubit = context.read<ServiceCubit>();
                final s = ServiceEntity(
                  id: item?.id,
                  name: nameCtrl.text,
                  unitPrice: int.tryParse(priceCtrl.text) ?? 0,
                  description: descCtrl.text,
                  hotelId: item?.hotelId ?? hotelId,
                );

                try {
                  if (item == null) {
                    await cubit.add(s);
                  } else {
                    await cubit.edit(s);
                  }
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(item == null
                          ? 'Thêm dịch vụ thành công'
                          : 'Cập nhật dịch vụ')));
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceCubit(
        getServices: getIt<GetServices>(),
        createService: getIt<CreateService>(),
        updateService: getIt<UpdateService>(),
        deleteService: getIt<DeleteService>(),
      )..fetch(hotelId: 1),
      child: Scaffold(
        appBar: AppBar(title: const Text('Service')),
        body: BlocConsumer<ServiceCubit, ServiceState>(
          listener: (context, state) {
            if (state.status.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.errorMessage ?? 'Có lỗi xảy ra')));
            }
          },
          builder: (context, state) {
            if (state.status.isLoading || state.status.isInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status.isFailure) {
              return Center(child: Text(state.errorMessage ?? 'Error'));
            }
            if (state.status.isSuccess) {
              final items = state.items ?? [];
              if (items.isEmpty)
                return const Center(child: Text('Không có dịch vụ nào'));
              return Column(
                children: [
                  FloatingActionButton(
                    onPressed: () => _showEditDialog(context, null, hotelId: 1),
                    child: const Icon(Icons.add),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (ctx, i) {
                        final it = items[i];
                        return ListTile(
                          title: Text(it.name ?? '-'),
                          subtitle: Text(
                              '${it.description ?? ''} • ${it.unitPrice ?? 0}'),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, it,
                                    hotelId: it.hotelId ?? 1)),
                            IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final cubit = context.read<ServiceCubit>();
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: const Text(
                                          'Bạn có chắc chắn muốn xóa dịch vụ này không?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Hủy')),
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Xác nhận')),
                                      ],
                                    ),
                                  );
                                  try {
                                    await cubit.remove(it.id!);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Xóa thành công')));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')));
                                  }
                                }),
                          ]),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
