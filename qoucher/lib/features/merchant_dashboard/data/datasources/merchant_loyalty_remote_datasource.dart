import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantLoyaltyRemoteDatasource {
  MerchantLoyaltyRemoteDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _loyaltyPrograms =>
      _firestore.collection('merchant_loyalty_programs');

  Future<void> savePointsProgram({
    required String merchantId,
    required bool isEnabled,
    required double pointsPerEuro,
    Map<String, dynamic>? boosterConfig,
  }) async {
    await _loyaltyPrograms.doc('${merchantId}_points').set({
      'merchantId': merchantId,
      'programType': 'points',
      'isEnabled': isEnabled,
      'pointsPerEuro': pointsPerEuro,
      'boosterConfig': boosterConfig ?? {},
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> saveStampProgram({
    required String merchantId,
    required bool isEnabled,
    required String stampCardName,
    required int requiredStamps,
    Map<String, dynamic>? conditions,
  }) async {
    await _loyaltyPrograms.doc('${merchantId}_stamp_$stampCardName').set({
      'merchantId': merchantId,
      'programType': 'stamp',
      'stampCardName': stampCardName,
      'requiredStamps': requiredStamps,
      'conditions': conditions ?? {},
      'isEnabled': isEnabled,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getMerchantPrograms(String merchantId) async {
    final snapshot = await _loyaltyPrograms
        .where('merchantId', isEqualTo: merchantId)
        .get();

    return snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList();
  }

  Future<Map<String, dynamic>?> getPointsProgram(String merchantId) async {
    final doc = await _loyaltyPrograms.doc('${merchantId}_points').get();
    return doc.data();
  }

  Future<void> toggleProgram(String documentId, bool isEnabled) async {
    await _loyaltyPrograms.doc(documentId).update({
      'isEnabled': isEnabled,
      'updatedAt': Timestamp.now(),
    });
  }
}