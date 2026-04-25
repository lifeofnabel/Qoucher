class LoyaltyAccount {
  final String id;
  final String userId;
  final String merchantId;
  final String merchantName;
  final String loyaltyType;
  final int points;
  final int stamps;
  final DateTime? updatedAt;

  const LoyaltyAccount({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.merchantName,
    required this.loyaltyType,
    required this.points,
    required this.stamps,
    this.updatedAt,
  });

  bool get usesPoints => loyaltyType == 'points';
  bool get usesStamps => loyaltyType == 'stamps';

  LoyaltyAccount copyWith({
    String? id,
    String? userId,
    String? merchantId,
    String? merchantName,
    String? loyaltyType,
    int? points,
    int? stamps,
    DateTime? updatedAt,
  }) {
    return LoyaltyAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      loyaltyType: loyaltyType ?? this.loyaltyType,
      points: points ?? this.points,
      stamps: stamps ?? this.stamps,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory LoyaltyAccount.fromMap(Map<String, dynamic> map) {
    return LoyaltyAccount(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      merchantId: map['merchantId']?.toString() ?? '',
      merchantName: map['merchantName']?.toString() ?? '',
      loyaltyType: map['loyaltyType']?.toString() ?? 'points',
      points: _parseInt(map['points']) ?? 0,
      stamps: _parseInt(map['stamps']) ?? 0,
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'loyaltyType': loyaltyType,
      'points': points,
      'stamps': stamps,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() {
    return 'LoyaltyAccount(id: $id, userId: $userId, merchantId: $merchantId, merchantName: $merchantName, loyaltyType: $loyaltyType, points: $points, stamps: $stamps, updatedAt: $updatedAt)';
  }
}