import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantScansRemoteDatasource {
  MerchantScansRemoteDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _scans =>
      _firestore.collection('merchant_scans');

  Future<Map<String, dynamic>?> findCustomerByLiveCode(String liveCode) async {
    final snapshot = await _users
        .where('role', isEqualTo: 'customer')
        .where('liveCode', isEqualTo: liveCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return {
      'id': doc.id,
      ...doc.data(),
    };
  }

  Future<void> addPointsFromAmount({
    required String merchantId,
    required String customerId,
    required double amount,
    required double pointsPerEuro,
    String? comment,
  }) async {
    final int pointsToAdd = (amount * pointsPerEuro).floor();
    final userRef = _users.doc(customerId);

    await _firestore.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      final userData = userSnap.data() ?? {};

      final currentPoints = (userData['points'] ?? 0) as int;
      final newPoints = currentPoints + pointsToAdd;

      transaction.update(userRef, {
        'points': newPoints,
        'updatedAt': Timestamp.now(),
      });

      transaction.set(_scans.doc(), {
        'merchantId': merchantId,
        'customerId': customerId,
        'type': 'points_added',
        'amount': amount,
        'pointsAdded': pointsToAdd,
        'comment': comment,
        'createdAt': Timestamp.now(),
      });
    });
  }

  Future<void> addStamp({
    required String merchantId,
    required String customerId,
    required String stampProgramId,
    String? comment,
  }) async {
    final userRef = _users.doc(customerId);

    await _firestore.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      final userData = userSnap.data() ?? {};

      final Map<String, dynamic> stampCards =
      Map<String, dynamic>.from(userData['stampCards'] ?? {});

      final int currentStamps = (stampCards[stampProgramId] ?? 0) as int;
      stampCards[stampProgramId] = currentStamps + 1;

      transaction.update(userRef, {
        'stampCards': stampCards,
        'updatedAt': Timestamp.now(),
      });

      transaction.set(_scans.doc(), {
        'merchantId': merchantId,
        'customerId': customerId,
        'type': 'stamp_added',
        'stampProgramId': stampProgramId,
        'comment': comment,
        'createdAt': Timestamp.now(),
      });
    });
  }

  Future<void> redeemReward({
    required String merchantId,
    required String customerId,
    required String rewardId,
    String? comment,
  }) async {
    await _scans.add({
      'merchantId': merchantId,
      'customerId': customerId,
      'rewardId': rewardId,
      'type': 'reward_redeemed',
      'comment': comment,
      'createdAt': Timestamp.now(),
    });
  }

  Future<List<Map<String, dynamic>>> getScannedHistory(String merchantId) async {
    final snapshot = await _scans
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTodayScans(String merchantId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _scans
        .where('merchantId', isEqualTo: merchantId)
        .where(
      'createdAt',
      isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
    )
        .where(
      'createdAt',
      isLessThan: Timestamp.fromDate(endOfDay),
    )
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList();
  }
}