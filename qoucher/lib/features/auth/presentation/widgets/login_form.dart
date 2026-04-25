import 'package:flutter/material.dart';
import 'package:qoucher/features/auth/presentation/controllers/auth_controller.dart';
import 'package:qoucher/router/app_router.dart';
import 'package:qoucher/router/route_names.dart';

class LoginForm extends StatefulWidget {
  final AuthController controller;

  const LoginForm({
    super.key,
    required this.controller,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  static const Color _lightGreen = Color(0xFFD9F2D0);
  static const Color _darkGreen = Color(0xFF244D2C);
  static const Color _midGreen = Color(0xFF8BCF95);
  static const Color _fieldBg = Color(0xFFF9FDF8);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _controllerListener() {
    if (!mounted) return;

    final error = widget.controller.errorMessage;
    final success = widget.controller.successMessage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red.shade600,
            ),
          );
      }

      if (success != null && success.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(success),
              backgroundColor: _darkGreen,
            ),
          );
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted || !success) return;

    final user = widget.controller.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (user?.role == 'merchant') {
        AppRouter.pushNamedAndRemoveUntil(
          context,
          RouteNames.merchantDashboard,
          arguments: {
            'merchantId': user?.id ?? '',
          },
        );
      } else {
        AppRouter.pushNamedAndRemoveUntil(
          context,
          RouteNames.home,
        );
      }
    });
  }

  void _showCustomerRegisterDialog() {
    final dialogFormKey = GlobalKey<FormState>();

    final firstNameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    bool obscureDialogPassword = true;
    String gender = 'M';

    showDialog(
      context: context,
      barrierDismissible: !widget.controller.isLoading,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Als Kunde registrieren',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _darkGreen,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kurz ausfüllen und direkt loslegen.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF4F6F55),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 430,
                child: Form(
                  key: dialogFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDialogField(
                          controller: firstNameController,
                          label: 'Vorname',
                          hintText: 'Dein Vorname',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Vorname eingeben.';
                            }
                            if (value.trim().length < 2) {
                              return 'Vorname ist zu kurz.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDialogField(
                          controller: usernameController,
                          label: 'Username',
                          hintText: 'dein_username',
                          prefixIcon: Icons.alternate_email_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Username eingeben.';
                            }
                            if (value.trim().length < 3) {
                              return 'Username ist zu kurz.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDialogField(
                          controller: emailController,
                          label: 'E-Mail',
                          hintText: 'deine@email.de',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte E-Mail eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDialogField(
                          controller: passwordController,
                          label: 'Passwort',
                          hintText: 'Mindestens 6 Zeichen',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: obscureDialogPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureDialogPassword = !obscureDialogPassword;
                              });
                            },
                            icon: Icon(
                              obscureDialogPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: _darkGreen.withOpacity(0.72),
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
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Geschlecht'),
                        const SizedBox(height: 8),
                        Container(
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
                                  isActive: gender == 'M',
                                  onTap: () {
                                    setDialogState(() {
                                      gender = 'M';
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: _toggleButton(
                                  title: 'W',
                                  isActive: gender == 'W',
                                  onTap: () {
                                    setDialogState(() {
                                      gender = 'W';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: widget.controller.isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Abbrechen',
                    style: TextStyle(
                      color: _darkGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.controller.isLoading
                      ? null
                      : () async {
                    FocusScope.of(context).unfocus();

                    if (!dialogFormKey.currentState!.validate()) return;

                    final success = await widget.controller.registerCustomer(
                      firstName: firstNameController.text,
                      username: usernameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      gender: gender,
                    );

                    if (!mounted || !success) return;

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }

                    AppRouter.pushNamedAndRemoveUntil(
                      context,
                      RouteNames.home,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: widget.controller.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Jetzt registrieren',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      firstNameController.dispose();
      usernameController.dispose();
      emailController.dispose();
      passwordController.dispose();
    });
  }

  void _showMerchantRequestDialog() {
    final dialogFormKey = GlobalKey<FormState>();

    final businessNameController = TextEditingController();
    final categoryController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final contactNameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: !widget.controller.isLoading,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merchant-Anfrage',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _darkGreen,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lass deine Daten da. Wir melden uns bei dir.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF4F6F55),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 430,
                child: Form(
                  key: dialogFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDialogField(
                          controller: businessNameController,
                          label: 'Geschäftsname',
                          hintText: 'Dein Ladenname',
                          prefixIcon: Icons.storefront_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Geschäftsname eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDialogField(
                          controller: categoryController,
                          label: 'Kategorie',
                          hintText: 'z. B. Food, Barber, Beauty',
                          prefixIcon: Icons.category_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Kategorie eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDialogField(
                          controller: phoneController,
                          label: 'Telefonnummer',
                          hintText: '0176...',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Telefonnummer eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDialogField(
                          controller: emailController,
                          label: 'E-Mail',
                          hintText: 'mail@business.de',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte E-Mail eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDialogField(
                          controller: contactNameController,
                          label: 'Ansprechpartner (optional)',
                          hintText: 'Dein Name',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: widget.controller.isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Abbrechen',
                    style: TextStyle(
                      color: _darkGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.controller.isLoading
                      ? null
                      : () async {
                    if (!dialogFormKey.currentState!.validate()) return;

                    final success = await widget.controller.requestMerchantAccess(
                      businessName: businessNameController.text,
                      category: categoryController.text,
                      phone: phoneController.text,
                      email: emailController.text,
                      contactName: contactNameController.text,
                    );

                    if (!mounted || !success) return;

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }

                    await Future.delayed(const Duration(milliseconds: 50));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: widget.controller.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Anfrage senden',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      businessNameController.dispose();
      categoryController.dispose();
      phoneController.dispose();
      emailController.dispose();
      contactNameController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.controller.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _roleToggle(),
          const SizedBox(height: 20),
          _roleInfoBox(),
          const SizedBox(height: 20),
          _buildLabel('E-Mail'),
          const SizedBox(height: 8),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildLabel('Passwort'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 12),
          _forgotPasswordButton(),
          const SizedBox(height: 20),
          _loginButton(isLoading),
          const SizedBox(height: 14),
          _registerHint(),
        ],
      ),
    );
  }

  Widget _roleInfoBox() {
    final isMerchant = widget.controller.isMerchant;

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
            isMerchant ? Icons.storefront_rounded : Icons.person_outline_rounded,
            color: _darkGreen.withOpacity(0.9),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isMerchant
                  ? 'Merchant-Zugang ist nur nach Freischaltung möglich. Neue Merchants schicken erst eine Anfrage.'
                  : 'Als Kunde kannst du dich direkt registrieren und sofort loslegen.',
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

  Widget _roleToggle() {
    final isMerchant = widget.controller.isMerchant;

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
              title: 'Kunde',
              isActive: !isMerchant,
              onTap: () => widget.controller.setMerchant(false),
            ),
          ),
          Expanded(
            child: _toggleButton(
              title: 'Merchant',
              isActive: isMerchant,
              onTap: () => widget.controller.setMerchant(true),
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

  Widget _forgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          AppRouter.pushNamed(context, RouteNames.forgotPassword);
        },
        child: const Text(
          'Passwort vergessen?',
          style: TextStyle(
            color: _darkGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _loginButton(bool isLoading) {
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
            : Text(
          widget.controller.isMerchant ? 'Als Merchant einloggen' : 'Einloggen',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _registerHint() {
    final isMerchant = widget.controller.isMerchant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isMerchant ? 'Noch kein Merchant-Zugang?' : 'Noch kein Konto?',
          style: TextStyle(
            color: _darkGreen.withOpacity(0.75),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: isMerchant
              ? _showMerchantRequestDialog
              : _showCustomerRegisterDialog,
          child: Text(
            isMerchant ? 'Anfrage senden' : 'Registrieren',
            style: const TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: _inputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
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