import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_bundle_deals_page.dart';

class MerchantBundleDealDraft {
  MerchantBundleDealDraft({
    required this.id,
    required this.merchantId,
    required this.shopName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buyItemId,
    required this.buyItemName,
    required this.getItemId,
    required this.getItemName,
    required this.oldPrice,
    required this.newPrice,
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

  String getItemId;
  String getItemName;

  double? oldPrice;
  double? newPrice;

  DateTime? startDate;
  DateTime? endDate;

  bool isActive;
  bool isArchived;

  factory MerchantBundleDealDraft.fromFirestore(
      String documentId,
      Map<String, dynamic> data,
      ) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return MerchantBundleDealDraft(
      id: data['id'] as String? ?? documentId,
      merchantId: data['merchantId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      title: data['title'] as String? ?? '2 für 1 Deal',
      subtitle: data['subtitle'] as String? ?? 'Kaufe eins, erhalte eins dazu',
      description: data['description'] as String? ?? '',
      buyItemId: data['buyItemId'] as String? ?? '',
      buyItemName: data['buyItemName'] as String? ?? 'Artikel auswählen',
      getItemId: data['getItemId'] as String? ?? '',
      getItemName: data['getItemName'] as String? ?? 'Artikel auswählen',
      oldPrice: (data['oldPrice'] as num?)?.toDouble(),
      newPrice: (data['newPrice'] as num?)?.toDouble(),
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
      'type': 'bundle_deal',
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'buyItemId': buyItemId,
      'buyItemName': buyItemName,
      'getItemId': getItemId,
      'getItemName': getItemName,
      'oldPrice': oldPrice,
      'newPrice': newPrice,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'isActive': isActive,
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MerchantBundleDealDraft copyWithNewId() {
    return MerchantBundleDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: merchantId,
      shopName: shopName,
      title: '$title Kopie',
      subtitle: subtitle,
      description: description,
      buyItemId: buyItemId,
      buyItemName: buyItemName,
      getItemId: getItemId,
      getItemName: getItemName,
      oldPrice: oldPrice,
      newPrice: newPrice,
      startDate: startDate,
      endDate: endDate,
      isActive: false,
      isArchived: false,
    );
  }
}

class MerchantShopItemOption {
  const MerchantShopItemOption({
    required this.id,
    required this.name,
    this.price,
  });

  final String id;
  final String name;
  final double? price;

  factory MerchantShopItemOption.fromFirestore(
      String documentId,
      Map<String, dynamic> data,
      ) {
    return MerchantShopItemOption(
      id: documentId,
      name: data['title'] as String? ??
          data['name'] as String? ??
          data['itemName'] as String? ??
          'Unbenannter Artikel',
      price: (data['price'] as num?)?.toDouble(),
    );
  }
}

class MerchantBundleDealsPage extends StatefulWidget {
  const MerchantBundleDealsPage({
    super.key,
    required this.merchantId,
    required this.shopName,
  });

  final String merchantId;
  final String shopName;

  @override
  State<MerchantBundleDealsPage> createState() =>
      _MerchantBundleDealsPageState();
}

class _MerchantBundleDealsPageState extends State<MerchantBundleDealsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<MerchantBundleDealDraft> deals = [];
  final List<MerchantShopItemOption> merchantItems = [];

  int selectedIndex = 0;

  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController oldPriceController = TextEditingController();
  final TextEditingController newPriceController = TextEditingController();

  MerchantBundleDealDraft get currentDeal => deals[selectedIndex];

  CollectionReference<Map<String, dynamic>> get _bundleDealsRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('bundleDeals');
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
    oldPriceController.dispose();
    newPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadEverything() async {
    setState(() => isLoading = true);

    try {
      await Future.wait([
        _loadMerchantItems(),
        _loadBundleDeals(),
      ]);

      if (deals.isEmpty) {
        deals.add(_defaultDeal());
      }

      selectedIndex = 0;
      _syncControllersFromCurrent();

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (error) {
      debugPrint('Fehler beim Laden: $error');

      if (deals.isEmpty) {
        deals.add(_defaultDeal());
        selectedIndex = 0;
        _syncControllersFromCurrent();
      }

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bundle Deals konnten nicht geladen werden'),
        ),
      );
    }
  }

  Future<void> _loadMerchantItems() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _itemsRef.orderBy('title').get();
    } catch (_) {
      snapshot = await _itemsRef.get();
    }

