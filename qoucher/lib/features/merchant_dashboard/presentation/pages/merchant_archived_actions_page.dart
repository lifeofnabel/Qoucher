import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_actions_controller.dart';

class MerchantArchivedActionsPage extends StatefulWidget {
  const MerchantArchivedActionsPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantArchivedActionsPage> createState() =>
      _MerchantArchivedActionsPageState();
}

class _MerchantArchivedActionsPageState
    extends State<MerchantArchivedActionsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MerchantActionsController>().loadActions(widget.merchantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantActionsController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Archivierte Aktionen'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.archivedActions.isEmpty
              ? const Center(child: Text('Kein Archiv vorhanden'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.archivedActions.length,
            itemBuilder: (context, index) {
              final action = controller.archivedActions[index];

              return Card(
                child: ListTile(
                  title: Text(action.title),
                  subtitle: Text(
                    '${action.subtitle}\nTyp: ${action.type}\nStatus: ${action.status}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
    );
  }
}