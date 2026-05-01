import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class MerchantRescueDealDraft {
  MerchantRescueDealDraft({
    required this.id,
    required this.merchantId,
    required this.shopName,
    required this.title,
    required this.itemId,
    required this.itemName,
    required this.itemImageUrl,
    required this.itemOriginalPrice,
    required this.newPrice,
    required this.quantityAvailable,
    required this.quantityInitial,
    required this.rescueType,
    required this.bestBeforeDate,
    this.availableUntil,
    required this.isActive,
    required this.isArchived,
    required this.soldOut,
  });

  final String id;
  String merchantId;
  String shopName;
  String title;

  String itemId;
  String itemName;
  String itemImageUrl;
  double itemOriginalPrice;

  double newPrice;
  int quantityAvailable;
  int quantityInitial;

  String rescueType; // 'mhd' | 'fresh_today'
  DateTime? bestBeforeDate;
  DateTime? availableUntil;

  bool isActive;
  bool isArchived;
  bool soldOut;

  factory MerchantRescueDealDraft.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return MerchantRescueDealDraft(
      id: data['id'] as String? ?? documentId,
      merchantId: data['merchantId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      title: data['title'] as String? ?? 'Rette mich',
      itemId: data['itemId'] as String? ?? '',
      itemName: data['itemName'] as String? ?? 'Artikel wählen',
      itemImageUrl: data['itemImageUrl'] as String? ?? '',
      itemOriginalPrice: (data['itemOriginalPrice'] as num?)?.toDouble() ?? 0.0,
      newPrice: (data['newPrice'] as num?)?.toDouble() ?? 0.0,
      quantityAvailable: data['quantityAvailable'] as int? ?? 0,
      quantityInitial: data['quantityInitial'] as int? ?? 0,
      rescueType: data['rescueType'] as String? ?? 'mhd',
      bestBeforeDate: parseDate(data['bestBeforeDate']),
      availableUntil: parseDate(data['availableUntil']),
      isActive: data['isActive'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
      soldOut: data['soldOut'] as bool? ?? false,
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
      'type': 'rescue_deal',
      'title': title,
      'itemId': itemId,
      'itemName': itemName,
      'itemImageUrl': itemImageUrl,
      'itemOriginalPrice': itemOriginalPrice,
      'newPrice': newPrice,
      'quantityAvailable': quantityAvailable,
      'quantityInitial': quantityInitial,
      'rescueType': rescueType,
      'bestBeforeDate': bestBeforeDate == null ? null : Timestamp.fromDate(bestBeforeDate!),
      'availableUntil': availableUntil == null ? null : Timestamp.fromDate(availableUntil!),
      'isActive': isActive,
      'isArchived': isArchived,
      'soldOut': soldOut,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MerchantRescueDealDraft copyWithNewId() {
    return MerchantRescueDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: merchantId,
      shopName: shopName,
      title: '$title Kopie',
      itemId: itemId,
      itemName: itemName,
      itemImageUrl: itemImageUrl,
      itemOriginalPrice: itemOriginalPrice,
      newPrice: newPrice,
      quantityAvailable: quantityAvailable,
      quantityInitial: quantityInitial,
      rescueType: rescueType,
      bestBeforeDate: bestBeforeDate,
      availableUntil: availableUntil,
      isActive: false,
      isArchived: false,
      soldOut: false,
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

class MerchantRescueDealsPage extends StatefulWidget {
  const MerchantRescueDealsPage({
    super.key,
    required this.merchantId,
    required this.shopName,
  });

  final String merchantId;
  final String shopName;

  @override
  State<MerchantRescueDealsPage> createState() => _MerchantRescueDealsPageState();
}

class _MerchantRescueDealsPageState extends State<MerchantRescueDealsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<MerchantRescueDealDraft> deals = [];
  final List<MerchantItemOption> merchantItems = [];

  int selectedIndex = 0;

  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  MerchantRescueDealDraft get currentDeal => deals[selectedIndex];

  CollectionReference<Map<String, dynamic>> get _rescueDealsRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('rescueDeals');
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
    priceController.dispose();
    quantityController.dispose();
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
      debugPrint('Fehler beim Laden Rescue Deals: $error');
      if (deals.isEmpty) deals.add(_defaultDeal());
      selectedIndex = 0;
      _syncControllersFromCurrent();
      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Aktionen konnten nicht geladen werden');
    }
  }

  Future<void> _loadMerchantItems() async {
    final snapshot = await _itemsRef.get();
    final items = snapshot.docs
        .map((doc) => MerchantItemOption.fromFirestore(doc.id, doc.data()))
        .toList();
    items.sort((a, b) => a.name.compareTo(b.name));
    merchantItems..clear()..addAll(items);
  }

  Future<void> _loadDeals() async {
    final snapshot = await _rescueDealsRef.orderBy('updatedAt', descending: true).get();
    deals..clear()..addAll(
      snapshot.docs.map((doc) => MerchantRescueDealDraft.fromFirestore(doc.id, doc.data())),
    );
  }

  void _syncControllersFromCurrent() {
    priceController.text = currentDeal.newPrice.toStringAsFixed(2);
    quantityController.text = currentDeal.quantityAvailable.toString();
  }

  void _syncCurrentFromControllers() {
    currentDeal.newPrice = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;
    currentDeal.quantityAvailable = int.tryParse(quantityController.text) ?? 0;
    if (currentDeal.quantityInitial == 0) {
      currentDeal.quantityInitial = currentDeal.quantityAvailable;
    }
  }

  Future<void> _saveCurrentDeal() async {
    _syncCurrentFromControllers();

    if (currentDeal.itemId.isEmpty) {
      _showMessage('Bitte Artikel auswählen');
      return;
    }
    if (currentDeal.bestBeforeDate == null) {
      _showMessage('MHD-Datum ist Pflicht');
      return;
    }

    setState(() => isSaving = true);

    try {
      final doc = _rescueDealsRef.doc(currentDeal.id);
      final data = currentDeal.toFirestoreMap(
        merchantId: widget.merchantId,
        shopName: widget.shopName,
      );
      await doc.set(data, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => isSaving = false);
      _showMessage('Gespeichert');
      await _loadEverything();
    } catch (error) {
      debugPrint('Fehler beim Speichern: $error');
      if (!mounted) return;
      setState(() => isSaving = false);
      _showMessage('Fehler beim Speichern');
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Löschen?'),
        content: Text('„${currentDeal.itemName}“ wird gelöscht.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.accentSoft, foregroundColor: AppColors.black),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _rescueDealsRef.doc(currentDeal.id).delete();
      setState(() {
        deals.removeAt(selectedIndex);
        selectedIndex = selectedIndex.clamp(0, deals.length - 1);
        _syncControllersFromCurrent();
      });
      _showMessage('Gelöscht');
    } catch (_) {
      _showMessage('Fehler beim Löschen');
    }
  }

  void _openItemPicker() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) {
        if (merchantItems.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Keine Artikel gefunden. Bitte zuerst unter „Artikel“ anlegen.', textAlign: TextAlign.center),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text('Artikel wählen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...merchantItems.map((item) => ListTile(
              leading: const Icon(Icons.inventory_2_rounded),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.price != null ? '${item.price!.toStringAsFixed(2)} €' : 'Kein Preis'),
              onTap: () {
                setState(() {
                  currentDeal.itemId = item.id;
                  currentDeal.itemName = item.name;
                  currentDeal.itemImageUrl = item.imageUrl;
                  currentDeal.itemOriginalPrice = item.price ?? 0.0;
                  if (currentDeal.newPrice == 0.0) {
                    currentDeal.newPrice = currentDeal.itemOriginalPrice * 0.5;
                    priceController.text = currentDeal.newPrice.toStringAsFixed(2);
                  }
                });
                Navigator.pop(context);
              },
            )),
          ],
        );
      },
    );
  }

  Future<void> _pickDate({required bool isMhd}) async {
    final initial = isMhd ? currentDeal.bestBeforeDate ?? DateTime.now() : currentDeal.availableUntil ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      if (isMhd) {
        currentDeal.bestBeforeDate = picked;
      } else {
        currentDeal.availableUntil = picked;
      }
    });
  }

  String _formatDate(DateTime? date) => date == null ? 'Wählen' : '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  MerchantRescueDealDraft _defaultDeal() => MerchantRescueDealDraft(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    merchantId: widget.merchantId,
    shopName: widget.shopName,
    title: 'Rette mich',
    itemId: '',
    itemName: 'Artikel wählen',
    itemImageUrl: '',
    itemOriginalPrice: 0.0,
    newPrice: 0.0,
    quantityAvailable: 1,
    quantityInitial: 1,
    rescueType: 'mhd',
    bestBeforeDate: DateTime.now(),
    isActive: false,
    isArchived: false,
    soldOut: false,
  );

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _topBar(),
            const SizedBox(height: 14),
            _dealsSwitcher(),
            const SizedBox(height: 16),
            _previewCard(),
            const SizedBox(height: 12),
            _sectionTitle('Rettungs-Details'),
            const SizedBox(height: 10),
            _itemSelectorCard(),
            const SizedBox(height: 12),
            _priceQuantityCard(),
            const SizedBox(height: 12),
            _typeCard(),
            const SizedBox(height: 12),
            _dateCard(),
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
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rette mich', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text('MHD & Tagesware retten', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w700)),
        ])),
      ],
    );
  }

  Widget _dealsSwitcher() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: deals.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == deals.length) {
            return InkWell(
              onTap: _createNewDeal,
              child: Container(
                width: 100, decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.5), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.add),
              ),
            );
          }
          final deal = deals[index];
          final sel = index == selectedIndex;
          return InkWell(
            onTap: () => setState(() { _syncCurrentFromControllers(); selectedIndex = index; _syncControllersFromCurrent(); }),
            child: Container(
              width: 140, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: sel ? AppColors.accentSoft : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.accent : AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(deal.itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                const Spacer(),
                Text(deal.isActive ? 'Aktiv' : 'Pausiert', style: TextStyle(fontSize: 12, color: deal.isActive ? Colors.black : AppColors.textMuted)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _previewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 70, height: 70, decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(16)),
            child: currentDeal.itemImageUrl.isNotEmpty ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(currentDeal.itemImageUrl, fit: BoxFit.cover)) : const Icon(Icons.fastfood_rounded, color: AppColors.textMuted),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(currentDeal.itemName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Row(children: [
              Text('${currentDeal.newPrice.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.red)),
              const SizedBox(width: 8),
              Text('${currentDeal.itemOriginalPrice.toStringAsFixed(2)} €', style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.textMuted, fontSize: 13)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(12)),
            child: Text('${currentDeal.quantityAvailable}x', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _itemSelectorCard() => _baseCard(child: ListTile(
    contentPadding: EdgeInsets.zero, leading: const Icon(Icons.inventory_2_outlined), title: const Text('Artikel auswählen', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(currentDeal.itemName), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16), onTap: _openItemPicker,
  ));

  Widget _priceQuantityCard() => _baseCard(child: Row(children: [
    Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sonderpreis (€)', prefixIcon: Icon(Icons.euro_rounded)))),
    const SizedBox(width: 12),
    Expanded(child: TextField(controller: quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Menge', prefixIcon: Icon(Icons.pin_rounded)))),
  ]));

  Widget _typeCard() => _baseCard(child: Row(children: [
    Expanded(child: ChoiceChip(label: const Text('MHD-Ware'), selected: currentDeal.rescueType == 'mhd', onSelected: (s) => setState(() => currentDeal.rescueType = 'mhd'))),
    const SizedBox(width: 10),
    Expanded(child: ChoiceChip(label: const Text('Frisch Heute'), selected: currentDeal.rescueType == 'fresh_today', onSelected: (s) => setState(() => currentDeal.rescueType = 'fresh_today'))),
  ]));

  Widget _dateCard() => _baseCard(child: Column(children: [
    _dateRow('MHD Datum (Pflicht)', _formatDate(currentDeal.bestBeforeDate), () => _pickDate(isMhd: true)),
    const Divider(),
    _dateRow('Verfügbar bis (Opt.)', _formatDate(currentDeal.availableUntil), () => _pickDate(isMhd: false)),
  ]));

  Widget _dateRow(String label, String value, VoidCallback onTap) => ListTile(contentPadding: EdgeInsets.zero, title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w900)), onTap: onTap);

  Widget _statusCard() => _baseCard(child: Row(children: [
    const Expanded(child: Text('Aktion aktiv', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
    Switch(value: currentDeal.isActive, onChanged: (v) => setState(() => currentDeal.isActive = v)),
  ]));

  Widget _quickActionsCard() => Row(children: [
    Expanded(child: OutlinedButton.icon(onPressed: _duplicateCurrentDeal, icon: const Icon(Icons.copy), label: const Text('Kopieren'))),
    const SizedBox(width: 12),
    Expanded(child: OutlinedButton.icon(onPressed: _deleteCurrentDeal, icon: const Icon(Icons.delete_outline), label: const Text('Löschen'))),
  ]);

  Widget _saveButton() => SizedBox(width: double.infinity, height: 56, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.accentSoft, foregroundColor: Colors.black), onPressed: isSaving ? null : _saveCurrentDeal, child: Text(isSaving ? 'Speichert...' : 'Aktion speichern', style: const TextStyle(fontWeight: FontWeight.w900))));

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900));

  Widget _baseCard({required Widget child}) => Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 0), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)), child: child);
}
