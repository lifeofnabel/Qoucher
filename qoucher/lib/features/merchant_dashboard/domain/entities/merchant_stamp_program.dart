class MerchantStampProgram {
  final String id;
  final String merchantId;
  final String programType;
  final String stampCardName;
  final int requiredStamps;
  final Map<String, dynamic> conditions;
  final bool isEnabled;
  final DateTime? updatedAt;

  const MerchantStampProgram({
    required this.id,
    required this.merchantId,
    required this.programType,
    required this.stampCardName,
    required this.requiredStamps,
    required this.conditions,
    required this.isEnabled,
    this.updatedAt,
  });

  MerchantStampProgram copyWith({
    String? id,
    String? merchantId,
    String? programType,
    String? stampCardName,
    int? requiredStamps,
    Map<String, dynamic>? conditions,
    bool? isEnabled,
    DateTime? updatedAt,
  }) {
    return MerchantStampProgram(
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
}