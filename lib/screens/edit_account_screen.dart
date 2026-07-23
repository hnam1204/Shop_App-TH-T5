import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/app_state_widgets.dart';
import '../widgets/custom_text_field.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await LocalStorageService.getCurrentUser();
    if (!mounted) return;

    setState(() {
      _user = user;
      _isLoading = false;
      if (user != null) {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _avatarUrlController.text = user.avatarUrl;
      }
    });
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _user == null) return;

    setState(() {
      _isSaving = true;
    });

    final updatedUser = _user!.copyWith(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim(),
    );

    await LocalStorageService.updateCurrentUser(updatedUser);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cập nhật tài khoản thành công'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: _EditAccountAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        appBar: _EditAccountAppBar(),
        body: EmptyState(
          icon: Icons.person_off_outlined,
          message: 'Chưa có dữ liệu người dùng',
        ),
      );
    }

    return Scaffold(
      appBar: const _EditAccountAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Họ tên',
                  icon: Icons.badge_outlined,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _addressController,
                  label: 'Địa chỉ',
                  icon: Icons.location_on_outlined,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _avatarUrlController,
                  label: 'Avatar URL',
                  icon: Icons.image_outlined,
                  keyboardType: TextInputType.url,
                  validator: (_) => null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Đang lưu...' : 'Lưu thay đổi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Không được để trống';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }
}

class _EditAccountAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _EditAccountAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Chỉnh sửa tài khoản'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
