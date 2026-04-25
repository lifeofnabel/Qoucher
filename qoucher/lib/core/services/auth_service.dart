import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qoucher/data/models/app_user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    return AppUser(
      id: user.uid,
      firstName: user.displayName ?? '',
      username: user.email?.split('@').first ?? '',
      email: user.email ?? '',
      role: 'customer',
      createdAt: user.metadata.creationTime,
    );
  }

  bool get isMerchant => currentUser?.role == 'merchant';
  bool get isCustomer => currentUser?.role == 'customer';

  static const String usersCollection = 'users';
  static const String merchantRequestsCollection = 'merchant_requests';

  User? get firebaseUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser> login({
    required String email,
    required String password,
    required bool wantsMerchantLogin,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Login fehlgeschlagen.');
      }

      final doc = await _firestore.collection(usersCollection).doc(user.uid).get();
      final data = doc.data();

      if (data == null) {
        await _auth.signOut();
        throw Exception('Kein Benutzerprofil gefunden.');
      }

      final role = (data['role'] ?? 'customer').toString();

      if (wantsMerchantLogin && role != 'merchant') {
        await _auth.signOut();
        throw Exception('Dieses Konto ist kein Merchant-Konto.');
      }

      if (!wantsMerchantLogin && role == 'merchant') {
        await _auth.signOut();
        throw Exception('Bitte als Merchant einloggen.');
      }

      return AppUser(
        id: user.uid,
        firstName: data['firstName']?.toString() ?? user.displayName ?? '',
        username: data['username']?.toString() ?? user.email?.split('@').first ?? '',
        email: data['email']?.toString() ?? user.email ?? '',
        role: role,
        createdAt: _parseDate(data['createdAt']) ?? user.metadata.creationTime,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  Future<AppUser> registerCustomer({
    required String firstName,
    required String username,
    required String email,
    required String password,
    required String gender,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Registrierung fehlgeschlagen.');
      }

      await user.updateDisplayName(firstName.trim());

      final userData = {
        'uid': user.uid,
        'firstName': firstName.trim(),
        'username': username.trim().toLowerCase(),
        'email': email.trim().toLowerCase(),
        'gender': gender.trim(),
        'role': 'customer',
        'isActive': true,
        'authProvider': 'password',
        'registeredVia': 'self_signup',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(usersCollection).doc(user.uid).set(userData);

      final freshDoc =
      await _firestore.collection(usersCollection).doc(user.uid).get();
      final freshData = freshDoc.data() ?? {};

      return AppUser(
        id: user.uid,
        firstName: freshData['firstName']?.toString() ?? firstName.trim(),
        username: freshData['username']?.toString() ?? username.trim().toLowerCase(),
        email: freshData['email']?.toString() ?? email.trim().toLowerCase(),
        role: 'customer',
        createdAt: _parseDate(freshData['createdAt']) ?? user.metadata.creationTime,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  Future<void> requestMerchantAccess({
    required String businessName,
    required String category,
    required String phone,
    required String email,
    String? contactName,
    String? note,
  }) async {
    if (businessName.trim().isEmpty) {
      throw Exception('Bitte Geschäftsname eingeben.');
    }
    if (category.trim().isEmpty) {
      throw Exception('Bitte Kategorie eingeben.');
    }
    if (phone.trim().isEmpty) {
      throw Exception('Bitte Telefonnummer eingeben.');
    }
    if (email.trim().isEmpty) {
      throw Exception('Bitte E-Mail eingeben.');
    }

    await _firestore.collection(merchantRequestsCollection).add({
      'businessName': businessName.trim(),
      'category': category.trim(),
      'phone': phone.trim(),
      'email': email.trim().toLowerCase(),
      'contactName': (contactName ?? '').trim(),
      'note': (note ?? '').trim(),
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> forgotPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
      return 'Passwort-Link wurde gesendet.';
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Ungültige E-Mail-Adresse.';
      case 'user-not-found':
        return 'Kein Konto mit dieser E-Mail gefunden.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-Mail oder Passwort ist falsch.';
      case 'email-already-in-use':
        return 'Diese E-Mail wird bereits verwendet.';
      case 'weak-password':
        return 'Das Passwort ist zu schwach.';
      case 'too-many-requests':
        return 'Zu viele Versuche. Bitte später erneut versuchen.';
      case 'network-request-failed':
        return 'Netzwerkfehler. Bitte Internet prüfen.';
      default:
        return e.message ?? 'Ein unbekannter Fehler ist aufgetreten.';
    }
  }
}