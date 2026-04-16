import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController(text: '9999999998');
  final _passwordController = TextEditingController(text: '1234');
  final _otpController = TextEditingController(text: '1111');
  String _type = 'user';
  String _loginMethod = 'password';
  bool _otpRequested = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = context.read<AppState>();
    bool success = false;

    if (_loginMethod == 'password') {
      success = await state.login(
        mobile: _mobileController.text.trim(),
        password: _passwordController.text.trim(),
        type: _type,
      );
    } else if (!_otpRequested) {
      setState(() {
        _otpRequested = true;
      });
      success = await state.requestLoginOtp(
        mobile: _mobileController.text.trim(),
        type: _type,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'OTP sent successfully'
                : (state.authError ?? 'Failed to send OTP'),
          ),
        ),
      );
      return;
    } else {
      if ((state.pendingOtpUserId ?? '').trim().isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missing OTP session. Please tap resend first.'),
          ),
        );
        return;
      }
      success = await state.verifyLoginOtp(
        otp: _otpController.text.trim(),
        type: _type,
      );
    }

    if (!mounted) {
      return;
    }

    if (success) {
      final successMessage = _loginMethod == 'password'
          ? 'Login successful'
          : 'OTP verified. Login successful';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(state.authError ?? 'Login failed')));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFECEC), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.lock_person_rounded,
                          color: Colors.red,
                          size: 44,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _loginMethod == 'password'
                              ? 'Sign in with mobile, password and account type'
                              : 'Sign in with mobile OTP and account type',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLoginMethodSelector(),
                        const SizedBox(height: 14),
                        _buildTypeSelector(),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _inputDecoration(
                            'Mobile Number',
                            Icons.phone_android_rounded,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter mobile'
                              : null,
                        ),
                        if (_loginMethod == 'password') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration(
                              'Password',
                              Icons.key_rounded,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter password'
                                : null,
                          ),
                        ],
                        if (_loginMethod == 'otp' && _otpRequested) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration(
                              'OTP',
                              Icons.password_rounded,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter OTP'
                                : null,
                          ),
                          if ((state.pendingOtpUserId ?? '').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'user_id: ${state.pendingOtpUserId}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: state.isAuthLoading ? null : _submit,
                          child: state.isAuthLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _loginMethod == 'password'
                                      ? 'Login'
                                      : (_otpRequested
                                            ? 'Verify OTP'
                                            : 'Send OTP'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                        if (_loginMethod == 'otp' && _otpRequested) ...[
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: state.isAuthLoading
                                ? null
                                : () {
                                    setState(() {
                                      _otpRequested = false;
                                      _otpController.clear();
                                    });
                                  },
                            child: const Text('Change number / resend'),
                          ),
                        ],
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: state.isAuthLoading
                              ? null
                              : () => Navigator.pushNamed(context, '/register'),
                          child: const Text('New here? Create account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _typeChip('user')),
          const SizedBox(width: 8),
          Expanded(child: _typeChip('business')),
        ],
      ),
    );
  }

  Widget _buildLoginMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _methodChip('password', 'Password')),
          const SizedBox(width: 8),
          Expanded(child: _methodChip('otp', 'OTP')),
        ],
      ),
    );
  }

  Widget _methodChip(String value, String label) {
    final selected = _loginMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _loginMethod = value;
          _otpRequested = false;
          _otpController.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String value) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF374151)),
      prefixIcon: Icon(icon, color: Colors.red.shade300),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
    );
  }
}
