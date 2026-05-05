import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:qoucher/core/constants/app_colors.dart';

class MerchantHappyHourDealDraft {
  MerchantHappyHourDealDraft({
    required this.id,
    required this.merchantId,
    required this.shopName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.selectedWeekdays,
    required this.startTime,
    required this.endTime,
    required this.dealMode,
    required this.discountPercent,
    required this.freestyleText,
    required this.isActive,
    required this.isArchived,
  });

  factory MerchantHappyHourDealDraft.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    TimeOfDay parseTime(dynamic value, TimeOfDay fallback) {
      if (value is Map) {
        final hour = value['hour'];
        final minute = value['minute'];

        if (hour is int && minute is int) {
          return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
        }
      }

      return fallback;
    }

    return MerchantHappyHourDealDraft(
      id: data['id']?.toString() ?? documentId,
      merchantId: data['merchantId']?.toString() ?? '',
      shopName: data['merchantName']?.toString() ??
          data['shopName']?.toString() ??
          '',
      title: data['title']?.toString() ?? 'Happy Hour',
      subtitle: data['subtitle']?.toString() ?? 'Zeitlich begrenzte Aktion',
      description: data['description']?.toString() ?? '',
      selectedWeekdays: (data['selectedWeekdays'] as List?)
              ?.map((item) => item is int ? item : int.tryParse(item.toString()))
              .whereType<int>()
              .where((item) => item >= 1 && item <= 7)
              .toList() ??
          [1, 2, 3, 4, 5],
      startTime: parseTime(
        data['startTime'],
        const TimeOfDay(hour: 14, minute: 0),
      ),
      endTime: parseTime(
        data['endTime'],
        const TimeOfDay(hour: 17, minute: 0),
      ),
      dealMode: data['dealMode']?.toString() ?? 'percent',
      discountPercent: (data['discountPercent'] as num?)?.toInt() ?? 20,
      freestyleText: data['freestyleText']?.toString() ?? 'Alle ausgewählten Produkte günstiger',
      isActive: data['isActive'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
    );
  }

  final String id;

  String merchantId;
  String shopName;

  String title;
  String subtitle;
  String description;

  List<int> selectedWeekdays;
  TimeOfDay startTime;
  TimeOfDay endTime;

  String dealMode; // percent | text
  int discountPercent;
  String freestyleText;

  bool isActive;
  bool isArchived;

  bool get isOvernight {
    final start = startTime.hour * 60 + startTime.minute;
    final end = endTime.hour * 60 + endTime.minute;
    return end < start;
  }

  bool get hasValidTime {
    final start = startTime.hour * 60 + startTime.minute;
    final end = endTime.hour * 60 + endTime.minute;
    return start != end;
  }

  bool get hasContent {
    if (dealMode == 'percent') return discountPercent > 0;
    return freestyleText.trim().isNotEmpty;
  }

  bool get canGoLive {
    return title.trim().isNotEmpty &&
        selectedWeekdays.isNotEmpty &&
        hasValidTime &&
        hasContent;
  }

  String get dealText {
    if (dealMode == 'percent') return '$discountPercent% Rabatt';
    return freestyleText.trim().isEmpty ? 'Happy Hour Angebot' : freestyleText.trim();
  }

