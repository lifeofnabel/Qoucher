class Reward {
  final String id;
  final String merchantId;
  final String title;
  final String description;
  final String rewardType;
  final int? costPoints;
  final int? requiredStamps;
  final bool isActive;

  const Reward({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.description,
    required this.rewardType,
    this.costPoints,
    this.requiredStamps,
    required this.isActive,
  });

  bool get usesPoints => costPoints != null;
  bool get usesStamps => requiredStamps != null;

  Reward copyWith({
    String? id,
    String? merchantId,
    String? title,
    String? description,
    String? rewardType,
    int? costPoints,
    int? requiredStamps,
    bool? isActive,
  }) {
    return Reward(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardType: rewardType ?? this.rewardType,
      costPoints: costPoints ?? this.costPoints,
      requiredStamps: requiredStamps ?? this.requiredStamps,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id']?.toString() ?? '',
      merchantId: map['merchantId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      rewardType: map['rewardType']?.toString() ?? '',
      costPoints: _parseInt(map['costPoints']),
      requiredStamps: _parseInt(map['requiredStamps']),
      isActive: map['isActive'] is bool ? map['isActive'] as bool : true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchantId': merchantId,
      'title': title,
      'description': description,
      'rewardType': rewardType,
      'costPoints': costPoints,
      'requiredStamps': requiredStamps,
      'isActive': isActive,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  @override
  String toString() {
    return 'Reward(id: $id, merchantId: $merchantId, title: $title, description: $description, rewardType: $rewardType, costPoints: $costPoints, requiredStamps: $requiredStamps, isActive: $isActive)';
  }
}