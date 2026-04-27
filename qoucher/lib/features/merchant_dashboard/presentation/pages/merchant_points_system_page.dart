import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isSaving = false;

  bool isEnabled = true;
  double pointsPerEuro = 1;
  int monthlyMaxPoints = 300;

  final Set<int> bonusDays = {};
  double bonusMultiplier = 2;

  final TextEditingController customerCodeController = TextEditingController();
  final TextEditingController purchaseAmountController =
  TextEditingController();

  int previewPoints = 0;

  final List<_MonthlyReward> rewards = [];

  final List<String> dayNames = [
    'Mo',
    'Di',
    'Mi',
    'Do',
    'Fr',
    'Sa',
    'So',
  ];

  DocumentReference<Map<String, dynamic>> get _configRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('pointsSystem')
        .doc('config')
        .collection('main')
        .doc('main');
  }

  CollectionReference<Map<String, dynamic>> get _rewardsRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('pointsSystem')
        .doc('rewards')
        .collection('items');
  }

  @override
  void initState() {
    super.initState();
    _loadPointsSystem();
  }

  @override
  void dispose() {
    customerCodeController.dispose();
    purchaseAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadPointsSystem() async {
    setState(() => isLoading = true);

    try {
      final configDoc = await _configRef.get();
      final rewardDocs = await _rewardsRef.orderBy('points').get();

      if (configDoc.exists) {
        final data = configDoc.data() ?? {};

        isEnabled = data['isEnabled'] as bool? ?? true;
        pointsPerEuro = (data['pointsPerEuro'] as num?)?.toDouble() ?? 1;
        monthlyMaxPoints = (data['monthlyMaxPoints'] as num?)?.toInt() ?? 300;
        bonusMultiplier = (data['bonusMultiplier'] as num?)?.toDouble() ?? 2;

        bonusDays
          ..clear()
          ..addAll(List<int>.from(data['bonusDays'] ?? []));
      }

      rewards
        ..clear()
        ..addAll(
          rewardDocs.docs.map((doc) {
            final data = doc.data();

            return _MonthlyReward(
              id: doc.id,
              points: (data['points'] as num?)?.toInt() ?? 0,
              title: data['title'] as String? ?? '',
              sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
            );
          }),
        );

      if (rewards.isEmpty) {
        rewards.addAll([
          _MonthlyReward(
            id: '',
            points: 80,
            title: 'Simple',
            sortOrder: 0,
          ),
          _MonthlyReward(
            id: '',
            points: 160,
            title: 'Middle',
            sortOrder: 1,
          ),
          _MonthlyReward(
            id: '',
            points: 300,
            title: 'Premium',
            sortOrder: 2,
          ),
        ]);
      }

      rewards.sort((a, b) => a.points.compareTo(b.points));

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden: $e'),
        ),
      );
    }
  }

  Future<void> _savePointsSystem() async {
    setState(() => isSaving = true);

    try {
      rewards.sort((a, b) => a.points.compareTo(b.points));

      await _configRef.set(
        {
          'isEnabled': isEnabled,
          'pointsPerEuro': pointsPerEuro,
          'monthlyMaxPoints': monthlyMaxPoints,
          'bonusDays': bonusDays.toList()..sort(),
          'bonusMultiplier': bonusMultiplier,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final batch = _firestore.batch();

      for (var i = 0; i < rewards.length; i++) {
        final reward = rewards[i];

        if (reward.id.isEmpty) {
          final doc = _rewardsRef.doc();

          reward.id = doc.id;
          reward.sortOrder = i;

          batch.set(doc, {
            'id': doc.id,
            'title': reward.title,
            'points': reward.points,
            'sortOrder': i,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          reward.sortOrder = i;

          batch.set(
            _rewardsRef.doc(reward.id),
            {
              'id': reward.id,
              'title': reward.title,
              'points': reward.points,
              'sortOrder': i,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      }

      await batch.commit();

      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Punktesystem gespeichert'),
        ),
      );

      await _loadPointsSystem();
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speichern fehlgeschlagen: $e'),
        ),
      );
    }
  }

  void _calculatePreview() {
    final amount = double.tryParse(
      purchaseAmountController.text.replaceAll(',', '.'),
    ) ??
        0;

    setState(() {
      previewPoints = (amount * pointsPerEuro).floor();
    });
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

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$previewPoints Punkte wurden vorbereitet'),
      ),
    );
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

  void _openBonusDaysSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bonus-Tage einstellen',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'An diesen Tagen bekommen Kunden mehr Punkte.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(dayNames.length, (index) {
                      final selected = bonusDays.contains(index);

                      return ChoiceChip(
                        label: Text(dayNames[index]),
                        selected: selected,
                        onSelected: (_) {
                          _toggleBonusDay(index);
                          sheetSetState(() {});
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Text(
                        'Bonus:',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
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
                            sheetSetState(() {});
                          },
                        ),
                      ),
                      Text(
                        '${bonusMultiplier.toStringAsFixed(0)}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Übernehmen'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openManualAssignSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                8,
                18,
                MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Punkte manuell vergeben',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Nur nutzen, wenn QR-Scan nicht klappt.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: customerCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Kundencode',
                      hintText: 'z. B. QCH-4821',
                      prefixIcon: Icon(Icons.qr_code_2_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: purchaseAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      _calculatePreview();
                      sheetSetState(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: 'Einkaufsbetrag',
                      hintText: 'z. B. 12,50',
                      prefixIcon: Icon(Icons.euro_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD36A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD79A25),
                      ),
                    ),
                    child: Text(
                      'Vorschau: $previewPoints Punkte',
                      style: const TextStyle(
                        color: AppColors.black,
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
          },
        );
      },
    );
  }

  void _openRewardSheet({_MonthlyReward? reward}) {
    final pointsController = TextEditingController(
      text: reward?.points.toString() ?? '',
    );

    final titleController = TextEditingController(
      text: reward?.title ?? '',
    );

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            8,
            18,
            MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reward == null ? 'Reward hinzufügen' : 'Reward bearbeiten',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Punkte-Grenze',
                  hintText: 'z. B. 120',
                  prefixIcon: Icon(Icons.stars_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Geschenk',
                  hintText: 'z. B. Gratis Wrap',
                  prefixIcon: Icon(Icons.card_giftcard_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (reward != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (reward.id.isNotEmpty) {
                            await _rewardsRef.doc(reward.id).delete();
                          }

                          setState(() {
                            rewards.remove(reward);
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Löschen'),
                      ),
                    ),
                  if (reward != null) const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        final points = int.tryParse(pointsController.text) ?? 0;
                        final title = titleController.text.trim();

                        if (points <= 0 || title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text('Bitte Punkte und Geschenk eingeben'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          if (reward == null) {
                            rewards.add(
                              _MonthlyReward(
                                id: '',
                                points: points,
                                title: title,
                                sortOrder: rewards.length,
                              ),
                            );
                          } else {
                            reward.points = points;
                            reward.title = title;
                          }

                          rewards.sort((a, b) => a.points.compareTo(b.points));
                        });

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Speichern'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openMonthlyMaxSheet() {
    final controller = TextEditingController(
      text: monthlyMaxPoints.toString(),
    );

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Monatsziel festlegen',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Maximale Punkte im Monat',
                  hintText: 'z. B. 300',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final value = int.tryParse(controller.text) ?? 0;

                    if (value <= 0) return;

                    setState(() {
                      monthlyMaxPoints = value;

                      for (final reward in rewards) {
                        if (reward.points > monthlyMaxPoints) {
                          reward.points = monthlyMaxPoints;
                        }
                      }

                      rewards.sort((a, b) => a.points.compareTo(b.points));
                    });

                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Übernehmen'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openReportSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Problem melden',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
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
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title gemeldet'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bonusText = bonusDays.isEmpty
        ? 'Keine Bonus-Tage aktiv'
        : '${bonusDays.length} Bonus-Tage · ${bonusMultiplier.toStringAsFixed(0)}x Punkte';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Punktesystem'),
        actions: [
          IconButton(
            onPressed: isSaving ? null : _savePointsSystem,
            icon: isSaving
                ? const SizedBox(
              width: 19,
              height: 19,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.check_circle_outline),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _statusCard(),
          const SizedBox(height: 10),

          _pointsRuleCard(),
          const SizedBox(height: 10),

          _rewardsCard(),
          const SizedBox(height: 10),

          _quickActionsCard(bonusText),
          const SizedBox(height: 18),

          _sectionTitle(
            title: 'Monatswechsel',
            subtitle: 'Punkte am Monatsanfang zurücksetzen.',
          ),
          const SizedBox(height: 10),
          _monthlyResetCard(),

          const SizedBox(height: 18),

          _sectionTitle(
            title: 'Sicherheit',
            subtitle: 'Fehler werden nur gemeldet, nicht direkt gelöscht.',
          ),
          const SizedBox(height: 10),
          _reportCard(),

        ],
      ),    );
  }

  Widget _statusCard() {
    return _baseCard(
      child: Row(
        children: [
          _iconBox(
            icon: isEnabled ? Icons.power_settings_new : Icons.pause_rounded,
            bg: isEnabled ? const Color(0xFFFFD36A) : const Color(0xFFE5D2AF),
            fg: AppColors.black,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Systemstatus',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.black,
              ),
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
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                '1 €',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.black,
                ),
              ),
              Expanded(
                child: Slider(
                  value: pointsPerEuro,
                  min: 0.5,
                  max: 10,
                  divisions: 19,
                  label: pointsPerEuro.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => pointsPerEuro = value);
                    _calculatePreview();
                  },
                ),
              ),
              Text(
                '${pointsPerEuro.toStringAsFixed(1)} Punkte',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rewardsCard() {
    final sortedRewards = [...rewards]
      ..sort((a, b) => a.points.compareTo(b.points));

    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Rewards diesen Monat',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openMonthlyMaxSheet,
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: Text('$monthlyMaxPoints P'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _rewardScale(sortedRewards),
          const SizedBox(height: 18),
          ...sortedRewards.map((reward) => _rewardRow(reward)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openRewardSheet(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Reward hinzufügen'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardScale(List<_MonthlyReward> sortedRewards) {
    return SizedBox(
      height: 74,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 35,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5D2AF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 35,
                child: Container(
                  width: constraints.maxWidth,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD36A),
                        Color(0xFFE89A00),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              ...sortedRewards.map((reward) {
                final percent =
                (reward.points / monthlyMaxPoints).clamp(0.0, 1.0);
                final left = (constraints.maxWidth - 34) * percent;

                return Positioned(
                  left: left,
                  top: 18,
                  child: GestureDetector(
                    onTap: () => _openRewardSheet(reward: reward),
                    child: Column(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.amber,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reward.points}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _rewardRow(_MonthlyReward reward) {
    return InkWell(
      onTap: () => _openRewardSheet(reward: reward),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            _iconBox(
              icon: Icons.card_giftcard_rounded,
              bg: const Color(0xFFFFD36A),
              fg: AppColors.black,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reward.title,
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${reward.points} P',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionsCard(String bonusText) {
    return _baseCard(
      child: Column(
        children: [
          _quickActionRow(
            icon: Icons.calendar_month_rounded,
            title: 'Bonus-Tage',
            subtitle: bonusText,
            onTap: _openBonusDaysSheet,
          ),
          const Divider(height: 22),
          _quickActionRow(
            icon: Icons.add_card_rounded,
            title: 'Punkte manuell vergeben',
            subtitle: 'Nur nutzen, wenn QR-Scan nicht klappt.',
            onTap: _openManualAssignSheet,
          ),
        ],
      ),
    );
  }

  Widget _quickActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            _iconBox(
              icon: icon,
              bg: const Color(0xFFE5D2AF),
              fg: AppColors.black,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard() {
    return _baseCard(
      child: Row(
        children: [
          _iconBox(
            icon: Icons.report_gmailerrorred_outlined,
            bg: const Color(0xFFFFD6D9),
            fg: const Color(0xFFB5121B),
          ),
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
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Fehler werden nur gemeldet und später geprüft.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _iconBox({
    required IconData icon,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bg.withOpacity(0.8),
        ),
      ),
      child: Icon(
        icon,
        color: fg,
        size: 24,
      ),
    );
  }

  Widget _baseCard({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
          width: 1.05,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _monthlyResetCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(
                icon: Icons.restart_alt_rounded,
                bg: const Color(0xFFFFD6D9),
                fg: const Color(0xFFB5121B),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alle Punkte zurücksetzen',
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openResetPointsSheet,
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Monatspunkte zurücksetzen'),
            ),
          ),
        ],
      ),
    );
  }

  void _openResetPointsSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Monatspunkte zurücksetzen?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Alle Kundenpunkte für diesen Monat werden auf 0 gesetzt. Rewards und Einstellungen bleiben bestehen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Abbrechen'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _resetAllCustomerMonthlyPoints();
                      },
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Zurücksetzen'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resetAllCustomerMonthlyPoints() async {
    try {
      setState(() => isSaving = true);

      final snapshot = await _firestore
          .collection('merchants')
          .doc(widget.merchantId)
          .collection('customerPoints')
          .get();

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.set(
          doc.reference,
          {
            'monthlyPoints': 0,
            'monthlyResetAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      batch.set(
        _configRef,
        {
          'lastMonthlyResetAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Monatspunkte wurden zurückgesetzt'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Zurücksetzen fehlgeschlagen: $e'),
        ),
      );
    }
  }
}

class _MonthlyReward {
  _MonthlyReward({
    required this.id,
    required this.points,
    required this.title,
    required this.sortOrder,
  });

  String id;
  int points;
  String title;
  int sortOrder;
}