    merchantItems
      ..clear()
      ..addAll(
        snapshot.docs.map(
              (doc) => MerchantShopItemOption.fromFirestore(
            doc.id,
            doc.data(),
          ),
        ),
      );
  }

  Future<void> _loadBundleDeals() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _bundleDealsRef.orderBy('updatedAt', descending: true).get();
    } catch (_) {
      snapshot = await _bundleDealsRef.get();
    }

    deals
      ..clear()
      ..addAll(
        snapshot.docs.map(
              (doc) => MerchantBundleDealDraft.fromFirestore(
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

    oldPriceController.text = currentDeal.oldPrice == null
        ? ''
        : _formatPriceInput(currentDeal.oldPrice!);

    newPriceController.text = currentDeal.newPrice == null
        ? ''
        : _formatPriceInput(currentDeal.newPrice!);
  }

  void _syncCurrentFromControllers() {
    currentDeal.title = titleController.text.trim().isEmpty
        ? '2 für 1 Deal'
        : titleController.text.trim();

    currentDeal.subtitle = subtitleController.text.trim().isEmpty
        ? 'Kaufe eins, erhalte eins dazu'
        : subtitleController.text.trim();

    currentDeal.description = descriptionController.text.trim();

    currentDeal.oldPrice = double.tryParse(
      oldPriceController.text.trim().replaceAll(',', '.'),
    );

    currentDeal.newPrice = double.tryParse(
      newPriceController.text.trim().replaceAll(',', '.'),
    );
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

    if (currentDeal.getItemId.isEmpty) {
      _showMessage('Bitte Erhalte-Artikel auswählen');
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
      final doc = _bundleDealsRef.doc(currentDeal.id);
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${currentDeal.title} gespeichert'),
        ),
      );

      await _loadEverything();
    } catch (error) {
      debugPrint('Fehler beim Speichern: $error');

      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speichern fehlgeschlagen'),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mindestens ein Bundle Deal muss bleiben'),
        ),
      );
      return;
    }

    final dealToDelete = currentDeal;


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
              isBuyItem ? 'Kauf-Artikel wählen' : 'Erhalte-Artikel wählen',
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
                        : '${_formatPriceInput(item.price!)} €',
                  ),
                  onTap: () {
                    setState(() {
                      if (isBuyItem) {
                        currentDeal.buyItemId = item.id;
                        currentDeal.buyItemName = item.name;
                      } else {
                        currentDeal.getItemId = item.id;
                        currentDeal.getItemName = item.name;
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

  String _formatPriceInput(double price) {
    return price.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  MerchantBundleDealDraft _defaultDeal() {
    final now = DateTime.now();

    return MerchantBundleDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: widget.merchantId,
      shopName: widget.shopName,
      title: '2 für 1 Deal',
      subtitle: 'Kaufe Artikel X und erhalte Artikel Y',
      description: '',
      buyItemId: '',
      buyItemName: 'Kauf-Artikel wählen',
      getItemId: '',
      getItemName: 'Erhalte-Artikel wählen',
      oldPrice: null,
      newPrice: null,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _dealsSwitcher(),
          const SizedBox(height: 16),
          _heroCard(),
          const SizedBox(height: 12),
          _sectionTitle('Artikel-Kombi'),
          const SizedBox(height: 10),
          _comboCard(),
          const SizedBox(height: 12),
          _mainInfoCard(),
          const SizedBox(height: 12),
          _dateCard(),
          const SizedBox(height: 12),
          _priceCard(),
          const SizedBox(height: 12),
          _descriptionCard(),
          const SizedBox(height: 18),
          _sectionTitle('Sichtbarkeit'),
          const SizedBox(height: 10),
          _statusCard(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: isSaving ? null : _saveCurrentDeal,
            icon: isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.save_outlined),
            label: Text(isSaving ? 'Speichert...' : 'Bundle Deal speichern'),
          ),
        ],
      ),
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
                      'Neuer Deal',
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
                    ? const Color(0xFFFFD6D9)
                    : AppColors.surface.withOpacity(0.88),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? const Color(0xFFE8757C) : AppColors.border,
                  width: selected ? 1.4 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.filter_2_rounded,
                    color: Color(0xFFB5121B),
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
                      color: deal.isActive
                          ? const Color(0xFF168A46)
                          : AppColors.textMuted,
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
        color: const Color(0xFFFFD6D9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE8757C),
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
              color: AppColors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          _heroItemBox(
            label: 'Erhalte',
            title: currentDeal.getItemName,
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
              color: const Color(0xFFB5121B),
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
            title: 'Erhalte Artikel',
            value: currentDeal.getItemName,
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
              hintText: 'z. B. Shawarma 2 für 1',
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
                  onChanged: (value) {
                    currentDeal.oldPrice = double.tryParse(
                      value.trim().replaceAll(',', '.'),
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'Alter Preis',
                    hintText: 'z. B. 14,00',
                    prefixIcon: Icon(Icons.euro_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: newPriceController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    currentDeal.newPrice = double.tryParse(
                      value.trim().replaceAll(',', '.'),
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'Neuer Preis',
                    hintText: 'z. B. 9,90',
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
            bg: currentDeal.isActive
                ? const Color(0xFFFFD36A)
                : const Color(0xFFE5D2AF),
            fg: AppColors.black,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Deal aktiv',
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