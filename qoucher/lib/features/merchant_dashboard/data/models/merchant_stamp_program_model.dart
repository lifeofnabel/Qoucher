import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantStampProgramModel {
  final String id;
  final String merchantId;
  final String programType;
  final String stampCardName;
  final int requiredStamps;
  final Map<String, dynamic> conditions;
  final bool isEnabled;
  final DateTime? updatedAt;

  const MerchantStampProgramModel({
    required this.id,
    required this.merchantId,
    required this.programType,
    required this.stampCardName,
    required this.requiredStamps,
    required this.conditions,
    required this.isEnabled,
    this.updatedAt,
  });

  factory MerchantStampProgramModel.fromMap(
      Map<String, dynamic> map, {
        String? documentId,
      }) {
    return MerchantStampProgramModel(
      id: documentId ?? (map['id'] ?? '') as String,
      merchantId: (map['merchantId'] ?? '') as String,
      programType: (map['programType'] ?? 'stamp') as String,
      stampCardName: (map['stampCardName'] ?? '') as String,
      requiredStamps: _readInt(map['requiredStamps']),
      conditions: Map<String, dynamic>.from(map['conditions'] ?? {}),
      isEnabled: (map['isEnabled'] ?? false) as bool,
      updatedAt: _readDateTime(map['updatedAt']),
    );
  }

  factory MerchantStampProgramModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return MerchantStampProgramModel.fromMap(data, documentId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'programType': programType,
      'stampCardName': stampCardName,
      'requiredStamps': requiredStamps,
      'conditions': conditions,
      'isEnabled': isEnabled,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  MerchantStampProgramModel copyWith({
    String? id,
    String? merchantId,
    String? programType,
    String? stampCardName,
    int? requiredStamps,
    Map<String, dynamic>? conditions,
    bool? isEnabled,
    DateTime? updatedAt,
  }) {
    return MerchantStampProgramModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      programType: programType ?? this.programType,
      stampCardName: stampCardName ?? this.stampCardName,
      requiredStamps: requiredStamps ?? this.requiredStamps,
      conditions: conditions ?? this.conditions,
      isEnabled: isEnabled ?? this.isEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _readInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}