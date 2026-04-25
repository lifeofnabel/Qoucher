import 'package:flutter/material.dart';

class CreateActionRulesStep extends StatefulWidget {
  const CreateActionRulesStep({
    super.key,
    required this.initialRules,
    required this.onChanged,
  });

  final Map<String, dynamic> initialRules;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<CreateActionRulesStep> createState() => _CreateActionRulesStepState();
}

class _CreateActionRulesStepState extends State<CreateActionRulesStep> {
  late final TextEditingController _pointsNeededController;
  late final TextEditingController _discountPercentController;
  late final TextEditingController _minAmountController;
  late final TextEditingController _buyXController;
  late final TextEditingController _getYController;

  @override
  void initState() {
    super.initState();
    _pointsNeededController = TextEditingController(
      text: (widget.initialRules['pointsNeeded'] ?? '').toString(),
    );
    _discountPercentController = TextEditingController(
      text: (widget.initialRules['discountPercent'] ?? '').toString(),
    );
    _minAmountController = TextEditingController(
      text: (widget.initialRules['minAmount'] ?? '').toString(),
    );
    _buyXController = TextEditingController(
      text: (widget.initialRules['buyX'] ?? '').toString(),
    );
    _getYController = TextEditingController(
      text: (widget.initialRules['getY'] ?? '').toString(),
    );
  }

  void _emit() {
    widget.onChanged({
      'pointsNeeded': int.tryParse(_pointsNeededController.text.trim()),
      'discountPercent': double.tryParse(_discountPercentController.text.trim()),
      'minAmount': double.tryParse(_minAmountController.text.trim()),
      'buyX': _buyXController.text.trim(),
      'getY': _getYController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bedingungen & Regeln',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pointsNeededController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Benötigte Punkte',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _discountPercentController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Rabatt in %',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _minAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Mindestbetrag',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _buyXController,
          decoration: const InputDecoration(
            labelText: 'Kauf X',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _getYController,
          decoration: const InputDecoration(
            labelText: 'Bekomme Y',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pointsNeededController.dispose();
    _discountPercentController.dispose();
    _minAmountController.dispose();
    _buyXController.dispose();
    _getYController.dispose();
    super.dispose();
  }
}