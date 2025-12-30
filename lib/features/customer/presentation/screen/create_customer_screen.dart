import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/request/create_customer_request.dart';
import '../cubit/create_customer_cubit.dart';
import '../../domain/usecases/create_customer_use_case.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_routes.dart';

@RoutePage()
class CreateCustomerScreen extends StatefulWidget {
  final String accountId;

  const CreateCustomerScreen(
      {@PathParam('accountId') required this.accountId, super.key});

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phoneNumber = TextEditingController();
  String _genderValue = 'nam';
  late String _hometownValue;

  @override
  void initState() {
    super.initState();
    _hometownValue = Constants.provinces.first;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => CreateCustomerCubit(getIt<CreateCustomerUseCase>()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const AutoLeadingButton(color: Colors.black87),
          title: const Text(
            'Thông tin cá nhân',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<CreateCustomerCubit, CreateCustomerState>(
          listener: (context, state) {
            if (state.status == CreateCustomerStatus.success) {
              context.router.replace(const CustomerRoute());
            }
            if (state.status == CreateCustomerStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.status == CreateCustomerStatus.loading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Hình minh họa đồng nhất phong cách
                    Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.badge_outlined,
                            size: 50, color: theme.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Hoàn tất hồ sơ',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Text(
                      'Vui lòng cung cấp thông tin chính xác để chúng tôi phục vụ bạn tốt hơn.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // Họ và tên
                    _buildTextField(
                      controller: _fullName,
                      label: 'Họ và tên',
                      icon: Icons.person_pin_outlined,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Vui lòng nhập họ tên'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Số điện thoại
                    _buildTextField(
                      controller: _phoneNumber,
                      label: 'Số điện thoại',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Vui lòng nhập số điện thoại'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _hometownValue,
                      isExpanded: true, // Cho phép text dài không bị tràn
                      menuMaxHeight: 350, // Giới hạn chiều cao danh sách cuộn
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined,
                          color: Colors.grey),
                      decoration: InputDecoration(
                        labelText: 'Quê quán',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      // Tùy chỉnh bo góc cho menu đổ xuống
                      borderRadius: BorderRadius.circular(12),
                      items: Constants.provinces.map((String province) {
                        return DropdownMenuItem<String>(
                          value: province,
                          child: Row(
                            children: [
                              Icon(Icons.map_outlined,
                                  size: 18,
                                  color: theme.primaryColor
                                      .withValues(alpha: 0.6)),
                              const SizedBox(width: 10),
                              Text(province,
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _hometownValue = v!),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Vui lòng chọn quê quán'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Giới tính',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Nam'),
                            value: 'nam',
                            groupValue: _genderValue,
                            onChanged: (v) =>
                                setState(() => _genderValue = v ?? 'nam'),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Nữ'),
                            value: 'nữ',
                            groupValue: _genderValue,
                            onChanged: (v) =>
                                setState(() => _genderValue = v ?? 'nu'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) return;
                                context.read<CreateCustomerCubit>().create(
                                      CreateCustomerRequest(
                                        pathImage: '',
                                        accountId: widget.accountId,
                                        fullName: _fullName.text.trim(),
                                        phoneNumber: _phoneNumber.text.trim(),
                                        gender: _genderValue,
                                        hometown: _hometownValue,
                                      ),
                                    );
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'HOÀN TẤT',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      validator: validator,
    );
  }
}
