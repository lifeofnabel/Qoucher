import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_points_controller.dart';

class MerchantPointsSystemPage extends StatefulWidget {
  const MerchantPointsSystemPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantPointsSystemPage> createState() =>
      _MerchantPointsSystemPageState();
}

class _MerchantPointsSystemPageState extends State<MerchantPointsSystemPage> {
  final _pointsPerEuroController = TextEditingController();
  final _boosterTitleController = TextEditingController();
  final _boosterMultiplierController = TextEditingController();
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = context.read<MerchantPointsController>();
      await controller.loadPointsProgram(widget.merchantId);

      final program = controller.pointsProgram;
      if (program != null && mounted) {
        _pointsPerEuroController.text = program.pointsPerEuro.toString();
        _boosterTitleController.text =
            (program.boosterConfig['title'] ?? '').toString();
        _boosterMultiplierController.text =
            (program.boosterConfig['multiplier'] ?? '').toString();
        setState(() {
          _isEnabled = program.isEnabled;
        });
      }
    });
  }

  Future<void> _save() async {
    final controller = context.read<MerchantPointsController>();

    final success = await controller.savePointsProgram(
      merchantId: widget.merchantId,
      isEnabled: _isEnabled,
      pointsPerEuro: double.tryParse(_pointsPerEuroController.text.trim()) ?? 0,
      boosterConfig: {
        'title': _boosterTitleController.text.trim(),
        'multiplier':
        double.tryParse(_boosterMultiplierController.text.trim()) ?? 1,
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Punktesystem gespeichert.' : (controller.errorMessage ?? 'Fehler'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantPointsController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Punktesystem'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Punktesystem aktivieren',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Punktesystem aktiv'),
                subtitle: const Text('Pro Euro Punkte vergeben'),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pointsPerEuroController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Punkte pro €',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Booster / Sonderaktion',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _boosterTitleController,
                decoration: const InputDecoration(
                  labelText: 'Booster Titel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _boosterMultiplierController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Multiplikator (z. B. 2 für doppelte Punkte)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Wie es funktioniert',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Text('• Merchant gibt beim Scan den Betrag ein'),
                      Text('• System berechnet automatisch Punkte'),
                      Text('• Punkte-Booster können zusätzlich Aktionen pushen'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isSaving ? null : _save,
                  child: controller.isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Speichern'),
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
    _pointsPerEuroController.dispose();
    _boosterTitleController.dispose();
    _boosterMultiplierController.dispose();
    super.dispose();
  }
}