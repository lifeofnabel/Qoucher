class ExplorerDealCardModel {
  final String id;
  final String merchantId;
  final String shopName;

  final String areaId;
  final String areaName;

  final List<String> shopTypeIds;
  final List<String> shopTypeNames;

  final String dealType;
  final String typeLabel;

  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;

  final DateTime? updatedAt;
  final DateTime? createdAt;

  final bool isActive;

  ExplorerDealCardModel({
    required this.id,
    required this.merchantId,
    required this.shopName,
    required this.areaId,
    required this.areaName,
    required this.shopTypeIds,
    required this.shopTypeNames,
    required this.dealType,
    required this.typeLabel,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    this.updatedAt,
    this.createdAt,
    this.isActive = true,
  });

  factory ExplorerDealCardModel.fromMap(Map<String, dynamic> map, Map<String, dynamic> merchant) {
    // Normalisierung basierend auf dem Deal-Typ
    final type = map['type'] ?? 'custom';
    String label = 'Angebot';
    
    switch (type) {
      case 'free_item':
        label = 'Gratis';
        break;
      case 'bundle':
        label = '2 für 1';
        break;
      case 'happy_hour':
        label = 'Happy Hour';
        break;
      case 'custom_post':
        label = 'Beitrag';
        break;
      case 'rescue':
        label = 'Rette mich';
        break;
      case 'discount':
        label = 'Rabatt';
        break;
    }

    return ExplorerDealCardModel(
      id: map['id'] ?? '',
      merchantId: merchant['id'] ?? '',
      shopName: merchant['shopName'] ?? merchant['businessName'] ?? 'Unbekannter Shop',
      areaId: merchant['areaId'] ?? '',
      areaName: merchant['areaName'] ?? '',
      shopTypeIds: List<String>.from(merchant['shopTypeIds'] ?? []),
      shopTypeNames: List<String>.from(merchant['shopTypeNames'] ?? []),
      dealType: type,
      typeLabel: label,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null,
      isActive: map['isActive'] ?? true,
    );
  }
}