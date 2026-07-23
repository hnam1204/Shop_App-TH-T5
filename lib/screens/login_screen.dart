import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/custom_text_field.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _rememberMe = false;
  bool _isLoadingSavedData = true;
  bool _isLoggingIn = false;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _loadSavedLoginData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLoginData() async {
    final rememberLogin = await LocalStorageService.loadRememberLogin();

    if (!mounted) return;
    setState(() {
      _rememberMe = rememberLogin.rememberMe;
      if (rememberLogin.rememberMe) {
        _emailController.text = rememberLogin.email;
      }
      _isLoadingSavedData = false;
    });
  }

  Future<void> _login() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    try {
      final credential = await _authService.loginUser(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      final userData = firebaseUser == null
          ? null
          : await _authService.getUserData(firebaseUser.uid);

      final currentUser = UserModel(
        id: firebaseUser?.uid ?? '',
        fullName:
            userData?['fullName']?.toString() ??
            firebaseUser?.displayName ??
            'User',
        email: userData?['email']?.toString() ?? email,
        password: '',
        phone: userData?['phone']?.toString() ?? '',
      );

      await LocalStorageService.saveCurrentUser(currentUser);
      await LocalStorageService.saveLoginStatus(true);
      await LocalStorageService.addLoginHistory(email);

      if (_rememberMe) {
        await LocalStorageService.saveRememberLogin(email, '', true);
      } else {
        await LocalStorageService.clearRememberLogin();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
      return;
    } on FirebaseAuthException catch (error) {
      _showLoginError(_firebaseLoginMessage(error.code));
    } catch (_) {
      _showLoginError('Đăng nhập thất bại. Vui lòng thử lại.');
    }
  }

  void _showLoginError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoggingIn = false;
      _loginError = message;
    });
  }

  Future<void> _forgotPassword() async {
    final emailError = _validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _loginError = 'Nhập email hợp lệ để đặt lại mật khẩu.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(
        () => _loginError =
            'Đã gửi hướng dẫn đặt lại mật khẩu đến email của bạn.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _loginError = _firebaseLoginMessage(error.code));
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoadingSavedData) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            color: colorScheme.onPrimary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(
                                  alpha: 0.07,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chào mừng trở lại',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Đăng nhập để tiếp tục mua sắm.',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                CustomTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [
                                    AutofillHints.username,
                                    AutofillHints.email,
                                  ],
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Mật khẩu',
                                  icon: Icons.lock_outline,
                                  obscureText: _hidePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _login(),
                                  suffixIcon: IconButton(
                                    tooltip: _hidePassword ? 'Hiện' : 'Ẩn',
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
                                    if (value == null || value.isEmpty) {
                                      return 'Mật khẩu không được trống';
                                    }
                                    return null;
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _forgotPassword,
                                    child: const Text('Quên mật khẩu?'),
                                  ),
                                ),
                                if (_loginError != null)
                                  Semantics(
                                    liveRegion: true,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _loginError!,
                                        style: TextStyle(
                                          color: colorScheme.onErrorContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  title: Text(
                                    'Ghi nhớ đăng nhập',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isLoggingIn ? null : _login,
                                    child: _isLoggingIn
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: colorScheme.onPrimary,
                                            ),
                                          )
                                        : const Text('Đăng nhập'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Chưa có tài khoản?',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _openRegister,
                                      child: const Text(
                                        'Đăng ký tài khoản',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
      return 'Email không được trống';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  String _firebaseLoginMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email không đúng định dạng';
      case 'user-disabled':
        return 'Tài khoản này đã bị khóa';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      case 'network-request-failed':
        return 'Không có kết nối mạng';
      default:
        return 'Đăng nhập thất bại. Vui lòng thử lại';
    }
  }
}
