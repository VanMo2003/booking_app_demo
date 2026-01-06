import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/constants/constant.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/widgets/app_scaffold.dart';
import 'package:booking_app_mobile/features/employee/data/models/request/employee_create_request.dart';
import 'package:booking_app_mobile/features/employee/data/models/request/employee_update_request.dart';
import 'package:booking_app_mobile/features/employee/domain/entities/employee.dart';
import 'package:booking_app_mobile/features/employee/presentation/cubit/employee_cubit.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/get_positions.dart';
import 'package:booking_app_mobile/features/position/presentation/cubit/position_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:booking_app_mobile/features/position/domain/usecases/create_position.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/update_position.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/delete_position.dart';

import '../../../employee/domain/use_case/create_employee.dart';
import '../../../employee/domain/use_case/delete_employee.dart';
import '../../../employee/domain/use_case/get_employee_by_hotel.dart';
import '../../../employee/domain/use_case/update_employee.dart';

@RoutePage()
class StaffAdminScreen extends StatefulWidget {
  const StaffAdminScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  State<StaffAdminScreen> createState() => _StaffAdminScreenState();
}

class _StaffAdminScreenState extends State<StaffAdminScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.primaryColor;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EmployeeCubit(
            getEmployeeByHotel: getIt<GetEmployeeByHotel>(),
            createEmployee: getIt<CreateEmployee>(),
            updateEmployee: getIt<UpdateEmployee>(),
            deleteEmployee: getIt<DeleteEmployee>(),
          )..fetchEmployees(hotelId: widget.hotelId),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => PositionCubit(
            getPositions: getIt<GetPositions>(),
            createPosition: getIt<CreatePosition>(),
            updatePosition: getIt<UpdatePosition>(),
            deletePosition: getIt<DeletePosition>(),
          )..fetchPositions(),
        ),
      ],
      child: BlocConsumer<EmployeeCubit, EmployeeState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          return AppScaffold(
            title: 'Quản lý Nhân viên',
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showEmployeeForm(context),
              backgroundColor: primaryBlue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: _buildContent(context, state, primaryBlue),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, EmployeeState state, Color primaryBlue) {
    if (state.status == EmployeeStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final employees = state.employees;
    if (employees == null || employees.isEmpty) {
      return const Center(child: Text('Chưa có nhân viên nào.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: employees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildEmployeeCard(context, employees[index], primaryBlue),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employee emp, Color primaryBlue) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryBlue.withOpacity(0.1),
          child: Icon(Icons.person, color: primaryBlue),
        ),
        title: Text(emp.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${emp.positionName} - ${emp.hometown}'),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') _showEmployeeForm(context, employee: emp);
            if (val == 'delete') _confirmDelete(context, emp);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Sửa')),
            const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  // --- Form Logic ---
  Future<void> _showEmployeeForm(BuildContext context, {Employee? employee}) async {
    final isEdit = employee != null;
    final empCubit = context.read<EmployeeCubit>();
    final posCubit = context.read<PositionCubit>();
    final primaryColor = Theme.of(context).primaryColor;

    final fullNameCtrl = TextEditingController(text: employee?.fullName);
    final phoneCtrl = TextEditingController(text: employee?.phoneNumber);
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final salaryCtrl = TextEditingController(text: employee?.salary.toString());
    final dobCtrl = TextEditingController(text: employee?.dateOfBirth ?? '2025-01-01');

    int? selectedPosId;
    if (isEdit) {
      selectedPosId = posCubit.state.positions
          ?.firstWhere((p) => p.name == employee.positionName, orElse: () => posCubit.state.positions!.first)
          .id;
    } else {
      selectedPosId = posCubit.state.positions?.firstOrNull?.id;
    }
    String _genderValue = 'nam';

    String? selectedHometown =
        Constants.provinces.contains(employee?.hometown) ? employee?.hometown : Constants.provinces.first;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Cập nhật nhân viên' : 'Thêm nhân viên mới',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // Position Dropdown
                DropdownButtonFormField<int>(
                  value: selectedPosId,
                  decoration: _inputDecoration('Chức vụ', Icons.work_outline),
                  items: posCubit.state.positions
                      ?.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name ?? '')))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedPosId = val),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedHometown,
                  decoration: _inputDecoration('Quê quán', Icons.location_on_outlined),
                  items: Constants.provinces.map((String province) {
                    return DropdownMenuItem<String>(
                      value: province,
                      child: Text(province),
                    );
                  }).toList(),
                  onChanged: (val) => setModalState(() => selectedHometown = val),
                ),
                const SizedBox(height: 16),
                if (!isEdit) ...[
                  _buildField(userCtrl, 'Tên đăng nhập', Icons.account_circle_outlined),
                  const SizedBox(height: 16),
                  _buildField(passCtrl, 'Mật khẩu', Icons.lock_outline, isPass: true),
                  const SizedBox(height: 16),
                ],

                _buildField(fullNameCtrl, 'Họ và tên', Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildField(phoneCtrl, 'Số điện thoại', Icons.phone_android, isNum: true),
                const SizedBox(height: 16),
                _buildField(salaryCtrl, 'Lương cơ bản', Icons.payments_outlined, isNum: true),
                const SizedBox(height: 16),
                _buildField(dobCtrl, 'Ngày sinh (yyyy-MM-dd)', Icons.cake_outlined),
                const SizedBox(height: 16),
                const Text('Giới tính', style: TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Nam'),
                        value: 'nam',
                        groupValue: _genderValue,
                        onChanged: (v) => setModalState(() => _genderValue = v ?? 'nam'),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Nữ'),
                        value: 'nữ',
                        groupValue: _genderValue,
                        onChanged: (v) => setModalState(() => _genderValue = v ?? 'nu'),
                      ),
                    ),
                  ],
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
                      final hometownValue = selectedHometown ?? "";
                      if (isEdit) {
                        empCubit.editEmployee(
                          employee.id,
                          EmployeeUpdateRequest(
                            pathImage: employee.pathImage,
                            fullName: fullNameCtrl.text,
                            phoneNumber: phoneCtrl.text,
                            gender: _genderValue,
                            dateOfBirth: dobCtrl.text,
                            hometown: hometownValue,
                            salary: int.tryParse(salaryCtrl.text) ?? 0,
                            positionId: selectedPosId ?? 0,
                          ),
                        );
                      } else {
                        empCubit.addEmployee(
                          EmployeeCreateRequest(
                            pathImage: "",
                            username: userCtrl.text,
                            password: passCtrl.text,
                            hotelId: widget.hotelId,
                            fullName: fullNameCtrl.text,
                            phoneNumber: phoneCtrl.text,
                            gender: _genderValue,
                            dateOfBirth: dobCtrl.text,
                            hometown: hometownValue,
                            salary: int.tryParse(salaryCtrl.text) ?? 0,
                            positionId: selectedPosId ?? 0,
                          ),
                        );
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
    );
  }

  // --- Helpers ---
  void _confirmDelete(BuildContext context, Employee emp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Xóa nhân viên ${emp.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              context.read<EmployeeCubit>().removeEmployee(emp.id);
              Navigator.pop(ctx);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {bool isPass = false, bool isNum = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label, icon),
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
