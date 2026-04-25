class LoyaltyTransaction {
  final String id;
  final String userId;
  final String merchantId;
  final String type;
  final int value;
  final String? note;
  final String? rewardId;
  final DateTime? createdAt;

  const LoyaltyTransaction({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.type,
    required this.value,
    this.note,
    this.rewardId,
    this.createdAt,
  });

  bool get isPointsTransaction => type == 'add_points';
  bool get isStampTransaction => type == 'add_stamp';
  bool get isRewardRedemption => type == 'redeem_reward';

  LoyaltyTransaction copyWith({
    String? id,
    String? userId,
    String? merchantId,
    String? type,
    int? value,
    String? note,
    String? rewardId,
    DateTime? createdAt,
  }) {
    return LoyaltyTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchantId: merchantId ?? this.merchantId,
      type: type ?? this.type,
      value: value ?? this.value,
      note: note ?? this.note,
      rewardId: rewardId ?? this.rewardId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory LoyaltyTransaction.fromMap(Map<String, dynamic> map) {
    return LoyaltyTransaction(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      merchantId: map['merchantId']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      value: _parseInt(map['value']) ?? 0,
      note: map['note']?.toString(),
      rewardId: map['rewardId']?.toString(),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'merchantId': merchantId,
      'type': type,
      'value': value,
      'note': note,
      'rewardId': rewardId,
      'createdAt': createdAt?.toIso8601String(),
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
    return 'LoyaltyTransaction(id: $id, userId: $userId, merchantId: $merchantId, type: $type, value: $value, note: $note, rewardId: $rewardId, createdAt: $createdAt)';
  }
}