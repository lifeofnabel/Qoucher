import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantDashboardRemoteDatasource {
  MerchantDashboardRemoteDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> getMerchantProfile(String merchantId) async {
    final doc = await _firestore.collection('users').doc(merchantId).get();
    return doc.data();
  }

  Future<int> getActiveActionsCount(String merchantId) async {
    final snapshot = await _firestore
        .collection('merchant_actions')
        .where('merchantId', isEqualTo: merchantId)
        .where('status', isEqualTo: 'active')
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<int> getArchivedActionsCount(String merchantId) async {
    final snapshot = await _firestore
        .collection('merchant_actions')
        .where('merchantId', isEqualTo: merchantId)
        .where('status', isEqualTo: 'archived')
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<int> getScannedTodayCount(String merchantId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('merchant_scans')
        .where('merchantId', isEqualTo: merchantId)
        .where(
      'createdAt',
      isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
    )
        .where(
      'createdAt',
      isLessThan: Timestamp.fromDate(endOfDay),
    )
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<Map<String, dynamic>> getDashboardOverview(String merchantId) async {
    final profile = await getMerchantProfile(merchantId);
    final activeActions = await getActiveActionsCount(merchantId);
    final archivedActions = await getArchivedActionsCount(merchantId);
    final scannedToday = await getScannedTodayCount(merchantId);

    return {
      'profile': profile,
      'activeActionsCount': activeActions,
      'archivedActionsCount': archivedActions,
      'scannedTodayCount': scannedToday,
    };
  }
}