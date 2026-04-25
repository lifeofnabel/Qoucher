import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const Color _bg = Color(0xFFF4FAF1);
  static const Color _card = Colors.white;
  static const Color _light = Color(0xFFD9F2D0);
  static const Color _mid = Color(0xFF8BCF95);
  static const Color _dark = Color(0xFF244D2C);
  static const Color _muted = Color(0xFF5F7463);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _authenticated = false;
  bool _isCheckingPassword = false;
  bool _isCreatingMerchant = false;

  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkPassword() async {
    if (_passwordController.text.trim() != '1234') {
      _showSnack('Falsches Passwort.', isError: true);
      return;
    }

    setState(() {
      _isCheckingPassword = true;
    });

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      _authenticated = true;
      _isCheckingPassword = false;
    });
  }

  Future<void> _approveRequest({
    required String requestId,
    required Map<String, dynamic> requestData,
  }) async {
    final businessNameController = TextEditingController(
      text: (requestData['businessName'] ?? '').toString(),
    );
    final emailController = TextEditingController(
      text: (requestData['email'] ?? '').toString(),
    );
    final phoneController = TextEditingController(
      text: (requestData['phone'] ?? '').toString(),
    );
    final categoryController = TextEditingController(
      text: (requestData['category'] ?? '').toString(),
    );
    final passwordController = TextEditingController();
    final noteController = TextEditingController(
      text: (requestData['contactName'] ?? '').toString(),
    );

    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    await showDialog(
      context: context,
      barrierDismissible: !_isCreatingMerchant,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _card,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Merchant freischalten',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _dark,
                ),
              ),
              content: SizedBox(
                width: 460,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dialogField(
                          controller: businessNameController,
                          label: 'Geschäftsname',
                          hint: 'Ladenname',
                          icon: Icons.storefront_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Geschäftsname eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _dialogField(
                          controller: categoryController,
                          label: 'Kategorie',
                          hint: 'Food, Barber, Beauty ...',
                          icon: Icons.category_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Kategorie eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _dialogField(
                          controller: emailController,
                          label: 'E-Mail',
                          hint: 'mail@business.de',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte E-Mail eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _dialogField(
                          controller: phoneController,
                          label: 'Telefon',
                          hint: '0176...',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Telefonnummer eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _dialogField(
                          controller: passwordController,
                          label: 'Start-Passwort',
                          hint: 'Mindestens 6 Zeichen',
                          icon: Icons.lock_outline_rounded,
                          obscureText: obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: _dark.withOpacity(0.7),
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
                        const SizedBox(height: 14),
                        _dialogField(
                          controller: noteController,
                          label: 'Ansprechpartner / Notiz',
                          hint: 'Optional',
                          icon: Icons.badge_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isCreatingMerchant
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Abbrechen',
                    style: TextStyle(
                      color: _dark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isCreatingMerchant
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;

                    await _createMerchantAccount(
                      requestId: requestId,
                      businessName: businessNameController.text.trim(),
                      category: categoryController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      password: passwordController.text.trim(),
                      contactName: noteController.text.trim(),
                    );

                    if (!mounted) return;

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isCreatingMerchant
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Freischalten',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    businessNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    categoryController.dispose();
    passwordController.dispose();
    noteController.dispose();
  }

  Future<void> _createMerchantAccount({
    required String requestId,
    required String businessName,
    required String category,
    required String email,
    required String phone,
    required String password,
    required String contactName,
  }) async {
    try {
      setState(() {
        _isCreatingMerchant = true;
      });

      final tempApp = await FirebaseAuth.instance.app
          .options
          .projectId; // nur damit Analyzer ruhig bleibt bei Web-Setups

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Merchant konnte nicht erstellt werden.');
      }

      await user.updateDisplayName(businessName);

      final merchantData = {
        'uid': user.uid,
        'firstName': businessName,
        'username': _buildUsername(businessName, category),
        'email': email.toLowerCase(),
        'gender': '',
        'role': 'merchant',
        'isActive': true,
        'authProvider': 'password',
        'registeredVia': 'admin_approval',
        'businessName': businessName,
        'category': category,
        'phone': phone,
        'contactName': contactName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(merchantData);

      await _firestore.collection('merchant_requests').doc(requestId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedMerchantUid': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnack('Merchant erfolgreich erstellt.');
    } on FirebaseAuthException catch (e) {
      _showSnack(_mapAuthError(e), isError: true);
    } catch (e) {
      _showSnack('Fehler: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingMerchant = false;
        });
      }
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    try {
      await _firestore.collection('merchant_requests').doc(requestId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnack('Anfrage abgelehnt.');
    } catch (e) {
      _showSnack('Fehler beim Ablehnen.', isError: true);
    }
  }

  String _buildUsername(String businessName, String category) {
    final base = '$businessName $category'
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');

    return base.isEmpty ? 'merchant_user' : base;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Diese E-Mail wird bereits verwendet.';
      case 'weak-password':
        return 'Das Passwort ist zu schwach.';
      case 'invalid-email':
        return 'Ungültige E-Mail-Adresse.';
      default:
        return e.message ?? 'Unbekannter Auth-Fehler.';
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red.shade600 : _dark,
          ),
        );
    });
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _dark.withOpacity(0.45),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FDF8),
            prefixIcon: Icon(
              icon,
              color: _dark.withOpacity(0.72),
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _light,
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _mid,
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _dark,
        title: const Text(
          'Admin',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _dark,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: !_authenticated ? _buildLoginGate() : _buildDashboard(),
      ),
    );
  }

  Widget _buildLoginGate() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _light,
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _dark.withOpacity(0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: _light,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 40,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Admin Zugang',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ein kleiner versteckter Raum hinter dem grünen Vorhang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.55,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  onSubmitted: (_) => _checkPassword(),
                  decoration: InputDecoration(
                    labelText: 'Passwort',
                    hintText: '1234',
                    filled: true,
                    fillColor: const Color(0xFFF9FDF8),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: _dark,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: _light,
                        width: 1.4,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: _mid,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isCheckingPassword ? null : _checkPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _dark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isCheckingPassword
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Öffnen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('merchant_requests')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: _dark,
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Fehler beim Laden der Anfragen.',
              style: TextStyle(
                color: _dark,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _light,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _dark.withOpacity(0.06),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _light,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.inbox_rounded,
                        color: _dark,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Merchant-Anfragen',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${docs.length} Einträge im Strom der Anfragen',
                            style: const TextStyle(
                              fontSize: 14,
                              color: _muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: docs.isEmpty
                    ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _light,
                        width: 1.2,
                      ),
                    ),
                    child: const Text(
                      'Noch keine Merchant-Anfragen da.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _dark,
                      ),
                    ),
                  ),
                )
                    : ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final status =
                    (data['status'] ?? 'new').toString();

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _light,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _dark.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (data['businessName'] ?? '-').toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _dark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _badgeColor(status),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: status == 'approved'
                                        ? _dark
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _infoLine('Kategorie', data['category']),
                          _infoLine('Telefon', data['phone']),
                          _infoLine('E-Mail', data['email']),
                          if ((data['contactName'] ?? '').toString().isNotEmpty)
                            _infoLine('Kontakt', data['contactName']),
                          const SizedBox(height: 16),
                          if (status == 'new')
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _isCreatingMerchant
                                      ? null
                                      : () => _approveRequest(
                                    requestId: doc.id,
                                    requestData: data,
                                  ),
                                  icon: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Freischalten',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _dark,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _rejectRequest(doc.id),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Ablehnen',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    side: BorderSide(
                                      color: Colors.red.shade200,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'Diese Anfrage wurde bereits bearbeitet.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: _muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoLine(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              (value ?? '-').toString(),
              style: const TextStyle(
                fontSize: 13.5,
                color: _muted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColor(String status) {
    switch (status) {
      case 'approved':
        return _light;
      case 'rejected':
        return Colors.red.shade400;
      default:
        return _dark;
    }
  }
}