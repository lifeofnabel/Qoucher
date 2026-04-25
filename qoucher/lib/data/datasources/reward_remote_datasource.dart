class RewardRemoteDatasource {
  Future<List<Map<String, dynamic>>> getRewardsByMerchant(
      String merchantId,
      ) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      {
        'id': 'reward_001',
        'merchantId': merchantId,
        'title': 'Gratis Getränk',
        'description': 'Kostenloses Getränk nach genug Sammeln.',
        'rewardType': 'free_item',
        'costPoints': null,
        'requiredStamps': 8,
        'isActive': true,
      },
      {
        'id': 'reward_002',
        'merchantId': merchantId,
        'title': '10% Rabatt',
        'description': 'Rabatt auf den nächsten Einkauf.',
        'rewardType': 'discount',
        'costPoints': 100,
        'requiredStamps': null,
        'isActive': true,
      },
    ];
  }

  Future<Map<String, dynamic>> getRewardById(String rewardId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'id': rewardId,
      'merchantId': 'merchant_001',
      'title': 'Gratis Extra',
      'description': 'Kleiner Bonus für treue Kunden.',
      'rewardType': 'free_item',
      'costPoints': null,
      'requiredStamps': 6,
      'isActive': true,
    };
  }

  Future<Map<String, dynamic>> createReward({
    required String merchantId,
    required String title,
    required String description,
    required String rewardType,
    int? costPoints,
    int? requiredStamps,
    required bool isActive,
  }) async {
    await Future.delayed(const Duration(milliseconds: 850));

    if (title.trim().isEmpty) {
      throw Exception('Reward-Titel fehlt.');
    }

    if (rewardType.trim().isEmpty) {
      throw Exception('Reward-Typ fehlt.');
    }

    return {
      'id': 'reward_new_001',
      'merchantId': merchantId,
      'title': title.trim(),
      'description': description.trim(),
      'rewardType': rewardType,
      'costPoints': costPoints,
      'requiredStamps': requiredStamps,
      'isActive': isActive,
    };
  }

  Future<Map<String, dynamic>> updateReward({
    required String rewardId,
    required String merchantId,
    required String title,
    required String description,
    required String rewardType,
    int? costPoints,
    int? requiredStamps,
    required bool isActive,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return {
      'id': rewardId,
      'merchantId': merchantId,
      'title': title.trim(),
      'description': description.trim(),
      'rewardType': rewardType,
      'costPoints': costPoints,
      'requiredStamps': requiredStamps,
      'isActive': isActive,
    };
  }

  Future<void> deleteReward(String rewardId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}