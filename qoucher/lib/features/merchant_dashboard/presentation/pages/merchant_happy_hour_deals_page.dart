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
    required this.isActive,
    required this.isArchived,
  });

  final String id;

  String merchantId;
  String shopName;

  String title;
  String subtitle;
  String description;

  List<int> selectedWeekdays; // 1 = Montag, 7 = Sonntag

  TimeOfDay startTime;
  TimeOfDay endTime;

  bool isActive;
  bool isArchived;

  factory MerchantHappyHourDealDraft.fromFirestore(
      String documentId,
      Map<String, dynamic> data,
      ) {
    TimeOfDay parseTime(dynamic value, TimeOfDay fallback) {
      if (value is Map) {
        final hour = value['hour'];
        final minute = value['minute'];

        if (hour is int && minute is int) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }

      return fallback;
    }

    return MerchantHappyHourDealDraft(
      id: data['id'] as String? ?? documentId,
      merchantId: data['merchantId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      title: data['title'] as String? ?? 'Happy Hour',
      subtitle: data['subtitle'] as String? ?? 'Zeitlich begrenzte Aktion',
      description: data['description'] as String? ?? '',
      selectedWeekdays: (data['selectedWeekdays'] as List?)
          ?.whereType<int>()
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
      isActive: data['isActive'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestoreMap({
    required String merchantId,
    required String shopName,
  }) {
    return {
      'id': id,
      'merchantId': merchantId,
      'shopName': shopName,
      'type': 'happy_hour_deal',
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'selectedWeekdays': selectedWeekdays,
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'isActive': isActive,
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MerchantHappyHourDealDraft copyWithNewId() {
    return MerchantHappyHourDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: merchantId,
      shopName: shopName,
      title: '$title Kopie',
      subtitle: subtitle,
      description: description,
      selectedWeekdays: [...selectedWeekdays],
      startTime: startTime,
      endTime: endTime,
      isActive: false,
      isArchived: false,
    );
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

  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  MerchantHappyHourDealDraft get currentDeal => deals[selectedIndex];

  CollectionReference<Map<String, dynamic>> get _happyHourDealsRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('happyHourDeals');
  }

  @override
  void initState() {
    super.initState();
    _loadDeals();
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDeals() async {
    setState(() => isLoading = true);

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;

      try {
        snapshot = await _happyHourDealsRef
            .orderBy('updatedAt', descending: true)
            .get();
      } catch (_) {
        snapshot = await _happyHourDealsRef.get();
      }

      deals
        ..clear()
        ..addAll(
          snapshot.docs.map(
                (doc) => MerchantHappyHourDealDraft.fromFirestore(
              doc.id,
              doc.data(),
            ),
          ),
        );

      if (deals.isEmpty) {
        deals.add(_defaultDeal());
      }

      selectedIndex = 0;
      _syncControllersFromCurrent();

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (error) {
      debugPrint('Fehler beim Laden Happy Hour: $error');

      if (deals.isEmpty) {
        deals.add(_defaultDeal());
        selectedIndex = 0;
        _syncControllersFromCurrent();
      }

      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Happy Hour konnte nicht geladen werden');
    }
  }

  void _syncControllersFromCurrent() {
    titleController.text = currentDeal.title;
    subtitleController.text = currentDeal.subtitle;
    descriptionController.text = currentDeal.description;
  }

  void _syncCurrentFromControllers() {
    currentDeal.title = titleController.text.trim().isEmpty
        ? 'Happy Hour'
        : titleController.text.trim();

    currentDeal.subtitle = subtitleController.text.trim().isEmpty
        ? 'Zeitlich begrenzte Aktion'
        : subtitleController.text.trim();

    currentDeal.description = descriptionController.text.trim();
  }

  Future<void> _saveCurrentDeal() async {
    _syncCurrentFromControllers();

    if (currentDeal.title.trim().isEmpty) {
      _showMessage('Bitte Titel eingeben');
      return;
    }

    if (currentDeal.selectedWeekdays.isEmpty) {
      _showMessage('Bitte mindestens einen Tag auswählen');
      return;
    }

    if (!_isValidTimeRange()) {
      _showMessage('Endzeit muss nach Startzeit liegen');
      return;
    }

    setState(() => isSaving = true);

    try {
      final doc = _happyHourDealsRef.doc(currentDeal.id);
      final existingDoc = await doc.get();

      final data = currentDeal.toFirestoreMap(
        merchantId: widget.merchantId,
        shopName: widget.shopName,
      );

      if (!existingDoc.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await doc.set(data, SetOptions(merge: true));

      if (!mounted) return;

      setState(() => isSaving = false);
      _showMessage('${currentDeal.title} gespeichert');

      await _loadDeals();
    } catch (error) {
      debugPrint('Fehler beim Speichern Happy Hour: $error');

      if (!mounted) return;

      setState(() => isSaving = false);
      _showMessage('Speichern fehlgeschlagen');
    }
  }

  void _createNewDeal() {
    _syncCurrentFromControllers();

    setState(() {
      deals.add(_defaultDeal());
      selectedIndex = deals.length - 1;
      _syncControllersFromCurrent();
    });
  }

  void _duplicateCurrentDeal() {
    _syncCurrentFromControllers();

    setState(() {
      deals.add(currentDeal.copyWithNewId());
      selectedIndex = deals.length - 1;
      _syncControllersFromCurrent();
    });
  }

  Future<void> _deleteCurrentDeal() async {
    if (deals.length == 1) {
      _showMessage('Mindestens eine Happy Hour muss bleiben');
      return;
    }

    final dealToDelete = currentDeal;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Happy Hour löschen?'),
          content: Text('„${dealToDelete.title}“ wird gelöscht.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentSoft,
                foregroundColor: AppColors.black,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _happyHourDealsRef.doc(dealToDelete.id).delete();

      if (!mounted) return;

      setState(() {
        deals.removeWhere((deal) => deal.id == dealToDelete.id);
        selectedIndex = selectedIndex.clamp(0, deals.length - 1);
        _syncControllersFromCurrent();
      });

      _showMessage('Happy Hour gelöscht');
    } catch (error) {
      debugPrint('Fehler beim Löschen: $error');
      _showMessage('Löschen fehlgeschlagen');
    }
  }

  Future<void> _pickTime({
    required bool isStart,
  }) async {
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
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (currentDeal.selectedWeekdays.contains(weekday)) {
        currentDeal.selectedWeekdays.remove(weekday);
      } else {
        currentDeal.selectedWeekdays.add(weekday);
        currentDeal.selectedWeekdays.sort();
      }
    });
  }

  bool _isValidTimeRange() {
    final start = currentDeal.startTime.hour * 60 + currentDeal.startTime.minute;
    final end = currentDeal.endTime.hour * 60 + currentDeal.endTime.minute;

    return end > start;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
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
    if (currentDeal.selectedWeekdays.length == 7) {
      return 'Jeden Tag';
    }

    if (currentDeal.selectedWeekdays.isEmpty) {
      return 'Keine Tage ausgewählt';
    }

    return currentDeal.selectedWeekdays.map(_weekdayShort).join(', ');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _topBar(),
            const SizedBox(height: 14),
            _dealsSwitcher(),
            const SizedBox(height: 16),
            _heroCard(),
            const SizedBox(height: 12),
            _sectionTitle('Zeitfenster'),
            const SizedBox(height: 10),
            _weekdayCard(),
            const SizedBox(height: 12),
            _timeCard(),
            const SizedBox(height: 12),
            _mainInfoCard(),
            const SizedBox(height: 12),
            _descriptionCard(),
            const SizedBox(height: 18),
            _sectionTitle('Sichtbarkeit'),
            const SizedBox(height: 10),
            _statusCard(),
            const SizedBox(height: 18),
            _quickActionsCard(),
            const SizedBox(height: 24),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Happy Hour',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tage und Uhrzeiten einfach steuern',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dealsSwitcher() {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: deals.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == deals.length) {
            return InkWell(
              onTap: _createNewDeal,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded),
                    SizedBox(height: 8),
                    Text(
                      'Neue Zeit',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            );
          }

          final deal = deals[index];
          final selected = index == selectedIndex;

          return InkWell(
            onTap: () {
              _syncCurrentFromControllers();

              setState(() {
                selectedIndex = index;
                _syncControllersFromCurrent();
              });
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 158,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accentSoft
                    : AppColors.surface.withOpacity(0.88),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.border,
                  width: selected ? 1.4 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    color: AppColors.black,
                  ),
                  const Spacer(),
                  Text(
                    deal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    deal.isActive ? 'Aktiv' : 'Pausiert',
                    style: TextStyle(
                      color:
                      deal.isActive ? AppColors.black : AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.accent,
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.access_time_filled_rounded,
              color: AppColors.black,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentDeal.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_weekdayLongList()} · ${_formatTime(currentDeal.startTime)}–${_formatTime(currentDeal.endTime)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekdayCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tage auswählen',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (index) {
              final weekday = index + 1;
              final selected = currentDeal.selectedWeekdays.contains(weekday);

              return InkWell(
                onTap: () => _toggleWeekday(weekday),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 46,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accentSoft : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.border,
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Text(
                    _weekdayShort(weekday),
                    style: TextStyle(
                      color: selected ? AppColors.black : AppColors.textMuted,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _timeCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uhrzeit',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }

  Widget _timeButton({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
          ),
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

  Widget _mainInfoCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Titel & Untertitel',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            onChanged: (value) {
              currentDeal.title = value;
              setState(() {});
            },
            decoration: const InputDecoration(
              labelText: 'Titel',
              hintText: 'z. B. Happy Hour Shawarma',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: subtitleController,
            onChanged: (value) {
              currentDeal.subtitle = value;
              setState(() {});
            },
            decoration: const InputDecoration(
              labelText: 'Untertitel',
              hintText: 'z. B. Jeden Freitag 14–17 Uhr',
              prefixIcon: Icon(Icons.short_text_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _descriptionCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Beschreibung',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            onChanged: (value) => currentDeal.description = value,
            minLines: 4,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Beschreibung',
              hintText: 'Was gilt in dieser Happy Hour?',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_rounded),
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
          _iconBox(
            icon: currentDeal.isActive
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            bg: currentDeal.isActive ? AppColors.accentSoft : AppColors.inputFill,
            fg: AppColors.black,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Happy Hour aktiv',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Switch(
            value: currentDeal.isActive,
            onChanged: (value) {
              setState(() => currentDeal.isActive = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard() {
    return _baseCard(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _duplicateCurrentDeal,
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Duplizieren'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _deleteCurrentDeal,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Löschen'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentSoft,
          foregroundColor: AppColors.black,
        ),
        onPressed: isSaving ? null : _saveCurrentDeal,
        icon: isSaving
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          isSaving ? 'Speichert...' : 'Happy Hour speichern',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
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
          color: AppColors.border,
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
}