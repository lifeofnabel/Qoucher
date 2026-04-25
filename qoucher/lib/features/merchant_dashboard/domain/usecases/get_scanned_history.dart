import 'package:qoucher/features/merchant_dashboard/data/models/scanned_customer_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class ScanCustomerByLiveCode {
  final MerchantDashboardRepositoryContract repository;

  const ScanCustomerByLiveCode(this.repository);

  Future<ScannedCustomerModel?> call(String liveCode) {
    return repository.findCustomerByLiveCode(liveCode);
  }
}