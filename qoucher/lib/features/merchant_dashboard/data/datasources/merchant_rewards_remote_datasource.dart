import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantRewardsRemoteDatasource {
  MerchantRewardsRemoteDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _rewards =>
      _firestore.collection('merchant_rewards');

  Future<String> createReward({
    required String merchantId,
    required String title,
    required String description,
    required String rewardType,
    String? linkedItemId,
    int? requiredPoints,
    Map<String, dynamic>? conditions,
    bool isActive = true,
  }) async {
    final now = Timestamp.now();

    final doc = await _rewards.add({
      'merchantId': merchantId,
      'title': title,
      'description': description,
      'rewardType': rewardType,
      'linkedItemId': linkedItemId,
      'requiredPoints': requiredPoints,
      'conditions': conditions ?? {},
      'isActive': isActive,
      'createdAt': now,
      'updatedAt': now,
    });

    return doc.id;
  }

  Future<List<Map<String, dynamic>>> getMerchantRewards(String merchantId) async {
    final snapshot = await _rewards
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList();
  }

  Future<void> updateReward(
      String rewardId, {
        String? title,
        String? description,
        String? rewardType,
        String? linkedItemId,
        int? requiredPoints,
        Map<String, dynamic>? conditions,
        bool? isActive,
      }) async {
    final data = <String, dynamic>{
      'updatedAt': Timestamp.now(),
    };

    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (rewardType != null) data['rewardType'] = rewardType;
    if (linkedItemId != null) data['linkedItemId'] = linkedItemId;
    if (requiredPoints != null) data['requiredPoints'] = requiredPoints;
    if (conditions != null) data['conditions'] = conditions;
    if (isActive != null) data['isActive'] = isActive;

    await _rewards.doc(rewardId).update(data);
  }

  Future<void> setRewardActive(String rewardId, bool isActive) async {
    await _rewards.doc(rewardId).update({
      'isActive': isActive,
      'updatedAt': Timestamp.now(),
    });
  }
}