import 'package:flutter/material.dart';
import 'package:qoucher/features/auth/presentation/controllers/auth_controller.dart';
import 'package:qoucher/router/app_router.dart';
import 'package:qoucher/router/route_names.dart';

class RegisterForm extends StatefulWidget {
  final AuthController controller;

  const RegisterForm({
    super.key,
    required this.controller,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _gender = 'M';

  static const Color _lightGreen = Color(0xFFD9F2D0);
  static const Color _darkGreen = Color(0xFF244D2C);
  static const Color _midGreen = Color(0xFF8BCF95);
  static const Color _fieldBg = Color(0xFFF9FDF8);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerListener);
    widget.controller.setMerchant(false);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    _firstNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _controllerListener() {
    if (!mounted) return;

    final error = widget.controller.errorMessage;
    final success = widget.controller.successMessage;

    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }

    if (success != null && success.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success),
          backgroundColor: _darkGreen,
        ),
      );
    }

    setState(() {});
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.registerCustomer(
      firstName: _firstNameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      gender: _gender,
    );

    if (!mounted || !success) return;

    AppRouter.pushNamedAndRemoveUntil(context, RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.controller.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _infoBox(),
          const SizedBox(height: 20),
          _buildLabel('Vorname'),
          const SizedBox(height: 8),
          _buildFirstNameField(),
          const SizedBox(height: 16),
          _buildLabel('Username'),
          const SizedBox(height: 8),
          _buildUsernameField(),
          const SizedBox(height: 16),
          _buildLabel('E-Mail'),
          const SizedBox(height: 8),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildLabel('Passwort'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildLabel('Geschlecht'),
          const SizedBox(height: 8),
          _genderToggle(),
          const SizedBox(height: 24),
          _registerButton(isLoading),
          const SizedBox(height: 14),
          _loginHint(),
        ],
      ),
    );
  }

  Widget _infoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _lightGreen.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _darkGreen.withOpacity(0.9),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hier registrieren sich nur private Nutzer. Merchant-Zugang läuft über Anfrage.',
              style: TextStyle(
                fontSize: 13.5,
                color: _darkGreen.withOpacity(0.88),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _lightGreen.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleButton(
              title: 'M',
              isActive: _gender == 'M',
              onTap: () {
                setState(() {
                  _gender = 'M';
                });
              },
            ),
          ),
          Expanded(
            child: _toggleButton(
              title: 'W',
              isActive: _gender == 'W',
              onTap: () {
                setState(() {
                  _gender = 'W';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? _darkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : _darkGreen,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _darkGreen,
        ),
      ),
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: _inputDecoration(
        hintText: 'Dein Vorname',
        prefixIcon: Icons.person_outline_rounded,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Bitte Vorname eingeben.';
        }
        if (value.trim().length < 2) {
          return 'Vorname ist zu kurz.';
        }
        return null;
      },
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: _inputDecoration(
        hintText: 'dein_username',
        prefixIcon: Icons.alternate_email_rounded,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Bitte Username eingeben.';
        }
        if (value.trim().length < 3) {
          return 'Username ist zu kurz.';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(
        hintText: 'deine@email.de',
        prefixIcon: Icons.mail_outline_rounded,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Bitte E-Mail eingeben.';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: _inputDecoration(
        hintText: 'Mindestens 6 Zeichen',
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: _darkGreen.withOpacity(0.7),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Bitte Passwort eingeben.';
        }
        if (value.trim().length < 6) {
          return 'Mindestens 6 Zeichen.';
        }
        return null;
      },
    );
  }

  Widget _registerButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Colors.white,
          ),
        )
            : const Text(
          'Registrieren',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _loginHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Schon ein Konto?',
          style: TextStyle(
            color: _darkGreen.withOpacity(0.75),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            AppRouter.pushReplacementNamed(context, RouteNames.login);
          },
          child: const Text(
            'Einloggen',
            style: TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: _darkGreen.withOpacity(0.45),
      ),
      filled: true,
      fillColor: _fieldBg,
      prefixIcon: Icon(
        prefixIcon,
        color: _darkGreen.withOpacity(0.72),
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: _lightGreen,
          width: 1.4,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: _midGreen,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 1.4,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.red.shade600,
          width: 1.8,
        ),
      ),
    );
  }
}