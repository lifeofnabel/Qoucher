class LoyaltyRemoteDatasource {
  Future<List<Map<String, dynamic>>> getUserLoyaltyAccounts(
      String userId,
      ) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      {
        'id': 'loyalty_001',
        'userId': userId,
        'merchantId': 'merchant_001',
        'merchantName': 'Babel Imbiss',
        'loyaltyType': 'stamps',
        'points': 0,
        'stamps': 4,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'loyalty_002',
        'userId': userId,
        'merchantId': 'merchant_002',
        'merchantName': 'Glow Beauty',
        'loyaltyType': 'points',
        'points': 70,
        'stamps': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];
  }

  Future<Map<String, dynamic>> getLoyaltyAccount({
    required String userId,
    required String merchantId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 550));

    return {
      'id': 'loyalty_single_001',
      'userId': userId,
      'merchantId': merchantId,
      'merchantName': 'Demo Merchant',
      'loyaltyType': 'points',
      'points': 35,
      'stamps': 0,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> addPoints({
    required String userId,
    required String merchantId,
    required int amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (amount <= 0) {
      throw Exception('Punkte müssen größer als 0 sein.');
    }

    return {
      'success': true,
      'message': '$amount Punkte wurden hinzugefügt.',
      'transaction': {
        'id': 'txn_points_001',
        'userId': userId,
        'merchantId': merchantId,
        'type': 'add_points',
        'value': amount,
        'createdAt': DateTime.now().toIso8601String(),
      },
    };
  }

  Future<Map<String, dynamic>> addStamp({
    required String userId,
    required String merchantId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 650));

    return {
      'success': true,
      'message': '1 Stempel wurde hinzugefügt.',
      'transaction': {
        'id': 'txn_stamp_001',
        'userId': userId,
        'merchantId': merchantId,
        'type': 'add_stamp',
        'value': 1,
        'createdAt': DateTime.now().toIso8601String(),
      },
    };
  }

  Future<Map<String, dynamic>> redeemReward({
    required String userId,
    required String merchantId,
    required String rewardId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return {
      'success': true,
      'message': 'Belohnung erfolgreich eingelöst.',
      'transaction': {
        'id': 'txn_redeem_001',
        'userId': userId,
        'merchantId': merchantId,
        'rewardId': rewardId,
        'type': 'redeem_reward',
        'value': 1,
        'createdAt': DateTime.now().toIso8601String(),
      },
    };
  }

  Future<List<Map<String, dynamic>>> getTransactions({
    required String userId,
    String? merchantId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 750));

    return [
      {
        'id': 'txn_001',
        'userId': userId,
        'merchantId': merchantId ?? 'merchant_001',
        'type': 'add_stamp',
        'value': 1,
        'note': 'Besuch bestätigt',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'txn_002',
        'userId': userId,
        'merchantId': merchantId ?? 'merchant_002',
        'type': 'add_points',
        'value': 20,
        'note': 'Punkte gesammelt',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'txn_003',
        'userId': userId,
        'merchantId': merchantId ?? 'merchant_001',
        'type': 'redeem_reward',
        'value': 1,
        'note': 'Reward eingelöst',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
    ];
  }
}