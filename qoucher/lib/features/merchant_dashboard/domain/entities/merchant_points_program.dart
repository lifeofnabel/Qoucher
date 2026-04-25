class MerchantPointsProgram {
  final String id;
  final String merchantId;
  final String programType;
  final bool isEnabled;
  final double pointsPerEuro;
  final Map<String, dynamic> boosterConfig;
  final DateTime? updatedAt;

  const MerchantPointsProgram({
    required this.id,
    required this.merchantId,
    required this.programType,
    required this.isEnabled,
    required this.pointsPerEuro,
    required this.boosterConfig,
    this.updatedAt,
  });

  MerchantPointsProgram copyWith({
    String? id,
    String? merchantId,
    String? programType,
    bool? isEnabled,
    double? pointsPerEuro,
    Map<String, dynamic>? boosterConfig,
    DateTime? updatedAt,
  }) {
    return MerchantPointsProgram(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      programType: programType ?? this.programType,
      isEnabled: isEnabled ?? this.isEnabled,
      pointsPerEuro: pointsPerEuro ?? this.pointsPerEuro,
      boosterConfig: boosterConfig ?? this.boosterConfig,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}