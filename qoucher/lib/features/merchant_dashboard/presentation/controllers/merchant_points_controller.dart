import 'package:flutter/material.dart';

enum PointsSystemStatus {
  active,
  paused,
}

enum PointsTransactionType {
  automatic,
  manual,
  rewardRedeemed,
  errorReport,
}

class PointsRewardMilestone {
  final String id;
  final int requiredPoints;
  final String title;
  final String description;
  final bool isActive;

  const PointsRewardMilestone({
    required this.id,
    required this.requiredPoints,
    required this.title,
    required this.description,
    this.isActive = true,
  });

  PointsRewardMilestone copyWith({
    String? id,
    int? requiredPoints,
    String? title,
    String? description,
    bool? isActive,
  }) {
    return PointsRewardMilestone(
      id: id ?? this.id,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}

class WeeklyBonusRule {
  final String id;
  final int weekday; // 1 = Montag, 7 = Sonntag
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double multiplier;
  final bool isActive;

  const WeeklyBonusRule({
    required this.id,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.multiplier,
    this.isActive = true,
  });

  WeeklyBonusRule copyWith({
    String? id,
    int? weekday,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? multiplier,
    bool? isActive,
  }) {
    return WeeklyBonusRule(
      id: id ?? this.id,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      multiplier: multiplier ?? this.multiplier,
      isActive: isActive ?? this.isActive,
    );
  }
}

class DateBonusRule {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final double multiplier;
  final bool isActive;

  const DateBonusRule({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.multiplier,
    this.isActive = true,
  });

  DateBonusRule copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    double? multiplier,
    bool? isActive,
  }) {
    return DateBonusRule(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      multiplier: multiplier ?? this.multiplier,
      isActive: isActive ?? this.isActive,
    );
  }
}

class PointsTransaction {
  final String id;
  final String customerId;
  final String customerName;
  final int points;
  final double? purchaseAmount;
  final PointsTransactionType type;
  final String note;
  final DateTime createdAt;

  const PointsTransaction({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.points,
    required this.type,
    required this.note,
    required this.createdAt,
    this.purchaseAmount,
  });
}

class PointsErrorReport {
  final String id;
  final String customerId;
  final String customerName;
  final String reason;
  final DateTime createdAt;

  const PointsErrorReport({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.reason,
    required this.createdAt,
  });
}

class MerchantPointsController extends ChangeNotifier {
  MerchantPointsController();

  bool _isLoading = false;
  bool _isSaving = false;

  PointsSystemStatus _status = PointsSystemStatus.active;

  double _pointsPerEuro = 1.0;

  final List<WeeklyBonusRule> _weeklyBonusRules = [];
  final List<DateBonusRule> _dateBonusRules = [];
  final List<PointsRewardMilestone> _rewardMilestones = [];
  final List<PointsTransaction> _transactions = [];
  final List<PointsErrorReport> _errorReports = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  PointsSystemStatus get status => _status;
  bool get isActive => _status == PointsSystemStatus.active;
  bool get isPaused => _status == PointsSystemStatus.paused;

  double get pointsPerEuro => _pointsPerEuro;

  List<WeeklyBonusRule> get weeklyBonusRules =>
      List.unmodifiable(_weeklyBonusRules);

  List<DateBonusRule> get dateBonusRules =>
      List.unmodifiable(_dateBonusRules);

  List<PointsRewardMilestone> get rewardMilestones {
    final sorted = [..._rewardMilestones];
    sorted.sort((a, b) => a.requiredPoints.compareTo(b.requiredPoints));
    return List.unmodifiable(sorted);
  }

