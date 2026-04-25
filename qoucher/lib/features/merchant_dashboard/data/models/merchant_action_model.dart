import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantActionModel {
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

  const MerchantActionModel({
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

  factory MerchantActionModel.fromMap(
      Map<String, dynamic> map, {
        String? documentId,
      }) {
    return MerchantActionModel(
      id: documentId ?? (map['id'] ?? '') as String,
      merchantId: (map['merchantId'] ?? '') as String,
      shopName: (map['shopName'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      subtitle: (map['subtitle'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      status: (map['status'] ?? 'draft') as String,
      isVisible: (map['isVisible'] ?? true) as bool,
      imageUrl: map['imageUrl'] as String?,
      linkedItemId: map['linkedItemId'] as String?,
      rules: Map<String, dynamic>.from(map['rules'] ?? {}),
      startsAt: _readDateTime(map['startsAt']),
      endsAt: _readDateTime(map['endsAt']),
      createdAt: _readDateTime(map['createdAt']),
      updatedAt: _readDateTime(map['updatedAt']),
    );
  }

  factory MerchantActionModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return MerchantActionModel.fromMap(data, documentId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'shopName': shopName,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'status': status,
      'isVisible': isVisible,
      'imageUrl': imageUrl,
      'linkedItemId': linkedItemId,
      'rules': rules,
      'startsAt': startsAt != null ? Timestamp.fromDate(startsAt!) : null,
      'endsAt': endsAt != null ? Timestamp.fromDate(endsAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  MerchantActionModel copyWith({
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
    return MerchantActionModel(
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

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}