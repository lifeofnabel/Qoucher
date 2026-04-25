class Merchant {
  final String id;
  final String ownerId;
  final String name;
  final String category;
  final String area;
  final String description;
  final String loyaltyType;
  final bool isActive;

  const Merchant({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.area,
    required this.description,
    required this.loyaltyType,
    required this.isActive,
  });

  bool get usesPoints => loyaltyType == 'points';
  bool get usesStamps => loyaltyType == 'stamps';

  Merchant copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? category,
    String? area,
    String? description,
    String? loyaltyType,
    bool? isActive,
  }) {
    return Merchant(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      category: category ?? this.category,
      area: area ?? this.area,
      description: description ?? this.description,
      loyaltyType: loyaltyType ?? this.loyaltyType,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Merchant.fromMap(Map<String, dynamic> map) {
    return Merchant(
      id: map['id']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      loyaltyType: map['loyaltyType']?.toString() ?? 'stamps',
      isActive: map['isActive'] is bool ? map['isActive'] as bool : true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'category': category,
      'area': area,
      'description': description,
      'loyaltyType': loyaltyType,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'Merchant(id: $id, ownerId: $ownerId, name: $name, category: $category, area: $area, description: $description, loyaltyType: $loyaltyType, isActive: $isActive)';
  }
}