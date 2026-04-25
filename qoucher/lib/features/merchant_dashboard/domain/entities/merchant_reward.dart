class MerchantReward {
  final String id;
  final String merchantId;
  final String title;
  final String description;
  final String rewardType;
  final String? linkedItemId;
  final int? requiredPoints;
  final Map<String, dynamic> conditions;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MerchantReward({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.description,
    required this.rewardType,
    required this.conditions,
    required this.isActive,
    this.linkedItemId,
    this.requiredPoints,
    this.createdAt,
    this.updatedAt,
  });

  MerchantReward copyWith({
    String? id,
    String? merchantId,
    String? title,
    String? description,
    String? rewardType,
    String? linkedItemId,
    int? requiredPoints,
    Map<String, dynamic>? conditions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantReward(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardType: rewardType ?? this.rewardType,
      linkedItemId: linkedItemId ?? this.linkedItemId,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      conditions: conditions ?? this.conditions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}