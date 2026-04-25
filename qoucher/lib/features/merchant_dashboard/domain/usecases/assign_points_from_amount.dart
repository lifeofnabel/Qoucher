import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class AssignPointsFromAmount {
  final MerchantDashboardRepositoryContract repository;

  const AssignPointsFromAmount(this.repository);

  Future<void> call({
    required String merchantId,
    required String customerId,
    required double amount,
    required double pointsPerEuro,
    String? comment,
  }) {
    return repository.addPointsFromAmount(
      merchantId: merchantId,
      customerId: customerId,
      amount: amount,
      pointsPerEuro: pointsPerEuro,
      comment: comment,
    );
  }
}