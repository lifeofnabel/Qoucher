class Area {
  final String id;
  final String name;
  final bool isActive;

  const Area({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  Area copyWith({
    String? id,
    String? name,
    bool? isActive,
  }) {
    return Area(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      isActive: map['isActive'] is bool ? map['isActive'] as bool : true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'Area(id: $id, name: $name, isActive: $isActive)';
  }

  static List<Area> defaultAreas = const [
    Area(id: 'westend', name: 'Westend'),
    Area(id: 'innenstadt', name: 'Innenstadt'),
    Area(id: 'sachsenhausen', name: 'Sachsenhausen'),
    Area(id: 'nordend', name: 'Nordend'),
    Area(id: 'frankfurt_sued', name: 'Frankfurt Süd'),
    Area(id: 'frankfurt_berg', name: 'Frankfurt Berg'),
  ];
}