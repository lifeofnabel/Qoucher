import 'package:flutter/material.dart';

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
  bool isEnabled = true;

  double pointsPerEuro = 1;
  bool fixedRuleEnabled = false;
  double fixedAmount = 10;
  int fixedPoints = 5;

  final Set<int> bonusDays = {};
  double bonusMultiplier = 2;

  final TextEditingController customerCodeController = TextEditingController();
  final TextEditingController purchaseAmountController = TextEditingController();

  int previewPoints = 0;

  final List<String> dayNames = [
    'Mo',
    'Di',
    'Mi',
    'Do',
    'Fr',
    'Sa',
    'So',
  ];

  @override
  void dispose() {
    customerCodeController.dispose();
    purchaseAmountController.dispose();
    super.dispose();
  }

  void _calculatePreview() {
    final amount = double.tryParse(
      purchaseAmountController.text.replaceAll(',', '.'),
    ) ??
        0;

    int result;

    if (fixedRuleEnabled) {
      result = ((amount / fixedAmount) * fixedPoints).floor();
    } else {
      result = (amount * pointsPerEuro).floor();
    }

    setState(() {
      previewPoints = result;
    });
  }

  void _toggleBonusDay(int index) {
    setState(() {
      if (bonusDays.contains(index)) {
        bonusDays.remove(index);
      } else {
        bonusDays.add(index);
      }
    });
  }

  void _showSaveMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Punktesystem gespeichert'),
      ),
    );
  }

  void _assignPoints() {
    _calculatePreview();

    final customerCode = customerCodeController.text.trim();

    if (customerCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Kundencode eingeben'),
        ),
      );
      return;
    }

    if (previewPoints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte gültigen Einkaufsbetrag eingeben'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$previewPoints Punkte wurden vorbereitet'),
      ),
    );
  }

  void _openReportSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Problem melden',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _reportTile(
                icon: Icons.person_search_outlined,
                title: 'Falscher Kunde gescannt',
                subtitle: 'Admin soll den Scan prüfen.',
              ),
              _reportTile(
                icon: Icons.payments_outlined,
                title: 'Falscher Betrag eingegeben',
                subtitle: 'Punkte sollen geprüft werden.',
              ),
              _reportTile(
                icon: Icons.warning_amber_rounded,
                title: 'Verdächtiger Vorgang',
                subtitle: 'Ungewöhnliche Nutzung melden.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reportTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title gemeldet')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ruleText = fixedRuleEnabled
        ? '${fixedAmount.toStringAsFixed(0)} € = $fixedPoints Punkte'
        : '1 € = ${pointsPerEuro.toStringAsFixed(1)} Punkte';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punktesystem'),
        actions: [
          IconButton(
            onPressed: _showSaveMessage,
            icon: const Icon(Icons.check_circle_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(ruleText),
          const SizedBox(height: 16),

          _statusCard(),
          const SizedBox(height: 16),

          _sectionTitle('Punkte-Regel'),
          const SizedBox(height: 10),
          _pointsRuleCard(),

          const SizedBox(height: 18),

          _sectionTitle('Feste Punkte-Regel'),
          const SizedBox(height: 10),
          _fixedRuleCard(),

          const SizedBox(height: 18),

          _sectionTitle('Bonus-Tage'),
          const SizedBox(height: 10),
          _bonusDaysCard(),

          const SizedBox(height: 18),

          _sectionTitle('Punkte vergeben'),
          const SizedBox(height: 10),
          _manualAssignCard(),

          const SizedBox(height: 18),

          _sectionTitle('Sicherheit'),
          const SizedBox(height: 10),
          _reportCard(),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _showSaveMessage,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Einstellungen speichern'),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _heroCard(String ruleText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.18),
            Theme.of(context).colorScheme.primary.withOpacity(0.06),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            ),
            child: Icon(
              Icons.stars_rounded,
              size: 38,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnabled ? 'Punktesystem aktiv' : 'Punktesystem pausiert',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ruleText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kunden sammeln automatisch Punkte pro Einkauf.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return _baseCard(
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.power_settings_new : Icons.pause_circle_outline,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Systemstatus',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled
                      ? 'Kunden können Punkte sammeln.'
                      : 'Punkte sammeln ist pausiert.',
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              setState(() => isEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _pointsRuleCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Standard-Regel',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Merchant entscheidet, wie viele Punkte pro Euro gelten.'),
          const SizedBox(height: 18),

          Row(
            children: [
              const Text(
                '1 € = ',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Expanded(
                child: Slider(
                  value: pointsPerEuro,
                  min: 0.5,
                  max: 10,
                  divisions: 19,
                  label: pointsPerEuro.toStringAsFixed(1),
                  onChanged: fixedRuleEnabled
                      ? null
                      : (value) {
                    setState(() => pointsPerEuro = value);
                    _calculatePreview();
                  },
                ),
              ),
              Text(
                '${pointsPerEuro.toStringAsFixed(1)} Punkte',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _infoBox(
            icon: Icons.lightbulb_outline,
            text:
            'Empfehlung: 1 € = 1 Punkt. Einfach zu verstehen. Weniger Chaos an der Kasse.',
          ),
        ],
      ),
    );
  }

  Widget _fixedRuleCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: fixedRuleEnabled,
            onChanged: (value) {
              setState(() => fixedRuleEnabled = value);
              _calculatePreview();
            },
            title: const Text(
              'Feste Regel aktivieren',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text('Beispiel: 10 € Einkauf = 5 Punkte'),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _numberStepper(
                  title: 'Einkauf',
                  value: '${fixedAmount.toStringAsFixed(0)} €',
                  onMinus: fixedRuleEnabled && fixedAmount > 1
                      ? () {
                    setState(() => fixedAmount--);
                    _calculatePreview();
                  }
                      : null,
                  onPlus: fixedRuleEnabled
                      ? () {
                    setState(() => fixedAmount++);
                    _calculatePreview();
                  }
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberStepper(
                  title: 'Punkte',
                  value: '$fixedPoints',
                  onMinus: fixedRuleEnabled && fixedPoints > 1
                      ? () {
                    setState(() => fixedPoints--);
                    _calculatePreview();
                  }
                      : null,
                  onPlus: fixedRuleEnabled
                      ? () {
                    setState(() => fixedPoints++);
                    _calculatePreview();
                  }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bonusDaysCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doppelte Punkte an bestimmten Tagen',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Beispiel: Montag doppelte Punkte, um ruhige Tage zu pushen.'),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(dayNames.length, (index) {
              final selected = bonusDays.contains(index);

              return ChoiceChip(
                label: Text(dayNames[index]),
                selected: selected,
                onSelected: (_) => _toggleBonusDay(index),
              );
            }),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Text(
                'Bonus:',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Expanded(
                child: Slider(
                  value: bonusMultiplier,
                  min: 2,
                  max: 5,
                  divisions: 3,
                  label: '${bonusMultiplier.toStringAsFixed(0)}x',
                  onChanged: (value) {
                    setState(() => bonusMultiplier = value);
                  },
                ),
              ),
              Text(
                '${bonusMultiplier.toStringAsFixed(0)}x Punkte',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _manualAssignCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manuell Punkte vergeben',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Für Fälle, wo QR-Scan nicht klappt oder Kunde Code zeigt.'),
          const SizedBox(height: 16),

          TextField(
            controller: customerCodeController,
            decoration: InputDecoration(
              labelText: 'Kundencode',
              hintText: 'z. B. QCH-4821',
              prefixIcon: const Icon(Icons.qr_code_2_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: purchaseAmountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculatePreview(),
            decoration: InputDecoration(
              labelText: 'Einkaufsbetrag',
              hintText: 'z. B. 12,50',
              prefixIcon: const Icon(Icons.euro_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            ),
            child: Text(
              'Vorschau: $previewPoints Punkte',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isEnabled ? _assignPoints : null,
              icon: const Icon(Icons.add_card_outlined),
              label: const Text('Punkte vergeben'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard() {
    return _baseCard(
      child: Row(
        children: [
          const Icon(Icons.report_gmailerrorred_outlined, size: 32),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keine Punkte abziehen',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text('Fehler werden nur gemeldet und später geprüft.'),
              ],
            ),
          ),
          IconButton(
            onPressed: _openReportSheet,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _numberStepper({
    required String title,
    required String value,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onMinus,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              IconButton(
                onPressed: onPlus,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.amber.withOpacity(0.10),
        border: Border.all(
          color: Colors.amber.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baseCard({
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
      ),
    );
  }
}