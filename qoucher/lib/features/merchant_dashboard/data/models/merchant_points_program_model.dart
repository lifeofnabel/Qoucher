import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantPointsProgramModel {
  final String id;
  final String merchantId;
  final String programType;
  final bool isEnabled;
  final double pointsPerEuro;
  final Map<String, dynamic> boosterConfig;
  final DateTime? updatedAt;

  const MerchantPointsProgramModel({
    required this.id,
    required this.merchantId,
    required this.programType,
    required this.isEnabled,
    required this.pointsPerEuro,
    required this.boosterConfig,
    this.updatedAt,
  });

  factory MerchantPointsProgramModel.fromMap(
      Map<String, dynamic> map, {
        String? documentId,
      }) {
    return MerchantPointsProgramModel(
      id: documentId ?? (map['id'] ?? '') as String,
      merchantId: (map['merchantId'] ?? '') as String,
      programType: (map['programType'] ?? 'points') as String,
      isEnabled: (map['isEnabled'] ?? false) as bool,
      pointsPerEuro: _readDouble(map['pointsPerEuro']),
      boosterConfig: Map<String, dynamic>.from(map['boosterConfig'] ?? {}),
      updatedAt: _readDateTime(map['updatedAt']),
    );
  }

  factory MerchantPointsProgramModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return MerchantPointsProgramModel.fromMap(data, documentId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'programType': programType,
      'isEnabled': isEnabled,
      'pointsPerEuro': pointsPerEuro,
      'boosterConfig': boosterConfig,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  MerchantPointsProgramModel copyWith({
    String? id,
    String? merchantId,
    String? programType,
    bool? isEnabled,
    double? pointsPerEuro,
    Map<String, dynamic>? boosterConfig,
    DateTime? updatedAt,
  }) {
    return MerchantPointsProgramModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      programType: programType ?? this.programType,
      isEnabled: isEnabled ?? this.isEnabled,
      pointsPerEuro: pointsPerEuro ?? this.pointsPerEuro,
      boosterConfig: boosterConfig ?? this.boosterConfig,
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