  List<PointsTransaction> get transactions {
    final sorted = [..._transactions];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  List<PointsErrorReport> get errorReports {
    final sorted = [..._errorReports];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  int get totalPointsGiven {
    return _transactions
        .where((t) =>
    t.type == PointsTransactionType.automatic ||
        t.type == PointsTransactionType.manual)
        .fold<int>(0, (sum, t) => sum + t.points);
  }

  int get manualPointsGiven {
    return _transactions
        .where((t) => t.type == PointsTransactionType.manual)
        .fold<int>(0, (sum, t) => sum + t.points);
  }

  int get automaticPointsGiven {
    return _transactions
        .where((t) => t.type == PointsTransactionType.automatic)
        .fold<int>(0, (sum, t) => sum + t.points);
  }

  int get redeemedRewardsCount {
    return _transactions
        .where((t) => t.type == PointsTransactionType.rewardRedeemed)
        .length;
  }

  int get errorReportsCount => _errorReports.length;

  int get todayPointsGiven {
    final now = DateTime.now();

    return _transactions.where((t) {
      final date = t.createdAt;
      final isToday =
          date.year == now.year && date.month == now.month && date.day == now.day;

      final isPointGiving =
          t.type == PointsTransactionType.automatic ||
              t.type == PointsTransactionType.manual;

      return isToday && isPointGiving;
    }).fold<int>(0, (sum, t) => sum + t.points);
  }

  Future<void> loadPointsSystem(String merchantId) async {
    _setLoading(true);

    try {
      // TODO später Firebase:
      // merchants/{merchantId}/pointsSystem/main

      await Future.delayed(const Duration(milliseconds: 250));

      _status = PointsSystemStatus.active;
      _pointsPerEuro = 1.0;

      _weeklyBonusRules
        ..clear()
        ..addAll([
          WeeklyBonusRule(
            id: 'weekly_1',
            weekday: 1,
            startTime: const TimeOfDay(hour: 14, minute: 0),
            endTime: const TimeOfDay(hour: 17, minute: 0),
            multiplier: 2.0,
          ),
        ]);

      _dateBonusRules
        ..clear()
        ..addAll([
          DateBonusRule(
            id: 'date_1',
            title: 'Sommer Bonus',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 14)),
            multiplier: 1.5,
          ),
        ]);

      _rewardMilestones
        ..clear()
        ..addAll([
          const PointsRewardMilestone(
            id: 'reward_50',
            requiredPoints: 50,
            title: 'Gratis Getränk',
            description: 'Kunde bekommt ein kleines Getränk gratis.',
          ),
          const PointsRewardMilestone(
            id: 'reward_100',
            requiredPoints: 100,
            title: '5 € Rabatt',
            description: 'Kunde bekommt 5 € Rabatt auf den Einkauf.',
          ),
          const PointsRewardMilestone(
            id: 'reward_200',
            requiredPoints: 200,
            title: 'Gratis Menü',
            description: 'Kunde bekommt ein ausgewähltes Menü gratis.',
          ),
        ]);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> savePointsSystem(String merchantId) async {
    _setSaving(true);

    try {
      // TODO später Firebase speichern:
      // merchants/{merchantId}/pointsSystem/main

      await Future.delayed(const Duration(milliseconds: 250));
    } finally {
      _setSaving(false);
    }
  }

  void activateSystem() {
    _status = PointsSystemStatus.active;
    notifyListeners();
  }

  void pauseSystem() {
    _status = PointsSystemStatus.paused;
    notifyListeners();
  }

  void updatePointsPerEuro(double value) {
    if (value <= 0) return;

    _pointsPerEuro = value;
    notifyListeners();
  }

  int calculateBasePoints(double purchaseAmount) {
    if (purchaseAmount <= 0) return 0;

    return (purchaseAmount * _pointsPerEuro).floor();
  }

  double getCurrentMultiplier({DateTime? now}) {
    final current = now ?? DateTime.now();

    double multiplier = 1.0;

    for (final rule in _weeklyBonusRules) {
      if (!rule.isActive) continue;
      if (rule.weekday != current.weekday) continue;

      if (_isTimeInsideRange(
        currentTime: TimeOfDay.fromDateTime(current),
        start: rule.startTime,
        end: rule.endTime,
      )) {
        if (rule.multiplier > multiplier) {
          multiplier = rule.multiplier;
        }
      }
    }

    for (final rule in _dateBonusRules) {
      if (!rule.isActive) continue;

      final startsBeforeOrToday = !current.isBefore(rule.startDate);
      final endsAfterOrToday = !current.isAfter(rule.endDate);

      if (startsBeforeOrToday && endsAfterOrToday) {
        if (rule.multiplier > multiplier) {
          multiplier = rule.multiplier;
        }
      }
    }

    return multiplier;
  }

  int calculateFinalPoints(double purchaseAmount, {DateTime? now}) {
    final basePoints = calculateBasePoints(purchaseAmount);
    final multiplier = getCurrentMultiplier(now: now);

    return (basePoints * multiplier).floor();
  }

  Future<void> assignPointsFromAmount({
    required String customerId,
    required String customerName,
    required double purchaseAmount,
  }) async {
    if (!isActive) return;
    if (purchaseAmount <= 0) return;

    final points = calculateFinalPoints(purchaseAmount);

    if (points <= 0) return;

    final transaction = PointsTransaction(
      id: _generateId('auto_points'),
      customerId: customerId,
      customerName: customerName,
      points: points,
      purchaseAmount: purchaseAmount,
      type: PointsTransactionType.automatic,
      note: 'Automatisch aus Einkauf berechnet',
      createdAt: DateTime.now(),
    );

    _transactions.add(transaction);
    notifyListeners();

    // TODO später Firebase:
    // merchants/{merchantId}/pointsTransactions/{transactionId}
    // users/{customerId}/merchantPoints/{merchantId}
  }

  Future<void> assignManualPoints({
    required String customerId,
    required String customerName,
    required int points,
    required String note,
  }) async {
    if (!isActive) return;
    if (points <= 0) return;

    final transaction = PointsTransaction(
      id: _generateId('manual_points'),
      customerId: customerId,
      customerName: customerName,
      points: points,
      type: PointsTransactionType.manual,
      note: note.trim().isEmpty ? 'Manuelle Punktevergabe' : note.trim(),
      createdAt: DateTime.now(),
    );

    _transactions.add(transaction);
    notifyListeners();

    // TODO später Firebase speichern.
  }

  Future<void> redeemReward({
    required String customerId,
    required String customerName,
    required PointsRewardMilestone reward,
  }) async {
    if (!isActive) return;
    if (!reward.isActive) return;

    final transaction = PointsTransaction(
      id: _generateId('reward_redeemed'),
      customerId: customerId,
      customerName: customerName,
      points: -reward.requiredPoints,
      type: PointsTransactionType.rewardRedeemed,
      note: 'Reward eingelöst: ${reward.title}',
      createdAt: DateTime.now(),
    );

    _transactions.add(transaction);
    notifyListeners();

    // TODO später Firebase:
    // User-Punkte reduzieren erst bei Reward-Einlösung erlaubt.
  }

  Future<void> reportPointsError({
    required String customerId,
    required String customerName,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) return;

    final report = PointsErrorReport(
      id: _generateId('points_error'),
      customerId: customerId,
      customerName: customerName,
      reason: reason.trim(),
      createdAt: DateTime.now(),
    );

    _errorReports.add(report);

    final transaction = PointsTransaction(
      id: _generateId('error_report'),
      customerId: customerId,
      customerName: customerName,
      points: 0,
      type: PointsTransactionType.errorReport,
      note: reason.trim(),
      createdAt: DateTime.now(),
    );

    _transactions.add(transaction);
    notifyListeners();

    // Wichtig:
    // Keine Punkte abziehen.
    // Nur Report für spätere Kontrolle.
  }

  void addWeeklyBonusRule({
    required int weekday,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required double multiplier,
  }) {
    if (weekday < 1 || weekday > 7) return;
    if (multiplier <= 1) return;

    final rule = WeeklyBonusRule(
      id: _generateId('weekly_bonus'),
      weekday: weekday,
      startTime: startTime,
      endTime: endTime,
      multiplier: multiplier,
    );

    _weeklyBonusRules.add(rule);
    notifyListeners();
  }

  void updateWeeklyBonusRule(WeeklyBonusRule updatedRule) {
    final index = _weeklyBonusRules.indexWhere((r) => r.id == updatedRule.id);
    if (index == -1) return;

    _weeklyBonusRules[index] = updatedRule;
    notifyListeners();
  }

  void deleteWeeklyBonusRule(String id) {
    _weeklyBonusRules.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void toggleWeeklyBonusRule(String id) {
    final index = _weeklyBonusRules.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final current = _weeklyBonusRules[index];

    _weeklyBonusRules[index] = current.copyWith(
      isActive: !current.isActive,
    );

    notifyListeners();
  }

  void addDateBonusRule({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required double multiplier,
  }) {
    if (title.trim().isEmpty) return;
    if (endDate.isBefore(startDate)) return;
    if (multiplier <= 1) return;

    final rule = DateBonusRule(
      id: _generateId('date_bonus'),
      title: title.trim(),
      startDate: startDate,
      endDate: endDate,
      multiplier: multiplier,
    );

    _dateBonusRules.add(rule);
    notifyListeners();
  }

  void updateDateBonusRule(DateBonusRule updatedRule) {
    final index = _dateBonusRules.indexWhere((r) => r.id == updatedRule.id);
    if (index == -1) return;

    _dateBonusRules[index] = updatedRule;
    notifyListeners();
  }

  void deleteDateBonusRule(String id) {
    _dateBonusRules.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void toggleDateBonusRule(String id) {
    final index = _dateBonusRules.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final current = _dateBonusRules[index];

    _dateBonusRules[index] = current.copyWith(
      isActive: !current.isActive,
    );

    notifyListeners();
  }

  void addRewardMilestone({
    required int requiredPoints,
    required String title,
    required String description,
  }) {
    if (requiredPoints <= 0) return;
    if (title.trim().isEmpty) return;

    final reward = PointsRewardMilestone(
      id: _generateId('points_reward'),
      requiredPoints: requiredPoints,
      title: title.trim(),
      description: description.trim(),
    );

    _rewardMilestones.add(reward);
    notifyListeners();
  }

  void updateRewardMilestone(PointsRewardMilestone updatedReward) {
    final index =
    _rewardMilestones.indexWhere((reward) => reward.id == updatedReward.id);

    if (index == -1) return;

    _rewardMilestones[index] = updatedReward;
    notifyListeners();
  }

  void deleteRewardMilestone(String id) {
    _rewardMilestones.removeWhere((reward) => reward.id == id);
    notifyListeners();
  }

  void toggleRewardMilestone(String id) {
    final index = _rewardMilestones.indexWhere((reward) => reward.id == id);
    if (index == -1) return;

    final current = _rewardMilestones[index];

    _rewardMilestones[index] = current.copyWith(
      isActive: !current.isActive,
    );

    notifyListeners();
  }

  PointsRewardMilestone? getNextRewardForPoints(int currentPoints) {
    final activeRewards =
    rewardMilestones.where((reward) => reward.isActive).toList();

    for (final reward in activeRewards) {
      if (reward.requiredPoints > currentPoints) {
        return reward;
      }
    }

    return null;
  }

  PointsRewardMilestone? getBestAvailableReward(int currentPoints) {
    final availableRewards = rewardMilestones
        .where((reward) =>
    reward.isActive && reward.requiredPoints <= currentPoints)
        .toList();

    if (availableRewards.isEmpty) return null;

    availableRewards.sort(
          (a, b) => b.requiredPoints.compareTo(a.requiredPoints),
    );

    return availableRewards.first;
  }

  double getProgressToNextReward(int currentPoints) {
    final nextReward = getNextRewardForPoints(currentPoints);

    if (nextReward == null) return 1.0;

    return (currentPoints / nextReward.requiredPoints).clamp(0.0, 1.0);
  }

  String getStatusLabel() {
    switch (_status) {
      case PointsSystemStatus.active:
        return 'Aktiv';
      case PointsSystemStatus.paused:
        return 'Pausiert';
    }
  }

  String weekdayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return 'Montag';
      case 2:
        return 'Dienstag';
      case 3:
        return 'Mittwoch';
      case 4:
        return 'Donnerstag';
      case 5:
        return 'Freitag';
      case 6:
        return 'Samstag';
      case 7:
        return 'Sonntag';
      default:
        return 'Unbekannt';
    }
  }

  bool _isTimeInsideRange({
    required TimeOfDay currentTime,
    required TimeOfDay start,
    required TimeOfDay end,
  }) {
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  String _generateId(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
}