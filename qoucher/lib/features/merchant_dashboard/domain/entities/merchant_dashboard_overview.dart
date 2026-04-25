import 'merchant_profile.dart';

class MerchantDashboardOverview {
  final MerchantProfile? profile;
  final int activeActionsCount;
  final int archivedActionsCount;
  final int scannedTodayCount;

  const MerchantDashboardOverview({
    required this.profile,
    required this.activeActionsCount,
    required this.archivedActionsCount,
    required this.scannedTodayCount,
  });

  MerchantDashboardOverview copyWith({
    MerchantProfile? profile,
    int? activeActionsCount,
    int? archivedActionsCount,
    int? scannedTodayCount,
  }) {
    return MerchantDashboardOverview(
      profile: profile ?? this.profile,
      activeActionsCount: activeActionsCount ?? this.activeActionsCount,
      archivedActionsCount: archivedActionsCount ?? this.archivedActionsCount,
      scannedTodayCount: scannedTodayCount ?? this.scannedTodayCount,
    );
  }
}