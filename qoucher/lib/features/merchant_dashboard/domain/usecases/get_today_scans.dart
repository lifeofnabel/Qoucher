import 'package:qoucher/features/merchant_dashboard/data/models/merchant_scan_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class GetTodayScans {
  final MerchantDashboardRepositoryContract repository;

  const GetTodayScans(this.repository);

  Future<List<MerchantScanModel>> call(String merchantId) {
    return repository.getTodayScans(merchantId);
  }
}