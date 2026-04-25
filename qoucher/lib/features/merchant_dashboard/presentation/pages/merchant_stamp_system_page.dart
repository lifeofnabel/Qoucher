import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_stamp_controller.dart';

class MerchantStampSystemPage extends StatefulWidget {
  const MerchantStampSystemPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantStampSystemPage> createState() =>
      _MerchantStampSystemPageState();
}

class _MerchantStampSystemPageState extends State<MerchantStampSystemPage> {
  final _stampCardNameController = TextEditingController();
  final _requiredStampsController = TextEditingController();
  final _conditionTypeController = TextEditingController();
  final _conditionValueController = TextEditingController();
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MerchantStampController>().loadStampPrograms(widget.merchantId);
    });
  }

  Future<void> _saveStampProgram() async {
    final controller = context.read<MerchantStampController>();

    final success = await controller.saveStampProgram(
      merchantId: widget.merchantId,
      isEnabled: _isEnabled,
      stampCardName: _stampCardNameController.text.trim(),
      requiredStamps: int.tryParse(_requiredStampsController.text.trim()) ?? 0,
      conditions: {
        'type': _conditionTypeController.text.trim(),
        'value': _conditionValueController.text.trim(),
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Stempelkarte gespeichert.' : (controller.errorMessage ?? 'Fehler')),
      ),
    );

    if (success) {
      _stampCardNameController.clear();
      _requiredStampsController.clear();
      _conditionTypeController.clear();
      _conditionValueController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantStampController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Stempelsystem'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Neue Stempelkarte',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
                title: const Text('Aktiv'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stampCardNameController,
                decoration: const InputDecoration(
                  labelText: 'Name der Stempelkarte',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _requiredStampsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Benötigte Stempel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conditionTypeController,
                decoration: const InputDecoration(
                  labelText: 'Bedingung Typ (z. B. artikel / betrag)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conditionValueController,
                decoration: const InputDecoration(
                  labelText: 'Bedingung Wert',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isSaving ? null : _saveStampProgram,
                  child: controller.isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Stempelkarte speichern'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bestehende Stempelkarten',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (controller.stampPrograms.isEmpty)
                const Text('Noch keine Stempelkarten vorhanden.'),
              ...controller.stampPrograms.map(
                    (program) => Card(
                  child: ListTile(
                    title: Text(program.stampCardName),
                    subtitle: Text(
                      'Benötigte Stempel: ${program.requiredStamps}\n'
                          'Aktiv: ${program.isEnabled ? 'Ja' : 'Nein'}',
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
    _stampCardNameController.dispose();
    _requiredStampsController.dispose();
    _conditionTypeController.dispose();
    _conditionValueController.dispose();
    super.dispose();
  }
}