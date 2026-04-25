import 'package:qoucher/features/merchant_dashboard/data/models/merchant_action_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class GetArchivedActions {
  final MerchantDashboardRepositoryContract repository;

  const GetArchivedActions(this.repository);

  Future<List<MerchantActionModel>> call(String merchantId) {
    return repository.getArchivedActions(merchantId);
  }
}