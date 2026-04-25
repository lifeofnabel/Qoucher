import 'package:flutter/material.dart';
import 'package:qoucher/features/auth/presentation/controllers/auth_controller.dart';
import 'package:qoucher/features/auth/presentation/widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF7FCF5);
    const cardColor = Colors.white;
    const primaryGreen = Color(0xFFD9F2D0);
    const darkGreen = Color(0xFF244D2C);
    const accentGreen = Color(0xFF8BCF95);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: darkGreen.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ],
                  border: Border.all(
                    color: primaryGreen,
                    width: 1.4,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 36,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Willkommen bei Qoucher',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Lokale Deals. Punkte. Stempel. Alles leicht, direkt und ohne App-Stress.',
                      style: TextStyle(
                        fontSize: 15,
                        color: darkGreen.withOpacity(0.75),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: darkGreen.withOpacity(0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Logge dich ein und starte direkt mit Deals, Punkten und Shop-Funktionen.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: darkGreen.withOpacity(0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    LoginForm(controller: _controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}