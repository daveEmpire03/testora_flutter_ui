import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_providers.dart';

const _yellow = AppColors.warning;

// ONBOARDING

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.magenta.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 92,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 38),
            const Text(
              'Learn Smarter.\nScore Higher.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                height: 1.15,
                fontWeight: FontWeight.w900,
                letterSpacing: -.8,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Practice past questions, take realistic mock exams '
              'and understand your performance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const Spacer(),
            GradientButton(
              label: 'Get Started',
              onTap: () => context.go('/register'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text(
                'I already have an account',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LOGIN
// =============================================================================

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _rememberMe = false;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final ok = await ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!ok) {
      final err = ref.read(authProvider).error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err ?? 'Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 52, 24, 40),
          child: Column(
            children: [
              const TestoraLogo(size: 78),
              const SizedBox(height: 22),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Sign in to continue learning.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 32),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your account details below.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 22),
                    _AuthField(
                      controller: _emailController,
                      hint: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final e = v?.trim() ?? '';
                        if (e.isEmpty) return 'Enter your email address';
                        if (!e.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _AuthField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_passwordVisible,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      suffix: IconButton(
                        onPressed:
                            () => setState(
                              () => _passwordVisible = !_passwordVisible,
                            ),
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          side: const BorderSide(color: Colors.white70),
                          checkColor: Colors.black,
                          activeColor: _yellow,
                          onChanged:
                              (v) => setState(() => _rememberMe = v ?? false),
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/forgot'),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: _yellow,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      label: 'Login',
                      isLoading: _submitting,
                      onTap: _login,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text(
                          "Don't have an account? Create Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REGISTER
// =============================================================================

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phoneNum = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _pwdVis = false;
  bool _confirmVis = false;
  bool _terms = false;
  bool _submitting = false;

  @override
  void dispose() {
    _fullName.dispose();
    _phoneNum.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_terms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Service.')),
      );
      return;
    }

    setState(() => _submitting = true);

    final ok = await ref
        .read(authProvider.notifier)
        .register(
          fullName: _fullName.text.trim(),
          email: _email.text.trim(),
          phone: _phoneNum.text.trim(),
          password: _password.text,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!ok) {
      final err = ref.read(authProvider).error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err ?? 'Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          child: Column(
            children: [
              const TestoraLogo(size: 68),
              const SizedBox(height: 18),
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join Testora and start preparing smarter.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  children: [
                    _AuthField(
                      controller: _fullName,
                      hint: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Enter your first name'
                                  : null,
                    ),

                    const SizedBox(height: 14),
                    _AuthField(
                      controller: _phoneNum,
                      hint: 'WhatsApp Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter your phone number';
                        }
                        if (v.trim().length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _AuthField(
                      controller: _email,
                      hint: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final e = v?.trim() ?? '';
                        if (e.isEmpty) return 'Enter your email address';
                        if (!e.contains('@') || !e.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _AuthField(
                      controller: _password,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_pwdVis,
                      textInputAction: TextInputAction.next,
                      suffix: IconButton(
                        onPressed: () => setState(() => _pwdVis = !_pwdVis),
                        icon: Icon(
                          _pwdVis
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _AuthField(
                      controller: _confirm,
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_confirmVis,
                      textInputAction: TextInputAction.done,
                      suffix: IconButton(
                        onPressed:
                            () => setState(() => _confirmVis = !_confirmVis),
                        icon: Icon(
                          _confirmVis
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirm your password';
                        }
                        if (v != _password.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _terms,
                          side: const BorderSide(color: Colors.white70),
                          checkColor: Colors.black,
                          activeColor: _yellow,
                          onChanged: (v) => setState(() => _terms = v ?? false),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 11),
                            child: Text(
                              'I agree to the Terms of Service and '
                              'Privacy Policy.',
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.4,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      label: 'Create Account',
                      isLoading: _submitting,
                      onTap: _register,
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'Already have an account? Sign In',
                        style: TextStyle(
                          color: _yellow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FORGOT PASSWORD
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset instructions have been sent.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Forgot Password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter the email address linked to your Testora account '
                "and we'll send you instructions to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              GlassCard(
                child: Column(
                  children: [
                    _AuthField(
                      controller: _email,
                      hint: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _sendResetLink(),
                      validator: (v) {
                        final e = v?.trim() ?? '';
                        if (e.isEmpty) return 'Enter your email address';
                        if (!e.contains('@') || !e.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      label: 'Send Reset Link',
                      onTap: _sendResetLink,
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: _yellow,
                        size: 18,
                      ),
                      label: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: _yellow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED AUTH FIELD
// =============================================================================

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      autocorrect: false,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffix,
        fillColor: Colors.white.withValues(alpha: 0.10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorStyle: const TextStyle(
          color: _yellow,
          fontWeight: FontWeight.w500,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _yellow.withValues(alpha: 0.6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _yellow, width: 1.5),
        ),
      ),
    );
  }
}
