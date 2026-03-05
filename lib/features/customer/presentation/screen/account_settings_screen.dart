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
        const SnackBar(content: Text('Khong tim thay customerId. Vui long dang nhap lai.')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiet lap tai khoan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Ho va ten',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui long nhap ho va ten';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'So dien thoai',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Vui long nhap so dien thoai';
                  if (!RegExp(r'^[0-9]{9,11}$').hasMatch(v)) {
                    return 'So dien thoai khong hop le';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gioi tinh',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'nam', child: Text('Nam')),
                  DropdownMenuItem(value: 'nu', child: Text('Nu')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _gender = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hometownController,
                decoration: const InputDecoration(
                  labelText: 'Que quan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui long nhap que quan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Luu thay doi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
