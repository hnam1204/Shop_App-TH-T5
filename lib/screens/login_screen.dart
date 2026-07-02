import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/custom_text_field.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String demoEmail = 'hnam12042006@gmail.com';
  static const String demoPassword = 'hainam@@';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _rememberMe = false;
  bool _isLoadingSavedData = true;
  bool _isLoggingIn = false;

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
        _passwordController.text = rememberLogin.password;
      }
      _isLoadingSavedData = false;
    });
  }

  Future<void> _login() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email == LoginScreen.demoEmail &&
        password == LoginScreen.demoPassword) {
      setState(() {
        _isLoggingIn = true;
      });

      try {
        final currentUser =
            (await LocalStorageService.getCurrentUser()) ??
            UserModel(
              id: 'demo-user',
              fullName: 'Nguyen Hai Nam',
              email: email,
              password: password,
              phone: '037 905 2767',
              address: 'Ho Chi Minh City',
            );

        final updatedUser = currentUser.copyWith(
          email: email,
          password: password,
        );

        await LocalStorageService.saveCurrentUser(updatedUser);
        await LocalStorageService.saveLoginStatus(true);
        await LocalStorageService.addLoginHistory(email);

        if (_rememberMe) {
          await LocalStorageService.saveRememberLogin(email, password, true);
        } else {
          await LocalStorageService.clearRememberLogin();
        }
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _isLoggingIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Email ho\u1eb7c m\u1eadt kh\u1ea9u kh\u00f4ng \u0111\u00fang',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.26,
                                ),
                                blurRadius: 22,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            color: colorScheme.onPrimary,
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(
                                  alpha: 0.08,
                                ),
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
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Sign in to continue shopping.',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                CustomTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: 14),
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  obscureText: _hidePassword,
                                  textInputAction: TextInputAction.done,
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
                                    if (value == null || value.isEmpty) {
                                      return 'M\u1eadt kh\u1ea9u kh\u00f4ng \u0111\u01b0\u1ee3c tr\u1ed1ng';
                                    }
                                    return null;
                                  },
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
                                    'Remember Me',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoggingIn ? null : _login,
                                    child: _isLoggingIn
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                            ),
                                          )
                                        : const Text(
                                            '\u0110\u0103ng nh\u1eadp',
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Ch\u01b0a c\u00f3 t\u00e0i kho\u1ea3n?',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _openRegister,
                                      child: const Text(
                                        '\u0110\u0103ng k\u00fd t\u00e0i kho\u1ea3n',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
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
      return 'Email kh\u00f4ng \u0111\u01b0\u1ee3c tr\u1ed1ng';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Email kh\u00f4ng \u0111\u00fang \u0111\u1ecbnh d\u1ea1ng';
    }
    return null;
  }
}
