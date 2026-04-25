import 'package:qoucher/features/merchant_dashboard/data/models/merchant_action_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class GetActiveActions {
  final MerchantDashboardRepositoryContract repository;

  const GetActiveActions(this.repository);

  Future<List<MerchantActionModel>> call(String merchantId) {
    return repository.getActiveActions(merchantId);
  }
}