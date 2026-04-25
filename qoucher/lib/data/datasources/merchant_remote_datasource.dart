class MerchantRemoteDatasource {
  Future<List<Map<String, dynamic>>> getAllMerchants() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      {
        'id': 'merchant_001',
        'ownerId': 'owner_001',
        'name': 'Babel Imbiss',
        'category': 'Food',
        'area': 'Westend',
        'description': 'Levante Food, Wraps, Bowls und mehr.',
        'loyaltyType': 'stamps',
        'isActive': true,
      },
      {
        'id': 'merchant_002',
        'ownerId': 'owner_002',
        'name': 'City Barber',
        'category': 'Barber',
        'area': 'Innenstadt',
        'description': 'Fresh Cuts und Stammkunden-Vorteile.',
        'loyaltyType': 'stamps',
        'isActive': true,
      },
      {
        'id': 'merchant_003',
        'ownerId': 'owner_003',
        'name': 'Glow Beauty',
        'category': 'Beauty',
        'area': 'Sachsenhausen',
        'description': 'Beauty Deals und Punkte sammeln.',
        'loyaltyType': 'points',
        'isActive': true,
      },
    ];
  }

  Future<Map<String, dynamic>> getMerchantById(String merchantId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'id': merchantId,
      'ownerId': 'owner_demo',
      'name': 'Babel Imbiss',
      'category': 'Food',
      'area': 'Westend',
      'description': 'Lokaler Spot für gutes Essen und gute Offers.',
      'loyaltyType': 'stamps',
      'isActive': true,
    };
  }

  Future<Map<String, dynamic>> createMerchant({
    required String ownerId,
    required String name,
    required String category,
    required String area,
    required String description,
    required String loyaltyType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (name.trim().isEmpty) {
      throw Exception('Merchant-Name fehlt.');
    }

    return {
      'id': 'merchant_new_001',
      'ownerId': ownerId,
      'name': name.trim(),
      'category': category,
      'area': area,
      'description': description.trim(),
      'loyaltyType': loyaltyType,
      'isActive': true,
    };
  }

  Future<Map<String, dynamic>> updateMerchant({
    required String merchantId,
    required String name,
    required String category,
    required String area,
    required String description,
    required String loyaltyType,
    required bool isActive,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return {
      'id': merchantId,
      'name': name.trim(),
      'category': category,
      'area': area,
      'description': description.trim(),
      'loyaltyType': loyaltyType,
      'isActive': isActive,
    };
  }
}