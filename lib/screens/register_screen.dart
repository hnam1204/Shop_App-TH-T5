import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('\u0110\u0103ng k\u00fd th\u00e0nh c\u00f4ng'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('\u0110\u0103ng k\u00fd')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 50,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Register with mock data only.',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              controller: _fullNameController,
                              label: 'H\u1ecd t\u00ean',
                              icon: Icons.badge_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'H\u1ecd t\u00ean kh\u00f4ng \u0111\u01b0\u1ee3c tr\u1ed1ng';
                                }
                                return null;
                              },
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
                              label: 'S\u1ed1 \u0111i\u1ec7n tho\u1ea1i',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'S\u1ed1 \u0111i\u1ec7n tho\u1ea1i kh\u00f4ng \u0111\u01b0\u1ee3c tr\u1ed1ng';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'M\u1eadt kh\u1ea9u',
                              icon: Icons.lock_outline,
                              obscureText: _hidePassword,
                              suffixIcon: IconButton(
                                tooltip: _hidePassword ? 'Show' : 'Hide',
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                final password = value ?? '';
                                if (password.isEmpty) {
                                  return 'M\u1eadt kh\u1ea9u kh\u00f4ng \u0111\u01b0\u1ee3c tr\u1ed1ng';
                                }
                                if (password.length < 6) {
                                  return 'M\u1eadt kh\u1ea9u t\u1ed1i thi\u1ec3u 6 k\u00fd t\u1ef1';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'X\u00e1c nh\u1eadn m\u1eadt kh\u1ea9u',
                              icon: Icons.verified_user_outlined,
                              obscureText: _hideConfirmPassword,
                              textInputAction: TextInputAction.done,
                              suffixIcon: IconButton(
                                tooltip: _hideConfirmPassword ? 'Show' : 'Hide',
                                icon: Icon(
                                  _hideConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _hideConfirmPassword =
                                        !_hideConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui l\u00f2ng x\u00e1c nh\u1eadn m\u1eadt kh\u1ea9u';
                                }
                                if (value != _passwordController.text) {
                                  return 'X\u00e1c nh\u1eadn m\u1eadt kh\u1ea9u kh\u00f4ng kh\u1edbp';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _register,
                                child: const Text('\u0110\u0103ng k\u00fd'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Quay l\u1ea1i \u0110\u0103ng nh\u1eadp',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email kh\u00f4ng \u0111\u01b0\u1ee3c tr\u1ed1ng';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Email kh\u00f4ng \u0111\u00fang \u0111\u1ecbnh d\u1ea1ng';
    }
    return null;
  }
}
