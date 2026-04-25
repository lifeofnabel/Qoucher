class MerchantScan {
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

  const MerchantScan({
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

  MerchantScan copyWith({
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
    return MerchantScan(
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
}