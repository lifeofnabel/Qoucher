import 'package:flutter/material.dart';
import 'package:qoucher/features/merchant_dashboard/data/models/merchant_action_model.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_active_actions.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/get_archived_actions.dart';
import 'package:qoucher/features/merchant_dashboard/domain/usecases/pause_merchant_action.dart';

class MerchantActionsController extends ChangeNotifier {
  MerchantActionsController({
    required GetActiveActions getActiveActions,
    required GetArchivedActions getArchivedActions,
    required PauseMerchantAction pauseMerchantAction,
  })  : _getActiveActions = getActiveActions,
        _getArchivedActions = getArchivedActions,
        _pauseMerchantAction = pauseMerchantAction;

  final GetActiveActions _getActiveActions;
  final GetArchivedActions _getArchivedActions;
  final PauseMerchantAction _pauseMerchantAction;

  bool isLoading = false;
  bool isPausing = false;
  String? errorMessage;

  List<MerchantActionModel> activeActions = [];
  List<MerchantActionModel> archivedActions = [];

  Future<void> loadActions(String merchantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      activeActions = await _getActiveActions(merchantId);
      archivedActions = await _getArchivedActions(merchantId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pauseAction({
    required String merchantId,
    required String actionId,
  }) async {
    isPausing = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _pauseMerchantAction(actionId);
      await loadActions(merchantId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      isPausing = false;
      notifyListeners();
    }
  }
}