import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantItemModel {
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

  const MerchantItemModel({
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

  factory MerchantItemModel.fromMap(
      Map<String, dynamic> map, {
        String? documentId,
      }) {
    return MerchantItemModel(
      id: documentId ?? (map['id'] ?? '') as String,
      merchantId: (map['merchantId'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      originalPrice: _readDouble(map['originalPrice']),
      imageUrl: (map['imageUrl'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      isActive: (map['isActive'] ?? true) as bool,
      createdAt: _readDateTime(map['createdAt']),
      updatedAt: _readDateTime(map['updatedAt']),
    );
  }

  factory MerchantItemModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return MerchantItemModel.fromMap(data, documentId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'title': title,
      'description': description,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  MerchantItemModel copyWith({
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
    return MerchantItemModel(
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

  static double _readDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}