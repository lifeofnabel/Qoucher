import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_rewards_controller.dart';

class ManageRewardsPage extends StatefulWidget {
  const ManageRewardsPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<ManageRewardsPage> createState() => _ManageRewardsPageState();
}

class _ManageRewardsPageState extends State<ManageRewardsPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardTypeController = TextEditingController();
  final _linkedItemIdController = TextEditingController();
  final _requiredPointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MerchantRewardsController>().loadRewards(widget.merchantId);
    });
  }

  Future<void> _createReward() async {
    final controller = context.read<MerchantRewardsController>();

    final success = await controller.createReward(
      merchantId: widget.merchantId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      rewardType: _rewardTypeController.text.trim().isEmpty
          ? 'reward'
          : _rewardTypeController.text.trim(),
      linkedItemId: _linkedItemIdController.text.trim().isEmpty
          ? null
          : _linkedItemIdController.text.trim(),
      requiredPoints: _requiredPointsController.text.trim().isEmpty
          ? null
          : int.tryParse(_requiredPointsController.text.trim()),
      conditions: {},
    );

    if (!mounted) return;

    if (success) {
      _titleController.clear();
      _descriptionController.clear();
      _rewardTypeController.clear();
      _linkedItemIdController.clear();
      _requiredPointsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reward erstellt')),
      );
    } else if (controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantRewardsController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meine Rewards'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Reward erstellen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rewardTypeController,
                decoration: const InputDecoration(
                  labelText: 'Reward Typ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkedItemIdController,
                decoration: const InputDecoration(
                  labelText: 'Artikel-ID optional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _requiredPointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Benötigte Punkte optional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isSaving ? null : _createReward,
                  child: controller.isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Reward speichern'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bereits erstellt',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (controller.rewards.isEmpty)
                const Text('Noch keine Rewards vorhanden.'),
              ...controller.rewards.map(
                    (reward) => Card(
                  child: ListTile(
                    title: Text(reward.title),
                    subtitle: Text(
                      '${reward.description}\nTyp: ${reward.rewardType}',
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardTypeController.dispose();
    _linkedItemIdController.dispose();
    _requiredPointsController.dispose();
    super.dispose();
  }
}