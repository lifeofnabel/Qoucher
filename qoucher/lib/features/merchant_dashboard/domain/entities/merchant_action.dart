class MerchantAction {
  final String id;
  final String merchantId;
  final String shopName;
  final String type;
  final String title;
  final String subtitle;
  final String description;
  final String status;
  final bool isVisible;
  final String? imageUrl;
  final String? linkedItemId;
  final Map<String, dynamic> rules;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MerchantAction({
    required this.id,
    required this.merchantId,
    required this.shopName,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.status,
    required this.isVisible,
    required this.rules,
    this.imageUrl,
    this.linkedItemId,
    this.startsAt,
    this.endsAt,
    this.createdAt,
    this.updatedAt,
  });

  MerchantAction copyWith({
    String? id,
    String? merchantId,
    String? shopName,
    String? type,
    String? title,
    String? subtitle,
    String? description,
    String? status,
    bool? isVisible,
    String? imageUrl,
    String? linkedItemId,
    Map<String, dynamic>? rules,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantAction(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      shopName: shopName ?? this.shopName,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      status: status ?? this.status,
      isVisible: isVisible ?? this.isVisible,
      imageUrl: imageUrl ?? this.imageUrl,
      linkedItemId: linkedItemId ?? this.linkedItemId,
      rules: rules ?? this.rules,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}