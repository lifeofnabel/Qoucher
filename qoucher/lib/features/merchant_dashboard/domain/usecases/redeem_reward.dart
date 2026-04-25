import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class RedeemReward {
  final MerchantDashboardRepositoryContract repository;

  const RedeemReward(this.repository);

  Future<void> call({
    required String merchantId,
    required String customerId,
    required String rewardId,
    String? comment,
  }) {
    return repository.redeemReward(
      merchantId: merchantId,
      customerId: customerId,
      rewardId: rewardId,
      comment: comment,
    );
  }
}