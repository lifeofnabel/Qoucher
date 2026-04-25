import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class PauseMerchantAction {
  final MerchantDashboardRepositoryContract repository;

  const PauseMerchantAction(this.repository);

  Future<void> call(String actionId) {
    return repository.pauseAction(actionId);
  }
}