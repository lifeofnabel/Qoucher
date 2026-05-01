class ShopType {
  final String id;
  final String name;
  final bool isActive;
  final int sortOrder;

  const ShopType({
    required this.id,
    required this.name,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory ShopType.fromMap(Map<String, dynamic> map) {
    return ShopType(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      isActive: map['isActive'] is bool ? map['isActive'] as bool : true,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  static List<ShopType> defaultShopTypes = const [
    ShopType(id: 'food', name: 'Food', sortOrder: 1),
    ShopType(id: 'kiosk', name: 'Kiosk', sortOrder: 2),
    ShopType(id: 'barber', name: 'Barber', sortOrder: 3),
    ShopType(id: 'beauty', name: 'Beauty', sortOrder: 4),
    ShopType(id: 'cafe', name: 'Café', sortOrder: 5),
    ShopType(id: 'retail', name: 'Retail', sortOrder: 6),
    ShopType(id: 'service', name: 'Service', sortOrder: 7),
  ];
}