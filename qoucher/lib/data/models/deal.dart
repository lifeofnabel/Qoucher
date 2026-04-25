class Deal {
  final String id;
  final String merchantId;
  final String title;
  final String description;
  final String category;
  final String area;
  final bool isHot;
  final bool isActive;
  final DateTime? startAt;
  final DateTime? endAt;

  const Deal({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.description,
    required this.category,
    required this.area,
    required this.isHot,
    required this.isActive,
    this.startAt,
    this.endAt,
  });

  Deal copyWith({
    String? id,
    String? merchantId,
    String? title,
    String? description,
    String? category,
    String? area,
    bool? isHot,
    bool? isActive,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return Deal(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      area: area ?? this.area,
      isHot: isHot ?? this.isHot,
      isActive: isActive ?? this.isActive,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
    );
  }

  factory Deal.fromMap(Map<String, dynamic> map) {
    return Deal(
      id: map['id']?.toString() ?? '',
      merchantId: map['merchantId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      isHot: map['isHot'] is bool ? map['isHot'] as bool : false,
      isActive: map['isActive'] is bool ? map['isActive'] as bool : true,
      startAt: _parseDateTime(map['startAt']),
      endAt: _parseDateTime(map['endAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchantId': merchantId,
      'title': title,
      'description': description,
      'category': category,
      'area': area,
      'isHot': isHot,
      'isActive': isActive,
      'startAt': startAt?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
    };
  }

  bool get isCurrentlyRunning {
    final now = DateTime.now();

    if (!isActive) return false;
    if (startAt != null && now.isBefore(startAt!)) return false;
    if (endAt != null && now.isAfter(endAt!)) return false;

    return true;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() {
    return 'Deal(id: $id, merchantId: $merchantId, title: $title, description: $description, category: $category, area: $area, isHot: $isHot, isActive: $isActive, startAt: $startAt, endAt: $endAt)';
  }
}