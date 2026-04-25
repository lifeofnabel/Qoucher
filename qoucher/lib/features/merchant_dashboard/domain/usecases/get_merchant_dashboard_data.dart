import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class GetMerchantDashboardData {
  final MerchantDashboardRepositoryContract repository;

  const GetMerchantDashboardData(this.repository);

  Future<Map<String, dynamic>> call(String merchantId) {
    return repository.getDashboardOverview(merchantId);
  }
}