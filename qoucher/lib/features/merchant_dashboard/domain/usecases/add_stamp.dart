import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class AddStamp {
  final MerchantDashboardRepositoryContract repository;

  const AddStamp(this.repository);

  Future<void> call({
    required String merchantId,
    required String customerId,
    required String stampProgramId,
    String? comment,
  }) {
    return repository.addStamp(
      merchantId: merchantId,
      customerId: customerId,
      stampProgramId: stampProgramId,
      comment: comment,
    );
  }
}