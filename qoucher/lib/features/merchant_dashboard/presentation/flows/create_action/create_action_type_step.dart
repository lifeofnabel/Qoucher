import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class MerchantCreateActionPage extends StatefulWidget {
  const MerchantCreateActionPage({
    super.key,
    required this.merchantId,
    required this.shopName,
    this.actionId,
  });

  final String merchantId;
  final String shopName;
  final String? actionId;

  @override
  State<MerchantCreateActionPage> createState() =>
      _MerchantCreateActionPageState();
}

class _MerchantCreateActionPageState extends State<MerchantCreateActionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController oldPriceController = TextEditingController();
  final TextEditingController newPriceController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;
  bool isActive = true;

  DateTime? startDate;
  DateTime? endDate;

  String selectedType = 'deal';

  final List<_ActionTypeOption> actionTypes = const [
    _ActionTypeOption(
      id: 'deal',
      title: 'Deal',
      subtitle: 'Normaler Rabatt',
      icon: Icons.local_offer_rounded,
    ),
    _ActionTypeOption(
      id: 'two_for_one',
      title: '2 für 1',
      subtitle: 'Bundle-Aktion',
      icon: Icons.filter_2_rounded,
    ),
    _ActionTypeOption(
      id: 'gift',
      title: 'Gratis',
      subtitle: 'Geschenk/Coupon',
      icon: Icons.card_giftcard_rounded,
    ),
    _ActionTypeOption(
      id: 'happy_hour',
      title: 'Happy Hour',
      subtitle: 'Zeitlich begrenzt',
      icon: Icons.access_time_filled_rounded,
    ),
    _ActionTypeOption(
      id: 'mhd',
      title: 'MHD-Ware',
      subtitle: 'Schnell verkaufen',
      icon: Icons.schedule_rounded,
    ),
    _ActionTypeOption(
      id: 'custom',
      title: 'Individuell',
      subtitle: 'Frei bauen',
      icon: Icons.edit_note_rounded,
    ),
  ];

  CollectionReference<Map<String, dynamic>> get _actionsRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('actions');
  }

  bool get isEditMode => widget.actionId != null && widget.actionId!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      _loadAction();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    descriptionController.dispose();
    oldPriceController.dispose();
    newPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadAction() async {
    setState(() => isLoading = true);

    try {
      final doc = await _actionsRef.doc(widget.actionId).get();

      if (!doc.exists) {
        if (!mounted) return;

        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aktion nicht gefunden'),
          ),
        );

        return;
      }

      final data = doc.data() ?? {};

      titleController.text = data['title'] as String? ?? '';
      subtitleController.text = data['subtitle'] as String? ?? '';
      descriptionController.text = data['description'] as String? ?? '';
      oldPriceController.text = (data['oldPrice'] as num?)?.toString() ?? '';
      newPriceController.text = (data['newPrice'] as num?)?.toString() ?? '';

      selectedType = data['type'] as String? ?? 'deal';
      isActive = data['isActive'] as bool? ?? true;

      final startTimestamp = data['startDate'];
      final endTimestamp = data['endDate'];

      if (startTimestamp is Timestamp) {
        startDate = startTimestamp.toDate();
      }

      if (endTimestamp is Timestamp) {
        endDate = endTimestamp.toDate();
      }

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

  Future<void> _saveAction() async {
    final title = titleController.text.trim();
    final subtitle = subtitleController.text.trim();
    final description = descriptionController.text.trim();

    final oldPrice = double.tryParse(
      oldPriceController.text.trim().replaceAll(',', '.'),
    );

    final newPrice = double.tryParse(
      newPriceController.text.trim().replaceAll(',', '.'),
    );

    if (title.isEmpty) {
      _showMessage('Bitte Titel eingeben');
      return;
    }

    if (subtitle.isEmpty) {
      _showMessage('Bitte Untertitel eingeben');
      return;
    }

    if (startDate == null || endDate == null) {
      _showMessage('Bitte Beginn und Ende auswählen');
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      _showMessage('Enddatum darf nicht vor Beginn liegen');
      return;
    }

    setState(() => isSaving = true);

    try {
      final doc = isEditMode ? _actionsRef.doc(widget.actionId) : _actionsRef.doc();

      final data = {
        'id': doc.id,
        'merchantId': widget.merchantId,
        'shopName': widget.shopName,
        'type': selectedType,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'oldPrice': oldPrice,
        'newPrice': newPrice,
        'startDate': Timestamp.fromDate(startDate!),
        'endDate': Timestamp.fromDate(endDate!),
        'isActive': isActive,
        'isArchived': false,
        'imageUrl': '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!isEditMode) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await doc.set(data, SetOptions(merge: true));

      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktion gespeichert'),
        ),
      );

      Navigator.pop(context);
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

  Future<void> _deleteAction() async {
    if (!isEditMode) {
      Navigator.pop(context);
      return;
    }

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
                'Aktion löschen?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Diese Aktion wird dauerhaft entfernt.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
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

                        await _actionsRef.doc(widget.actionId).delete();

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Aktion gelöscht'),
                          ),
                        );

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Löschen'),
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

  Future<void> _pickDate({
    required bool isStart,
  }) async {
    final initialDate = isStart
        ? startDate ?? DateTime.now()
        : endDate ?? startDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        startDate = picked;

        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = picked;
        }
      } else {
        endDate = picked;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Auswählen';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = actionTypes.firstWhere(
          (item) => item.id == selectedType,
      orElse: () => actionTypes.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditMode ? 'Aktion bearbeiten' : 'Neue Aktion'),
        actions: [
          IconButton(
            onPressed: isSaving ? null : _saveAction,
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
          _imageHero(selectedOption),
          const SizedBox(height: 12),
          _typeSelector(),
          const SizedBox(height: 12),
          _mainInfoCard(),
          const SizedBox(height: 12),
          _dateCard(),
          const SizedBox(height: 12),
          _priceCard(),
          const SizedBox(height: 12),
          _descriptionCard(),
          const SizedBox(height: 12),
          _statusCard(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSaving ? null : _deleteAction,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(isEditMode ? 'Löschen' : 'Abbrechen'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isSaving ? null : _saveAction,
                  icon: isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.save_outlined),
                  label: Text(isSaving ? 'Speichert...' : 'Speichern'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageHero(_ActionTypeOption selectedOption) {
    return Container(
      height: 178,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD9BE86),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF8F6B24),
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
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.border,
                width: 1.2,
              ),
            ),
            child: Icon(
              selectedOption.icon,
              color: AppColors.black,
              size: 48,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Bildhalter',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${selectedOption.title} · ${selectedOption.subtitle}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Bild später hinzufügen',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeSelector() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktionstyp',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actionTypes.map((type) {
              final selected = selectedType == type.id;

              return ChoiceChip(
                label: Text(type.title),
                selected: selected,
                avatar: Icon(
                  type.icon,
                  size: 17,
                  color: selected ? AppColors.white : AppColors.black,
                ),
                onSelected: (_) {
                  setState(() => selectedType = type.id);
                },
              );
            }).toList(),
          ),
        ],
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
            decoration: const InputDecoration(
              labelText: 'Titel',
              hintText: 'z. B. Shawarma Deal',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: subtitleController,
            decoration: const InputDecoration(
              labelText: 'Untertitel',
              hintText: 'z. B. Nur diese Woche',
              prefixIcon: Icon(Icons.short_text_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zeitraum',
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
                child: _dateButton(
                  title: 'Beginn',
                  value: _formatDate(startDate),
                  icon: Icons.play_arrow_rounded,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateButton(
                  title: 'Ende',
                  value: _formatDate(endDate),
                  icon: Icons.stop_rounded,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preis',
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
                child: TextField(
                  controller: oldPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Altpreis',
                    hintText: 'z. B. 9,90',
                    prefixIcon: Icon(Icons.euro_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: newPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Neupreis',
                    hintText: 'z. B. 6,90',
                    prefixIcon: Icon(Icons.sell_rounded),
                  ),
                ),
              ),
            ],
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
            minLines: 4,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Beschreibung',
              hintText: 'Was bekommt der Kunde genau?',
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
            icon: isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            bg: isActive ? const Color(0xFFFFD36A) : const Color(0xFFE5D2AF),
            fg: AppColors.black,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktion aktiv',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Aktive Aktionen erscheinen für Kunden.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) {
              setState(() => isActive = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _dateButton({
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
            Icon(
              icon,
              color: AppColors.black,
            ),
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
}

class _ActionTypeOption {
  const _ActionTypeOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}