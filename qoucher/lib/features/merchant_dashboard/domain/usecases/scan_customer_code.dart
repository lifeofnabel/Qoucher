import 'package:qoucher/features/merchant_dashboard/data/models/merchant_scan_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class GetScannedHistory {
  final MerchantDashboardRepositoryContract repository;

  const GetScannedHistory(this.repository);

  Future<List<MerchantScanModel>> call(String merchantId) {
    return repository.getScannedHistory(merchantId);
  }
}