  Map<String, dynamic> toFeedMap({
    required String merchantId,
    required String shopName,
  }) {
    return {
      'id': id,
      'merchantId': merchantId,
      'merchantName': shopName,
      'shopName': shopName,
      'type': 'happy_hour',
      'title': title.trim().isEmpty ? 'Happy Hour' : title.trim(),
      'subtitle': subtitle.trim(),
      'description': description.trim(),
      'selectedWeekdays': selectedWeekdays..sort(),
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'allowsOvernight': isOvernight,
      'dealMode': dealMode,
      'discountPercent': discountPercent,
      'freestyleText': freestyleText.trim(),
      'dealText': dealText,
      'isActive': isActive,
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class MerchantHappyHourDealsPage extends StatefulWidget {
  const MerchantHappyHourDealsPage({
    super.key,
    required this.merchantId,
    required this.shopName,
  });

  final String merchantId;
  final String shopName;

  @override
  State<MerchantHappyHourDealsPage> createState() =>
      _MerchantHappyHourDealsPageState();
}

class _MerchantHappyHourDealsPageState
    extends State<MerchantHappyHourDealsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<MerchantHappyHourDealDraft> deals = [];

  int selectedIndex = 0;
  bool isLoading = true;
  bool isSaving = false;

  Timer? _saveTimer;

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final descriptionController = TextEditingController();
  final freestyleController = TextEditingController();

  MerchantHappyHourDealDraft get currentDeal => deals[selectedIndex];

  CollectionReference<Map<String, dynamic>> get _feedRef {
    return _firestore.collection('feed');
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    titleController.dispose();
    subtitleController.dispose();
    descriptionController.dispose();
    freestyleController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;

      try {
        snapshot = await _feedRef
            .where('merchantId', isEqualTo: widget.merchantId)
            .where('type', isEqualTo: 'happy_hour')
            .orderBy('updatedAt', descending: true)
            .limit(1)
            .get();
      } catch (_) {
        snapshot = await _feedRef
            .where('merchantId', isEqualTo: widget.merchantId)
            .where('type', isEqualTo: 'happy_hour')
            .limit(1)
            .get();
      }

      deals
        ..clear()
        ..addAll(
          snapshot.docs.map(
            (doc) => MerchantHappyHourDealDraft.fromFirestore(doc.id, doc.data()),
          ),
        );

      if (deals.isEmpty) {
        final draft = _defaultDeal();
        deals.add(draft);
        await _saveDeal(draft, silent: true);
      }

      selectedIndex = 0;
      _syncControllersFromCurrent();
    } catch (_) {
      if (deals.isEmpty) {
        deals.add(_defaultDeal());
        selectedIndex = 0;
        _syncControllersFromCurrent();
      }

      _showMessage('Happy Hour konnte nicht geladen werden', error: true);
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _syncControllersFromCurrent() {
    titleController.text = currentDeal.title;
    subtitleController.text = currentDeal.subtitle;
    descriptionController.text = currentDeal.description;
    freestyleController.text = currentDeal.freestyleText;
  }

  void _syncCurrentFromControllers() {
    currentDeal.title = titleController.text.trim();
    currentDeal.subtitle = subtitleController.text.trim();
    currentDeal.description = descriptionController.text.trim();
    currentDeal.freestyleText = freestyleController.text.trim();
  }

  void _scheduleSave() {
    _syncCurrentFromControllers();

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 650), () {
      _saveCurrent(silent: true);
    });
  }

  Future<void> _saveCurrent({bool silent = false}) async {
    _syncCurrentFromControllers();
    await _saveDeal(currentDeal, silent: silent);
  }

  Future<void> _saveDeal(
    MerchantHappyHourDealDraft deal, {
    bool silent = false,
  }) async {
    if (!mounted) return;

    setState(() => isSaving = true);

    try {
      if (deal.isActive && !deal.canGoLive) {
        deal.isActive = false;
        _showMessage(
          'Live geht erst, wenn Tage, Uhrzeit, Titel und Inhalt vollständig sind',
          error: true,
        );
      }

      final docRef = _feedRef.doc(deal.id);
      final exists = (await docRef.get()).exists;

      final data = deal.toFeedMap(
        merchantId: widget.merchantId,
        shopName: widget.shopName,
      );

      if (!exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(data, SetOptions(merge: true));

      if (!silent) {
        _showMessage('${deal.title.isEmpty ? 'Happy Hour' : deal.title} gespeichert');
      }
    } catch (_) {
      _showMessage('Speichern fehlgeschlagen', error: true);
    }

    if (mounted) setState(() => isSaving = false);
  }

  void _tryCreateNewDeal() {
    _showMessage(
      'Zurzeit ist das Veröffentlichen nur von einer Happy Hour in dieser Branche möglich.',
      error: true,
    );
  }

  void _openDeleteSheet() {
    _darkSheet(
      title: 'Happy Hour löschen',
      subtitle: 'Dieser Feed-Post wird entfernt.',
      child: Column(
        children: [
          _lightButton(
            text: 'Ja, weiter',
            onTap: () {
              Navigator.pop(context);
              _openFinalDeleteSheet();
            },
          ),
        ],
      ),
    );
  }

  void _openFinalDeleteSheet() {
    _darkSheet(
      title: 'Wirklich löschen?',
      subtitle: 'Letzte Warnung. Die Happy Hour verschwindet aus dem Feed.',
      child: _dangerButton(
        text: 'Endgültig löschen',
        onTap: () async {
          Navigator.pop(context);
          await _deleteCurrentDeal();
        },
      ),
    );
  }

  Future<void> _deleteCurrentDeal() async {
    final deal = currentDeal;

    try {
      await _feedRef.doc(deal.id).delete();

      final draft = _defaultDeal();
      deals
        ..clear()
        ..add(draft);
      selectedIndex = 0;
      _syncControllersFromCurrent();

      await _saveDeal(draft, silent: true);

      if (mounted) setState(() {});
      _showMessage('Happy Hour gelöscht. Neuer Entwurf wurde vorbereitet.');
    } catch (_) {
      _showMessage('Löschen fehlgeschlagen', error: true);
    }
  }

  MerchantHappyHourDealDraft _defaultDeal() {
    return MerchantHappyHourDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: widget.merchantId,
      shopName: widget.shopName,
      title: 'Happy Hour',
      subtitle: 'Zeitlich begrenzte Aktion',
      description: '',
      selectedWeekdays: [1, 2, 3, 4, 5],
      startTime: const TimeOfDay(hour: 14, minute: 0),
      endTime: const TimeOfDay(hour: 17, minute: 0),
      dealMode: 'percent',
      discountPercent: 20,
      freestyleText: 'Alle ausgewählten Produkte günstiger',
      isActive: false,
      isArchived: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.black),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.black,
          backgroundColor: AppColors.surface,
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _hero(),
              const SizedBox(height: 16),
              _limitStrip(),
              const SizedBox(height: 16),
              _feedPreview(),
              const SizedBox(height: 16),
              _quickStatus(),
              const SizedBox(height: 22),
              _sectionTitle(
                'Wann läuft sie?',
                'Wochentage und Uhrzeit. Nachtfenster wie 22:00–02:00 sind erlaubt.',
              ),
              const SizedBox(height: 12),
              _timePanel(),
              const SizedBox(height: 22),
              _sectionTitle(
                'Was passiert in der Happy Hour?',
                'Entweder Prozent-Rabatt oder freier Text.',
              ),
              const SizedBox(height: 12),
              _contentPanel(),
              const SizedBox(height: 22),
              _sectionTitle(
                'Wie soll der Post klingen?',
                'Titel, Untertitel und Beschreibung.',
              ),
              const SizedBox(height: 12),
              _textPanel(),
              const SizedBox(height: 22),
              _managePanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(38),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _heroButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              if (isSaving)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.2,
                  ),
                )
              else
                _heroPill(currentDeal.isActive ? 'Live' : 'Entwurf'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Happy Hour Builder',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: 37,
              height: 0.95,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.7,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tage, Uhrzeit und Aktion setzen. Der Feed zeigt automatisch, wann es heiß wird.',
            style: TextStyle(
              color: AppColors.textDisabled,
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _darkChip('type: happy_hour'),
              _darkChip(_weekdayLongList()),
              _darkChip(_timeRangeText()),
              _darkChip(currentDeal.isOvernight ? 'über Nacht' : 'gleicher Tag'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _limitStrip() {
    return GestureDetector(
      onTap: _tryCreateNewDeal,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.black),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aktuell ist nur eine Happy Hour in dieser Branche möglich.',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
            ),
            Icon(Icons.add_circle_outline_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _feedPreview() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.storefront_rounded, color: AppColors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.shopName,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentDeal.isActive ? 'Aktive Happy Hour' : 'Entwurf',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            currentDeal.title.trim().isEmpty ? 'Happy Hour' : currentDeal.title,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 30,
              height: 0.95,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentDeal.subtitle.trim().isEmpty
                ? 'Zeitlich begrenzte Aktion'
                : currentDeal.subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _previewBox(
                  label: 'Zeit',
                  title: '${_weekdayLongList()}\n${_timeRangeText()}',
                  icon: Icons.schedule_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: AppColors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _previewBox(
                  label: 'Aktion',
                  title: currentDeal.dealText,
                  icon: Icons.percent_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _softChip(currentDeal.dealText),
              _softChip(_weekdayLongList()),
              _softChip(_timeRangeText()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickStatus() {
    return Row(
      children: [
        Expanded(
          child: _quickPill(
            icon: currentDeal.isActive ? Icons.bolt_rounded : Icons.pause_rounded,
            title: currentDeal.isActive ? 'Live' : 'Entwurf',
            onTap: () async {
              if (!currentDeal.isActive && !currentDeal.canGoLive) {
                _showMessage('Erst Tage, Uhrzeit, Inhalt und Titel ausfüllen', error: true);
                return;
              }

              setState(() => currentDeal.isActive = !currentDeal.isActive);
              await _saveCurrent(silent: true);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _quickPill(
            icon: currentDeal.isArchived ? Icons.inventory_2_rounded : Icons.public_rounded,
            title: currentDeal.isArchived ? 'Archiv' : 'Feed',
            onTap: () async {
              setState(() {
                currentDeal.isArchived = !currentDeal.isArchived;
                if (currentDeal.isArchived) currentDeal.isActive = false;
              });

              await _saveCurrent(silent: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _timePanel() {
    return _basePanel(
      children: [
        _weekdayPicker(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _timeButton(
                title: 'Start',
                value: _formatTime(currentDeal.startTime),
                icon: Icons.play_arrow_rounded,
                onTap: () => _pickTime(isStart: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _timeButton(
                title: 'Ende',
                value: _formatTime(currentDeal.endTime),
                icon: Icons.stop_rounded,
                onTap: () => _pickTime(isStart: false),
              ),
            ),
          ],
        ),
        if (currentDeal.isOvernight) ...[
          const SizedBox(height: 12),
          _smallInfo('Läuft über Nacht. Beispiel: 22:00–02:00.'),
        ],
      ],
    );
  }

  Widget _weekdayPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final weekday = index + 1;
        final selected = currentDeal.selectedWeekdays.contains(weekday);

        return GestureDetector(
          onTap: () async {
            setState(() {
              if (selected) {
                currentDeal.selectedWeekdays.remove(weekday);
              } else {
                currentDeal.selectedWeekdays.add(weekday);
                currentDeal.selectedWeekdays.sort();
              }
            });

            await _saveCurrent(silent: true);
          },
          child: Container(
            width: 46,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.black : AppColors.inputFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? AppColors.black : AppColors.border),
            ),
            child: Text(
              _weekdayShort(weekday),
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.textMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _contentPanel() {
    return _basePanel(
      children: [
        Row(
          children: [
            Expanded(
              child: _modeTile(
                icon: Icons.percent_rounded,
                title: 'Rabatt %',
                selected: currentDeal.dealMode == 'percent',
                onTap: () async {
                  setState(() => currentDeal.dealMode = 'percent');
                  await _saveCurrent(silent: true);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _modeTile(
                icon: Icons.edit_note_rounded,
                title: 'Freitext',
                selected: currentDeal.dealMode == 'text',
                onTap: () async {
                  setState(() => currentDeal.dealMode = 'text');
                  await _saveCurrent(silent: true);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (currentDeal.dealMode == 'percent') _percentPicker() else _freestyleInput(),
      ],
    );
  }

  Widget _percentPicker() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Text(
            'Rabatt',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Slider(
              value: currentDeal.discountPercent.toDouble().clamp(5, 80),
              min: 5,
              max: 80,
              divisions: 15,
              label: '${currentDeal.discountPercent}%',
              onChanged: (value) async {
                setState(() => currentDeal.discountPercent = value.round());
                _scheduleSave();
              },
            ),
          ),
          Text(
            '${currentDeal.discountPercent}%',
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _freestyleInput() {
    return _input(
      controller: freestyleController,
      hint: 'z. B. Alle Wraps günstiger',
      icon: Icons.local_fire_department_rounded,
      onChanged: (_) => _scheduleSave(),
    );
  }

  Widget _textPanel() {
    return _basePanel(
      children: [
        _input(
          controller: titleController,
          hint: 'Titel, z. B. Happy Hour Shawarma',
          icon: Icons.title_rounded,
          onChanged: (_) => _scheduleSave(),
        ),
        const SizedBox(height: 10),
        _input(
          controller: subtitleController,
          hint: 'Untertitel, z. B. Jeden Freitag 14–17 Uhr',
          icon: Icons.short_text_rounded,
          onChanged: (_) => _scheduleSave(),
        ),
        const SizedBox(height: 10),
        _input(
          controller: descriptionController,
          hint: 'Beschreibung optional',
          icon: Icons.notes_rounded,
          maxLines: 3,
          onChanged: (_) => _scheduleSave(),
        ),
      ],
    );
  }

  Widget _managePanel() {
    return _basePanel(
      children: [
        _manageRow(
          icon: Icons.add_circle_outline_rounded,
          title: 'Neue Happy Hour hinzufügen',
          subtitle: 'Zurzeit auf eine Happy Hour limitiert.',
          onTap: _tryCreateNewDeal,
        ),
        const Divider(height: 18, color: AppColors.divider),
        _manageRow(
          icon: Icons.delete_forever_rounded,
          title: 'Happy Hour löschen',
          subtitle: 'Zwei Fragen, dann weg.',
          onTap: _openDeleteSheet,
        ),
      ],
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? currentDeal.startTime : currentDeal.endTime,
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        currentDeal.startTime = picked;
      } else {
        currentDeal.endTime = picked;
      }
    });

    await _saveCurrent(silent: true);
  }

  Widget _modeTile({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 98,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.black : AppColors.inputFill,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? AppColors.black : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? AppColors.white : AppColors.black),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeButton({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.black),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewBox({
    required String label,
    required String title,
    required IconData icon,
  }) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.black, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickPill({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.black, size: 21),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _basePanel({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textDisabled),
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _manageRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(icon, color: AppColors.black),
            const SizedBox(width: 13),
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
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _smallInfo(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _softChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _darkChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white.withOpacity(0.14)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textOnDark,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _heroButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, color: AppColors.black),
      ),
    );
  }

  Widget _heroPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.black,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  void _darkSheet({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bottom = MediaQuery.of(sheetContext).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(36),
            ),
            child: SafeArea(
              top: false,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: 26,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.9,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _lightButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _dangerButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _timeRangeText() {
    return '${_formatTime(currentDeal.startTime)}–${_formatTime(currentDeal.endTime)}';
  }

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mo';
      case 2:
        return 'Di';
      case 3:
        return 'Mi';
      case 4:
        return 'Do';
      case 5:
        return 'Fr';
      case 6:
        return 'Sa';
      case 7:
        return 'So';
      default:
        return '?';
    }
  }

  String _weekdayLongList() {
    final days = [...currentDeal.selectedWeekdays]..sort();

    if (days.length == 7) return 'Jeden Tag';
    if (days.isEmpty) return 'Keine Tage';

    return days.map(_weekdayShort).join(', ');
  }

  void _showMessage(String text, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: error ? AppColors.error : AppColors.black,
        ),
      );
  }
}
