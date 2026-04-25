import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantScanModel {
  final String id;
  final String merchantId;
  final String customerId;
  final String type;
  final double? amount;
  final int? pointsAdded;
  final String? stampProgramId;
  final String? rewardId;
  final String? comment;
  final DateTime? createdAt;

  const MerchantScanModel({
    required this.id,
    required this.merchantId,
    required this.customerId,
    required this.type,
    this.amount,
    this.pointsAdded,
    this.stampProgramId,
    this.rewardId,
    this.comment,
    this.createdAt,
  });

  factory MerchantScanModel.fromMap(
      Map<String, dynamic> map, {
        String? documentId,
      }) {
    return MerchantScanModel(
      id: documentId ?? (map['id'] ?? '') as String,
      merchantId: (map['merchantId'] ?? '') as String,
      customerId: (map['customerId'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      amount: _readDoubleOrNull(map['amount']),
      pointsAdded: _readIntOrNull(map['pointsAdded']),
      stampProgramId: map['stampProgramId'] as String?,
      rewardId: map['rewardId'] as String?,
      comment: map['comment'] as String?,
      createdAt: _readDateTime(map['createdAt']),
    );
  }

  factory MerchantScanModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return MerchantScanModel.fromMap(data, documentId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'customerId': customerId,
      'type': type,
      'amount': amount,
      'pointsAdded': pointsAdded,
      'stampProgramId': stampProgramId,
      'rewardId': rewardId,
      'comment': comment,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  MerchantScanModel copyWith({
    String? id,
    String? merchantId,
    String? customerId,
    String? type,
    double? amount,
    int? pointsAdded,
    String? stampProgramId,
    String? rewardId,
    String? comment,
    DateTime? createdAt,
  }) {
    return MerchantScanModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      pointsAdded: pointsAdded ?? this.pointsAdded,
      stampProgramId: stampProgramId ?? this.stampProgramId,
      rewardId: rewardId ?? this.rewardId,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static double? _readDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString());
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