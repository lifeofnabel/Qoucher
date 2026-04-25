class DealRemoteDatasource {
  Future<List<Map<String, dynamic>>> getHotDeals() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      {
        'id': 'deal_001',
        'merchantId': 'merchant_001',
        'title': '2 Wraps günstiger',
        'description': 'Heute Special auf ausgewählte Wraps.',
        'category': 'Food',
        'area': 'Westend',
        'isHot': true,
        'isActive': true,
        'startAt': DateTime.now().toIso8601String(),
        'endAt': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'deal_002',
        'merchantId': 'merchant_002',
        'title': 'Jeder 5. Cut mit Vorteil',
        'description': 'Treue lohnt sich diese Woche extra.',
        'category': 'Barber',
        'area': 'Innenstadt',
        'isHot': true,
        'isActive': true,
        'startAt': DateTime.now().toIso8601String(),
        'endAt': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getDealsByMerchant(String merchantId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      {
        'id': 'deal_101',
        'merchantId': merchantId,
        'title': 'Gratis Extra ab 8 Stempeln',
        'description': 'Nur für kurze Zeit aktiv.',
        'category': 'Food',
        'area': 'Westend',
        'isHot': false,
        'isActive': true,
        'startAt': DateTime.now().toIso8601String(),
        'endAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      },
      {
        'id': 'deal_102',
        'merchantId': merchantId,
        'title': 'Wochenangebot',
        'description': 'Einfach, lokal, stark.',
        'category': 'Food',
        'area': 'Westend',
        'isHot': true,
        'isActive': true,
        'startAt': DateTime.now().toIso8601String(),
        'endAt': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      },
    ];
  }

  Future<Map<String, dynamic>> createDeal({
    required String merchantId,
    required String title,
    required String description,
    required String category,
    required String area,
    required bool isHot,
    required bool isActive,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (title.trim().isEmpty) {
      throw Exception('Deal-Titel fehlt.');
    }

    return {
      'id': 'deal_new_001',
      'merchantId': merchantId,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'area': area,
      'isHot': isHot,
      'isActive': isActive,
      'startAt': (startAt ?? DateTime.now()).toIso8601String(),
      'endAt': (endAt ?? DateTime.now().add(const Duration(days: 7)))
          .toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> updateDeal({
    required String dealId,
    required String merchantId,
    required String title,
    required String description,
    required String category,
    required String area,
    required bool isHot,
    required bool isActive,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 750));

    return {
      'id': dealId,
      'merchantId': merchantId,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'area': area,
      'isHot': isHot,
      'isActive': isActive,
      'startAt': (startAt ?? DateTime.now()).toIso8601String(),
      'endAt': (endAt ?? DateTime.now().add(const Duration(days: 7)))
          .toIso8601String(),
    };
  }

  Future<void> deleteDeal(String dealId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}