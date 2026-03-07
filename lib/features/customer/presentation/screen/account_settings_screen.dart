import 'package:booking_app_mobile/core/constants/constant.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/auth/domain/entity/auth.dart';
import 'package:booking_app_mobile/features/auth/data/models/response/customer_response.dart';
import 'package:booking_app_mobile/features/customer/data/models/request/update_customer_request.dart';
import 'package:booking_app_mobile/features/customer/domain/repositories/customer_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hometownController = TextEditingController();

  String _gender = 'nam';
  bool _isSaving = false;
  bool _isLoadingProfile = true;
  int? _customerId;

  // Helper để tạo InputDecoration đồng bộ
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  Future<void> _initForm() async {
    final storage = getIt<FlutterSecureStorage>();
    final rawId = await storage.read(key: Constants.customerId);
    final id = int.tryParse(rawId ?? '');

    if (id == null) {
      if (!mounted) return;
      setState(() {
        _customerId = null;
        _isLoadingProfile = false;
      });
      return;
    }

    try {
      final customer = await getIt<CustomerRepository>().getCustomerById(id);
      final current = Auth.current;
      if (current != null) {
        current.customer = customer;
      }

      if (!mounted) return;
      setState(() {
        _customerId = id;
        _fullNameController.text = customer.fullName ?? '';
        _phoneController.text = customer.phoneNumber ?? '';
        _hometownController.text = customer.hometown ?? '';
        _gender = _normalizeGender(customer.gender);
      });
    } catch (_) {
      final fallback = Auth.current?.customer;
      if (!mounted) return;
      setState(() {
        _customerId = id;
        _fullNameController.text = fallback?.fullName ?? '';
        _phoneController.text = fallback?.phoneNumber ?? '';
        _hometownController.text = fallback?.hometown ?? '';
        _gender = _normalizeGender(fallback?.gender);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  String _normalizeGender(String? gender) {
    if (gender == 'nu' || gender == 'n?') return 'nu';
    return 'nam';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final id = _customerId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Khong tim thay customerId. Vui long dang nhap lai.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final request = UpdateCustomerRequest(
        pathImage: Auth.current?.customer?.pathImage ?? '',
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _gender,
        hometown: _hometownController.text.trim(),
      );

      final updated =
          await getIt<CustomerRepository>().updateCustomer(id, request);

      final current = Auth.current;
      if (current != null) {
        current.customer = CustomerResponse(
          id: updated.id,
          pathImage: updated.pathImage,
          accountId: updated.accountId,
          username: updated.username,
          fullName: updated.fullName,
          phoneNumber: updated.phoneNumber,
          gender: updated.gender,
          hometown: updated.hometown,
          onCreate: updated.onCreate,
          onUpdate: updated.onUpdate,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cap nhat thong tin thanh cong')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cap nhat that bai: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _hometownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: theme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Thiết lập tài khoản',
                  style: TextStyle(color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withValues(alpha: 0.8)
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _fullNameController,
                        decoration: _inputDecoration('Họ và tên'),
                        validator: (v) => (v?.trim().isEmpty ?? true)
                            ? 'Vui lòng nhập họ tên'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration('Số điện thoại'),
                        validator: (v) =>
                            !RegExp(r'^[0-9]{9,11}$').hasMatch(v ?? '')
                                ? 'Số điện thoại không hợp lệ'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: _inputDecoration('Giới tính'),
                        items: const [
                          DropdownMenuItem(value: 'nam', child: Text('Nam')),
                          DropdownMenuItem(value: 'nu', child: Text('Nữ')),
                        ],
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hometownController,
                        decoration: _inputDecoration('Quê quán'),
                        validator: (v) => (v?.trim().isEmpty ?? true)
                            ? 'Vui lòng nhập quê quán'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : const Text('Lưu thay đổi',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
