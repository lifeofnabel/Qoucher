import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantRewardModel {
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

  const MerchantRewardModel({
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

  factory MerchantRewardModel.fromMap(
      Map<String, dynamic> map, {
        String? documentId,
      }) {
    return MerchantRewardModel(
      id: documentId ?? (map['id'] ?? '') as String,
      merchantId: (map['merchantId'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      rewardType: (map['rewardType'] ?? '') as String,
      linkedItemId: map['linkedItemId'] as String?,
      requiredPoints: _readIntOrNull(map['requiredPoints']),
      conditions: Map<String, dynamic>.from(map['conditions'] ?? {}),
      isActive: (map['isActive'] ?? true) as bool,
      createdAt: _readDateTime(map['createdAt']),
      updatedAt: _readDateTime(map['updatedAt']),
    );
  }

  factory MerchantRewardModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return MerchantRewardModel.fromMap(data, documentId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'title': title,
      'description': description,
      'rewardType': rewardType,
      'linkedItemId': linkedItemId,
      'requiredPoints': requiredPoints,
      'conditions': conditions,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  MerchantRewardModel copyWith({
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
    return MerchantRewardModel(
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

  static int? _readIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}