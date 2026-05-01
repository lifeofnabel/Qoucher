import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:qoucher/app.dart';
import 'package:qoucher/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('🔥 Firebase initialized');
  debugPrint('🔥 Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');

  await _debugFirestoreConnection();

  runApp(const QoucherApp());
}

Future<void> _debugFirestoreConnection() async {
  try {
    final firestore = FirebaseFirestore.instance;

    final areasSnapshot = await firestore.collection('areas').get();
    final shopTypeSnapshot = await firestore.collection('shopType').get();
    final merchantsSnapshot = await firestore.collection('merchants').get();

    debugPrint('🔥 AREAS COUNT: ${areasSnapshot.docs.length}');
    debugPrint('🔥 SHOPTYPE COUNT: ${shopTypeSnapshot.docs.length}');
    debugPrint('🔥 MERCHANTS COUNT: ${merchantsSnapshot.docs.length}');

    for (final doc in areasSnapshot.docs) {
      debugPrint('🔥 AREA: ${doc.id} => ${doc.data()}');
    }

    for (final doc in shopTypeSnapshot.docs) {
      debugPrint('🔥 SHOPTYPE: ${doc.id} => ${doc.data()}');
    }

    for (final doc in merchantsSnapshot.docs) {
      debugPrint('🔥 MERCHANT: ${doc.id} => ${doc.data()}');
    }
  } catch (error) {
    debugPrint('🔥 FIRESTORE DEBUG ERROR: $error');
  }
}