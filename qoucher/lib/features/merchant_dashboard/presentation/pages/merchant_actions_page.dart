import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_actions_controller.dart';

class MerchantActionsPage extends StatefulWidget {
  const MerchantActionsPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantActionsPage> createState() => _MerchantActionsPageState();
}

class _MerchantActionsPageState extends State<MerchantActionsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MerchantActionsController>().loadActions(widget.merchantId);
    });
  }

  Future<void> _pauseAction(String actionId) async {
    final controller = context.read<MerchantActionsController>();
    final success = await controller.pauseAction(
      merchantId: widget.merchantId,
      actionId: actionId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Aktion pausiert' : (controller.errorMessage ?? 'Fehler')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantActionsController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meine aktiven Aktionen'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.activeActions.isEmpty
              ? const Center(child: Text('Keine aktiven Aktionen'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.activeActions.length,
            itemBuilder: (context, index) {
              final action = controller.activeActions[index];

              return Card(
                child: ListTile(
                  title: Text(action.title),
                  subtitle: Text(
                    '${action.subtitle}\nTyp: ${action.type}\nStatus: ${action.status}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.pause_circle_outline),
                    onPressed: controller.isPausing
                        ? null
                        : () => _pauseAction(action.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}