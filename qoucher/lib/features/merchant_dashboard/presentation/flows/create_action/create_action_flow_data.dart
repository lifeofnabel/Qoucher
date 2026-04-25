class CreateActionFlowData {
  final String? type;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? linkedItemId;
  final Map<String, dynamic> rules;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isVisible;
  final String status;

  const CreateActionFlowData({
    this.type,
    this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.linkedItemId,
    this.rules = const {},
    this.startsAt,
    this.endsAt,
    this.isVisible = true,
    this.status = 'draft',
  });

  CreateActionFlowData copyWith({
    String? type,
    String? title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? linkedItemId,
    Map<String, dynamic>? rules,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isVisible,
    String? status,
  }) {
    return CreateActionFlowData(
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      linkedItemId: linkedItemId ?? this.linkedItemId,
      rules: rules ?? this.rules,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      isVisible: isVisible ?? this.isVisible,
      status: status ?? this.status,
    );
  }
}