import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class MerchantFreeItemDealDraft {
  MerchantFreeItemDealDraft({
    required this.id,
    required this.merchantId,
    required this.shopName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buyItemId,
    required this.buyItemName,
    required this.freeItemId,
    required this.freeItemName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isArchived,
  });

  final String id;

  String merchantId;
  String shopName;

  String title;
  String subtitle;
  String description;

  String buyItemId;
  String buyItemName;

  String freeItemId;
  String freeItemName;

  DateTime? startDate;
  DateTime? endDate;

  bool isActive;
  bool isArchived;

  factory MerchantFreeItemDealDraft.fromFirestore(
      String documentId,
      Map<String, dynamic> data,
      ) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return MerchantFreeItemDealDraft(
      id: data['id'] as String? ?? documentId,
      merchantId: data['merchantId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      title: data['title'] as String? ?? 'Kaufe X, erhalte Y gratis',
      subtitle: data['subtitle'] as String? ?? 'Gratis-Artikel beim Kauf',
      description: data['description'] as String? ?? '',
      buyItemId: data['buyItemId'] as String? ?? '',
      buyItemName: data['buyItemName'] as String? ?? 'Kauf-Artikel wählen',
      freeItemId: data['freeItemId'] as String? ?? '',
      freeItemName: data['freeItemName'] as String? ?? 'Gratis-Artikel wählen',
      startDate: parseDate(data['startDate']),
      endDate: parseDate(data['endDate']),
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
      'type': 'free_item_deal',
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'buyItemId': buyItemId,
      'buyItemName': buyItemName,
      'freeItemId': freeItemId,
      'freeItemName': freeItemName,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'isActive': isActive,
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MerchantFreeItemDealDraft copyWithNewId() {
    return MerchantFreeItemDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: merchantId,
      shopName: shopName,
      title: '$title Kopie',
      subtitle: subtitle,
      description: description,
      buyItemId: buyItemId,
      buyItemName: buyItemName,
      freeItemId: freeItemId,
      freeItemName: freeItemName,
      startDate: startDate,
      endDate: endDate,
      isActive: false,
      isArchived: false,
    );
  }
}

class MerchantItemOption {
  const MerchantItemOption({
    required this.id,
    required this.name,
    this.price,
    this.imageUrl = '',
  });

  final String id;
  final String name;
  final double? price;
  final String imageUrl;

  factory MerchantItemOption.fromFirestore(
      String documentId,
      Map<String, dynamic> data,
      ) {
    return MerchantItemOption(
      id: data['id'] as String? ?? documentId,
      name: data['name'] as String? ??
          data['title'] as String? ??
          data['itemName'] as String? ??
          'Unbenannter Artikel',
      price: (data['price'] as num?)?.toDouble() ??
          (data['originalPrice'] as num?)?.toDouble(),
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }
}

class MerchantFreeItemDealsPage extends StatefulWidget {
  const MerchantFreeItemDealsPage({
    super.key,
    required this.merchantId,
    required this.shopName,
  });

  final String merchantId;
  final String shopName;

  @override
  State<MerchantFreeItemDealsPage> createState() =>
      _MerchantFreeItemDealsPageState();
}

class _MerchantFreeItemDealsPageState extends State<MerchantFreeItemDealsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<MerchantFreeItemDealDraft> deals = [];
  final List<MerchantItemOption> merchantItems = [];

  int selectedIndex = 0;

  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  MerchantFreeItemDealDraft get currentDeal => deals[selectedIndex];

  CollectionReference<Map<String, dynamic>> get _freeDealsRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('freeItemDeals');
  }

  CollectionReference<Map<String, dynamic>> get _itemsRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('items');
  }

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadEverything() async {
    setState(() => isLoading = true);

    try {
      await Future.wait([
        _loadMerchantItems(),
        _loadDeals(),
      ]);

      if (deals.isEmpty) {
        deals.add(_defaultDeal());
      }

      selectedIndex = 0;
      _syncControllersFromCurrent();

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (error) {
      debugPrint('Fehler beim Laden Free Item Deals: $error');

      if (deals.isEmpty) {
        deals.add(_defaultDeal());
        selectedIndex = 0;
        _syncControllersFromCurrent();
      }

      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Gratis-Aktionen konnten nicht geladen werden');
    }
  }

  Future<void> _loadMerchantItems() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _itemsRef.get();
    } catch (_) {
      snapshot = await _itemsRef.get();
    }

    final items = snapshot.docs
        .map(
          (doc) => MerchantItemOption.fromFirestore(
        doc.id,
        doc.data(),
      ),
    )
        .toList();

    items.sort((a, b) => a.name.compareTo(b.name));

    merchantItems
      ..clear()
      ..addAll(items);
  }

  Future<void> _loadDeals() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _freeDealsRef.orderBy('updatedAt', descending: true).get();
    } catch (_) {
      snapshot = await _freeDealsRef.get();
    }

    deals
      ..clear()
      ..addAll(
        snapshot.docs.map(
              (doc) => MerchantFreeItemDealDraft.fromFirestore(
            doc.id,
            doc.data(),
          ),
        ),
      );
  }

  void _syncControllersFromCurrent() {
    titleController.text = currentDeal.title;
    subtitleController.text = currentDeal.subtitle;
    descriptionController.text = currentDeal.description;
  }

  void _syncCurrentFromControllers() {
    currentDeal.title = titleController.text.trim().isEmpty
        ? 'Kaufe X, erhalte Y gratis'
        : titleController.text.trim();

    currentDeal.subtitle = subtitleController.text.trim().isEmpty
        ? 'Gratis-Artikel beim Kauf'
        : subtitleController.text.trim();

    currentDeal.description = descriptionController.text.trim();
  }

  Future<void> _saveCurrentDeal() async {
    _syncCurrentFromControllers();

    if (currentDeal.title.trim().isEmpty) {
      _showMessage('Bitte Titel eingeben');
      return;
    }

    if (currentDeal.buyItemId.isEmpty) {
      _showMessage('Bitte Kauf-Artikel auswählen');
      return;
    }

    if (currentDeal.freeItemId.isEmpty) {
      _showMessage('Bitte Gratis-Artikel auswählen');
      return;
    }

    if (currentDeal.startDate == null || currentDeal.endDate == null) {
      _showMessage('Bitte Beginn und Ende auswählen');
      return;
    }

    if (currentDeal.endDate!.isBefore(currentDeal.startDate!)) {
      _showMessage('Enddatum darf nicht vor Beginn liegen');
      return;
    }

    setState(() => isSaving = true);

    try {
      final doc = _freeDealsRef.doc(currentDeal.id);
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

      await _loadEverything();
    } catch (error) {
      debugPrint('Fehler beim Speichern Free Item Deal: $error');

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
      _showMessage('Mindestens eine Aktion muss bleiben');
      return;
    }

    final dealToDelete = currentDeal;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Aktion löschen?'),
          content: Text(
            '„${dealToDelete.title}“ wird gelöscht.',
          ),
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
      await _freeDealsRef.doc(dealToDelete.id).delete();

      if (!mounted) return;

      setState(() {
        deals.removeWhere((deal) => deal.id == dealToDelete.id);
        selectedIndex = selectedIndex.clamp(0, deals.length - 1);
        _syncControllersFromCurrent();
      });

      _showMessage('Aktion gelöscht');
    } catch (error) {
      debugPrint('Fehler beim Löschen: $error');
      _showMessage('Löschen fehlgeschlagen');
    }
  }

  void _openItemPicker({
    required bool isBuyItem,
  }) {
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
        if (merchantItems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Keine Artikel gefunden',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lege zuerst Artikel unter „Meine Artikel“ an.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentSoft,
                      foregroundColor: AppColors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Okay'),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Text(
              isBuyItem ? 'Kauf-Artikel wählen' : 'Gratis-Artikel wählen',
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            ...merchantItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_rounded),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                    ),
                  ),
                  subtitle: Text(
                    item.price == null
                        ? 'Preis nicht gesetzt'
                        : '${_formatPrice(item.price!)} €',
                  ),
                  onTap: () {
                    setState(() {
                      if (isBuyItem) {
                        currentDeal.buyItemId = item.id;
                        currentDeal.buyItemName = item.name;
                      } else {
                        currentDeal.freeItemId = item.id;
                        currentDeal.freeItemName = item.name;
                      }
                    });

                    Navigator.pop(context);
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _pickDate({
    required bool isStart,
  }) async {
    final initialDate = isStart
        ? currentDeal.startDate ?? DateTime.now()
        : currentDeal.endDate ?? currentDeal.startDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        currentDeal.startDate = picked;

        if (currentDeal.endDate != null &&
            currentDeal.endDate!.isBefore(currentDeal.startDate!)) {
          currentDeal.endDate = picked;
        }
      } else {
        currentDeal.endDate = picked;
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

  String _formatPrice(double price) {
    return price.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  MerchantFreeItemDealDraft _defaultDeal() {
    final now = DateTime.now();

    return MerchantFreeItemDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: widget.merchantId,
      shopName: widget.shopName,
      title: 'Kaufe X, erhalte Y gratis',
      subtitle: 'Gratis-Artikel beim Kauf',
      description: '',
      buyItemId: '',
      buyItemName: 'Kauf-Artikel wählen',
      freeItemId: '',
      freeItemName: 'Gratis-Artikel wählen',
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
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
            _sectionTitle('Gratis-Kombi'),
            const SizedBox(height: 10),
            _comboCard(),
            const SizedBox(height: 12),
            _mainInfoCard(),
            const SizedBox(height: 12),
            _dateCard(),
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
                'Gratis-Aktion',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kaufe Artikel X, erhalte Y gratis',
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
                      'Neue Aktion',
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
                    Icons.card_giftcard_rounded,
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
      height: 190,
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
          _heroItemBox(
            label: 'Kauf',
            title: currentDeal.buyItemName,
            icon: Icons.shopping_bag_rounded,
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 12),
          _heroItemBox(
            label: 'Gratis',
            title: currentDeal.freeItemName,
            icon: Icons.card_giftcard_rounded,
          ),
        ],
      ),
    );
  }

  Widget _heroItemBox({
    required String label,
    required String title,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.black,
              size: 34,
            ),
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
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comboCard() {
    return _baseCard(
      child: Column(
        children: [
          _pickerRow(
            icon: Icons.shopping_bag_outlined,
            title: 'Kauf Artikel',
            value: currentDeal.buyItemName,
            onTap: () => _openItemPicker(isBuyItem: true),
          ),
          const Divider(),
          _pickerRow(
            icon: Icons.card_giftcard_outlined,
            title: 'Gratis Artikel',
            value: currentDeal.freeItemName,
            onTap: () => _openItemPicker(isBuyItem: false),
          ),
        ],
      ),
    );
  }

  Widget _pickerRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(value),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
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
            onChanged: (value) => currentDeal.title = value,
            decoration: const InputDecoration(
              labelText: 'Titel',
              hintText: 'z. B. Kaufe Shawarma, erhalte Ayran gratis',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: subtitleController,
            onChanged: (value) => currentDeal.subtitle = value,
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
                  value: _formatDate(currentDeal.startDate),
                  icon: Icons.play_arrow_rounded,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateButton(
                  title: 'Ende',
                  value: _formatDate(currentDeal.endDate),
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
            icon: currentDeal.isActive
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            bg: currentDeal.isActive ? AppColors.accentSoft : AppColors.inputFill,
            fg: AppColors.black,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Aktion aktiv',
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
          isSaving ? 'Speichert...' : 'Aktuelle Aktion speichern',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
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