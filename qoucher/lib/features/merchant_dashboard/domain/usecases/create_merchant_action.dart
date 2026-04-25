import 'package:qoucher/features/merchant_dashboard/domain/repositories/merchant_dashboard_repository_contract.dart';

class CreateMerchantAction {
  final MerchantDashboardRepositoryContract repository;

  const CreateMerchantAction(this.repository);

  Future<String> call({
    required String merchantId,
    required String shopName,
    required String type,
    required String title,
    required String subtitle,
    required String description,
    required String status,
    required bool isVisible,
    String? imageUrl,
    String? linkedItemId,
    Map<String, dynamic>? rules,
    DateTime? startsAt,
    DateTime? endsAt,
  }) {
    return repository.createAction(
      merchantId: merchantId,
      shopName: shopName,
      type: type,
      title: title,
      subtitle: subtitle,
      description: description,
      status: status,
      isVisible: isVisible,
      imageUrl: imageUrl,
      linkedItemId: linkedItemId,
      rules: rules,
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }
}