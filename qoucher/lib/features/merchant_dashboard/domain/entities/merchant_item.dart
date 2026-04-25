class MerchantItem {
  final String id;
  final String merchantId;
  final String title;
  final String description;
  final double originalPrice;
  final String imageUrl;
  final String category;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MerchantItem({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  MerchantItem copyWith({
    String? id,
    String? merchantId,
    String? title,
    String? description,
    double? originalPrice,
    String? imageUrl,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantItem(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      title: title ?? this.title,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}