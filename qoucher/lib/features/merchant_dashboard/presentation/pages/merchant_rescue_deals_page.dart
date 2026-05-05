import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:qoucher/core/constants/app_colors.dart';

class MerchantRescueDealDraft {
  MerchantRescueDealDraft({
    required this.id,
    required this.merchantId,
    required this.shopName,
    required this.title,
    required this.description,
    required this.itemId,
    required this.itemName,
    required this.itemImageUrl,
    required this.itemOriginalPrice,
    required this.itemSource,
    required this.newPrice,
    required this.quantityAvailable,
    required this.quantityInitial,
    required this.rescueType,
    required this.bestBeforeDate,
    required this.availableUntil,
    required this.isActive,
    required this.isArchived,
    required this.soldOut,
  });

  factory MerchantRescueDealDraft.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return MerchantRescueDealDraft(
      id: data['id']?.toString() ?? documentId,
      merchantId: data['merchantId']?.toString() ?? '',
      shopName: data['merchantName']?.toString() ??
          data['shopName']?.toString() ??
          '',
      title: data['title']?.toString() ?? 'Rette mich',
      description: data['description']?.toString() ?? '',
      itemId: data['itemId']?.toString() ?? '',
      itemName: data['itemName']?.toString() ?? 'Artikel wählen',
      itemImageUrl: data['itemImageUrl']?.toString() ?? '',
      itemOriginalPrice: (data['itemOriginalPrice'] as num?)?.toDouble() ?? 0.0,
      itemSource: data['itemSource']?.toString() ?? 'items',
      newPrice: (data['newPrice'] as num?)?.toDouble() ?? 0.0,
      quantityAvailable: (data['quantityAvailable'] as num?)?.toInt() ?? 1,
      quantityInitial: (data['quantityInitial'] as num?)?.toInt() ?? 1,
      rescueType: data['rescueType']?.toString() ?? 'mhd',
      bestBeforeDate: parseDate(data['bestBeforeDate']),
      availableUntil: parseDate(data['availableUntil']),
      isActive: data['isActive'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
      soldOut: data['soldOut'] as bool? ?? false,
    );
  }

  final String id;

  String merchantId;
  String shopName;
  String title;
  String description;

  String itemId;
  String itemName;
  String itemImageUrl;
  double itemOriginalPrice;
  String itemSource; // items | custom

  double newPrice;
  int quantityAvailable;
  int quantityInitial;

  String rescueType; // mhd | fresh_today | rest_stock | closing_time
  DateTime? bestBeforeDate;
  DateTime? availableUntil;

  bool isActive;
  bool isArchived;
  bool soldOut;

  bool get hasItem => itemId.trim().isNotEmpty;
  bool get hasPrice => newPrice > 0;
  bool get hasQuantity => quantityAvailable > 0;

  bool get needsBestBeforeDate => rescueType == 'mhd';
  bool get needsAvailableUntil => rescueType != 'mhd';

  bool get canGoLive {
    final hasRequiredDate = needsBestBeforeDate
        ? bestBeforeDate != null
        : availableUntil != null;

    return title.trim().isNotEmpty &&
        hasItem &&
        hasPrice &&
        hasQuantity &&
        hasRequiredDate &&
        !soldOut;
  }

  String get rescueTypeLabel {
    switch (rescueType) {
      case 'fresh_today':
        return 'Frisch heute';
      case 'rest_stock':
        return 'Restbestand';
      case 'closing_time':
        return 'Kurz vor Ladenschluss';
      case 'mhd':
      default:
        return 'MHD-Ware';
    }
  }

  double get discountPercent {
    if (itemOriginalPrice <= 0 || newPrice <= 0) return 0;
    final percent = 100 - ((newPrice / itemOriginalPrice) * 100);
    return percent.clamp(0, 99).toDouble();
  }

  String get feedSubtitle {
    if (itemName == 'Artikel wählen') return rescueTypeLabel;
    return '$itemName retten · $rescueTypeLabel';
  }

  Map<String, dynamic> toFeedMap({
    required String merchantId,
    required String merchantName,
    required String area,
    required List<String> shopTypes,
  }) {
    final outOfStock = quantityAvailable <= 0 || soldOut;

    return {
      'id': id,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'shopName': merchantName,
      'area': area,
      'shopTypes': shopTypes,
      'type': 'rescue',
      'title': title.trim().isEmpty ? 'Rette mich' : title.trim(),
      'subtitle': feedSubtitle,
      'description': description.trim(),
      'itemId': itemId,
      'itemName': itemName,
      'itemImageUrl': itemImageUrl,
      'itemOriginalPrice': itemOriginalPrice,
      'itemSource': itemSource,
      'oldPrice': itemOriginalPrice,
      'newPrice': newPrice,
      'discountPercent': discountPercent,
      'quantityAvailable': quantityAvailable,
      'quantityInitial': quantityInitial,
      'rescueType': rescueType,
      'rescueTypeLabel': rescueTypeLabel,
      'bestBeforeDate': bestBeforeDate == null ? null : Timestamp.fromDate(bestBeforeDate!),
      'availableUntil': availableUntil == null ? null : Timestamp.fromDate(availableUntil!),
      'isActive': outOfStock ? false : isActive,
      'isArchived': isArchived,
      'soldOut': outOfStock,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MerchantRescueDealDraft copyWithNewId() {
    return MerchantRescueDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: merchantId,
      shopName: shopName,
      title: '$title Kopie',
      description: description,
      itemId: itemId,
      itemName: itemName,
      itemImageUrl: itemImageUrl,
      itemOriginalPrice: itemOriginalPrice,
      itemSource: itemSource,
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

  factory MerchantItemOption.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return MerchantItemOption(
      id: data['id']?.toString() ?? documentId,
      name: data['name']?.toString() ??
          data['title']?.toString() ??
          data['itemName']?.toString() ??
          'Unbenannter Artikel',
      price: (data['price'] as num?)?.toDouble() ??
          (data['originalPrice'] as num?)?.toDouble(),
      imageUrl: data['imageUrl']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final double? price;
  final String imageUrl;
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

  String area = '';
  List<String> shopTypes = [];

  Timer? _saveTimer;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  MerchantRescueDealDraft get currentDeal => deals[selectedIndex];

  CollectionReference<Map<String, dynamic>> get _feedRef {
    return _firestore.collection('feed');
  }

  CollectionReference<Map<String, dynamic>> get _merchantsRef {
    return _firestore.collection('merchants');
  }

  CollectionReference<Map<String, dynamic>> get _itemsRef {
    return _merchantsRef.doc(widget.merchantId).collection('items');
  }

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadEverything() async {
    setState(() => isLoading = true);

    try {
      await Future.wait([
        _loadMerchantMeta(),
        _loadMerchantItems(),
        _loadDeals(),
      ]);

      if (deals.isEmpty) {
        final draft = _defaultDeal();
        deals.add(draft);
        await _saveDeal(draft, silent: true);
      }

      selectedIndex = 0;
      _syncControllersFromCurrent();
    } catch (error) {
      debugPrint('Fehler beim Laden Rescue Deals: $error');

      if (deals.isEmpty) {
        deals.add(_defaultDeal());
        selectedIndex = 0;
        _syncControllersFromCurrent();
      }

      _showMessage('Aktionen konnten nicht geladen werden', error: true);
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadMerchantMeta() async {
    final merchantDoc = await _merchantsRef.doc(widget.merchantId).get();
    final data = merchantDoc.data() ?? {};

    area = data['area']?.toString() ?? '';
    shopTypes = (data['shopTypes'] as List?)
            ?.map((item) => item.toString())
            .toList() ??
        [];
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
          (doc) => MerchantItemOption.fromFirestore(doc.id, doc.data()),
        ),
      );

    merchantItems.sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _loadDeals() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _feedRef
          .where('merchantId', isEqualTo: widget.merchantId)
          .where('type', isEqualTo: 'rescue')
          .orderBy('updatedAt', descending: true)
          .get();
    } catch (_) {
      snapshot = await _feedRef
          .where('merchantId', isEqualTo: widget.merchantId)
          .where('type', isEqualTo: 'rescue')
          .get();
    }

    deals
      ..clear()
      ..addAll(
        snapshot.docs.map(
          (doc) => MerchantRescueDealDraft.fromFirestore(doc.id, doc.data()),
        ),
      );
  }

  void _syncControllersFromCurrent() {
    titleController.text = currentDeal.title;
    descriptionController.text = currentDeal.description;
    priceController.text = currentDeal.newPrice <= 0 ? '' : _money(currentDeal.newPrice);
    quantityController.text = currentDeal.quantityAvailable.toString();
  }

  void _syncCurrentFromControllers() {
    currentDeal.title = titleController.text.trim();
    currentDeal.description = descriptionController.text.trim();
    currentDeal.newPrice = _parseMoney(priceController.text) ?? 0.0;
    currentDeal.quantityAvailable = int.tryParse(quantityController.text.trim()) ?? 0;

    if (currentDeal.quantityInitial <= 0 ||
        currentDeal.quantityInitial < currentDeal.quantityAvailable) {
      currentDeal.quantityInitial = currentDeal.quantityAvailable;
    }

    currentDeal.soldOut = currentDeal.quantityAvailable <= 0;
    if (currentDeal.soldOut) currentDeal.isActive = false;
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
    MerchantRescueDealDraft deal, {
    bool silent = false,
  }) async {
    if (!mounted) return;

    setState(() => isSaving = true);

    try {
      if (deal.isActive && !deal.canGoLive) {
        deal.isActive = false;
        _showMessage(
          'Live geht erst, wenn Artikel, Preis, Menge und Pflichtdatum vollständig sind',
          error: true,
        );
      }

      final doc = _feedRef.doc(deal.id);
      final exists = (await doc.get()).exists;

      final data = deal.toFeedMap(
        merchantId: widget.merchantId,
        merchantName: widget.shopName,
        area: area,
        shopTypes: shopTypes,
      );

      if (!exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await doc.set(data, SetOptions(merge: true));

      if (!silent) {
        _showMessage('${deal.title.isEmpty ? 'Rette mich' : deal.title} gespeichert');
      }
    } catch (error) {
      debugPrint('Fehler beim Speichern: $error');
      _showMessage('Speichern fehlgeschlagen', error: true);
    }

    if (mounted) setState(() => isSaving = false);
  }

  Future<void> _createNewDeal() async {
    await _saveCurrent(silent: true);

    final deal = _defaultDeal();

    setState(() {
      deals.add(deal);
      selectedIndex = deals.length - 1;
      _syncControllersFromCurrent();
    });

    await _saveDeal(deal, silent: false);
  }

  Future<void> _duplicateCurrentDeal() async {
    await _saveCurrent(silent: true);

    final copy = currentDeal.copyWithNewId();

    setState(() {
      deals.add(copy);
      selectedIndex = deals.length - 1;
      _syncControllersFromCurrent();
    });

    await _saveDeal(copy, silent: false);
  }

  void _openDeleteSheet() {
    bool secondStep = false;

    _darkSheet(
      title: 'Rescue-Deal löschen',
      subtitle: 'Dieser Feed-Post wird endgültig entfernt.',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.white.withOpacity(0.14)),
                ),
                child: Text(
                  secondStep
                      ? 'Letzte Warnung. Dieser Rescue-Deal verschwindet aus dem Feed.'
                      : 'Willst du „${currentDeal.itemName}“ wirklich löschen?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (!secondStep)
                _lightButton(
                  text: 'Ja, weiter',
                  onTap: () => setSheetState(() => secondStep = true),
                )
              else
                _dangerButton(
                  text: 'Endgültig löschen',
                  onTap: () async {
                    Navigator.pop(context);
                    await _deleteCurrentDeal();
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteCurrentDeal() async {
    if (deals.length <= 1) {
      _showMessage('Mindestens eine Aktion muss bleiben', error: true);
      return;
    }

    final deal = currentDeal;

    try {
      await _feedRef.doc(deal.id).delete();

      setState(() {
        deals.removeWhere((item) => item.id == deal.id);
        selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : 0;
        _syncControllersFromCurrent();
      });

      _showMessage('Deal gelöscht');
    } catch (_) {
      _showMessage('Löschen fehlgeschlagen', error: true);
    }
  }

  MerchantRescueDealDraft _defaultDeal() {
    return MerchantRescueDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: widget.merchantId,
      shopName: widget.shopName,
      title: 'Rette mich',
      description: '',
      itemId: '',
      itemName: 'Artikel wählen',
      itemImageUrl: '',
      itemOriginalPrice: 0.0,
      itemSource: 'items',
      newPrice: 0.0,
      quantityAvailable: 1,
      quantityInitial: 1,
      rescueType: 'mhd',
      bestBeforeDate: DateTime.now(),
      availableUntil: DateTime.now().add(const Duration(days: 1)),
      isActive: false,
      isArchived: false,
      soldOut: false,
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
          onRefresh: _loadEverything,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _hero(),
              const SizedBox(height: 16),
              _dealsSwitcher(),
              const SizedBox(height: 16),
              _feedPreview(),
              const SizedBox(height: 16),
              _quickStatus(),
              const SizedBox(height: 22),
              _sectionTitle(
                'Was soll gerettet werden?',
                'Artikel wählen oder freien Artikel eintippen.',
              ),
              const SizedBox(height: 12),
              _itemPanel(),
              const SizedBox(height: 22),
              _sectionTitle(
                'Preis & Menge',
                'Rabatt-Chips helfen schnell beim Sonderpreis.',
              ),
              const SizedBox(height: 12),
              _priceQuantityPanel(),
              const SizedBox(height: 22),
              _sectionTitle(
                'Warum retten?',
                'MHD, Tagesware, Restbestand oder Ladenschluss.',
              ),
              const SizedBox(height: 12),
              _rescueTypePanel(),
              const SizedBox(height: 22),
              _sectionTitle(
                'Beschreibung',
                'Optional: Zustand, Menge, Abholhinweis oder Uhrzeit.',
              ),
              const SizedBox(height: 12),
              _descriptionPanel(),
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
            'Rescue Builder',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: 38,
              height: 0.95,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.7,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'MHD, Tagesware und Restbestand schnell sichtbar machen. Weniger Verlust, mehr Bewegung.',
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
              _darkChip('type: rescue'),
              _darkChip('${deals.length} Deals'),
              _darkChip(currentDeal.rescueTypeLabel),
              _darkChip(currentDeal.isArchived ? 'Archiviert' : 'Feed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dealsSwitcher() {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: deals.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == deals.length) {
            return GestureDetector(
              onTap: _createNewDeal,
              child: Container(
                width: 126,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded),
                    SizedBox(height: 8),
                    Text(
                      'Neue Ware',
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

          return GestureDetector(
            onTap: () async {
              await _saveCurrent(silent: true);
              setState(() {
                selectedIndex = index;
                _syncControllersFromCurrent();
              });
            },
            child: Container(
              width: 164,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? AppColors.black : AppColors.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: selected ? AppColors.black : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.recycling_rounded,
                    color: selected ? AppColors.white : AppColors.black,
                  ),
                  const Spacer(),
                  Text(
                    deal.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.white : AppColors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    deal.isActive ? 'Live' : 'Entwurf',
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? AppColors.textDisabled : AppColors.textMuted,
                      fontWeight: FontWeight.w800,
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
                      currentDeal.isActive ? 'Aktive Rescue-Aktion' : 'Entwurf',
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
            currentDeal.title.trim().isEmpty ? 'Rette mich' : currentDeal.title,
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
            currentDeal.feedSubtitle,
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
              _imageBox(size: 98),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDeal.itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _priceBadge(),
                        _softChip('${currentDeal.quantityAvailable}x verfügbar'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _softChip(currentDeal.rescueTypeLabel),
              if (currentDeal.needsBestBeforeDate)
                _softChip('MHD ${_formatDate(currentDeal.bestBeforeDate)}')
              else
                _softChip('bis ${_formatDate(currentDeal.availableUntil)}'),
              if (currentDeal.discountPercent > 0)
                _softChip('-${currentDeal.discountPercent.round()}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_money(currentDeal.newPrice)} €',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (currentDeal.itemOriginalPrice > 0) ...[
            const SizedBox(width: 7),
            Text(
              '${_money(currentDeal.itemOriginalPrice)} €',
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
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
                _showMessage(
                  'Erst Artikel, Preis, Menge und Pflichtdatum ausfüllen',
                  error: true,
                );
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

  Widget _itemPanel() {
    return GestureDetector(
      onTap: _openItemPicker,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            _imageBox(size: 66, dark: true),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                currentDeal.itemName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  Widget _priceQuantityPanel() {
    return _basePanel(
      children: [
        Row(
          children: [
            Expanded(
              child: _input(
                controller: priceController,
                hint: 'Sonderpreis',
                icon: Icons.euro_rounded,
                keyboardType: TextInputType.number,
                onChanged: (_) => _scheduleSave(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _input(
                controller: quantityController,
                hint: 'Menge',
                icon: Icons.pin_rounded,
                keyboardType: TextInputType.number,
                onChanged: (_) => _scheduleSave(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _discountButton(30)),
            const SizedBox(width: 8),
            Expanded(child: _discountButton(50)),
            const SizedBox(width: 8),
            Expanded(child: _discountButton(70)),
          ],
        ),
      ],
    );
  }

  Widget _discountButton(int percent) {
    return GestureDetector(
      onTap: currentDeal.itemOriginalPrice <= 0
          ? null
          : () async {
              final factor = (100 - percent) / 100;
              final value = currentDeal.itemOriginalPrice * factor;

              setState(() {
                currentDeal.newPrice = value;
                priceController.text = _money(value);
              });

              await _saveCurrent(silent: true);
            },
      child: Opacity(
        opacity: currentDeal.itemOriginalPrice <= 0 ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '-$percent%',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rescueTypePanel() {
    final types = [
      ('mhd', 'MHD-Ware', Icons.event_busy_rounded),
      ('fresh_today', 'Frisch heute', Icons.today_rounded),
      ('rest_stock', 'Restbestand', Icons.inventory_2_rounded),
      ('closing_time', 'Ladenschluss', Icons.nights_stay_rounded),
    ];

    return _basePanel(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: types.map((type) {
            final selected = currentDeal.rescueType == type.$1;

            return GestureDetector(
              onTap: () async {
                setState(() {
                  currentDeal.rescueType = type.$1;
                  if (currentDeal.rescueType == 'mhd') {
                    currentDeal.bestBeforeDate ??= DateTime.now();
                  } else {
                    currentDeal.availableUntil ??= DateTime.now().add(const Duration(days: 1));
                  }
                });

                await _saveCurrent(silent: true);
              },
              child: Container(
                width: 150,
                height: 100,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: selected ? AppColors.black : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: selected ? AppColors.black : AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(type.$3, color: selected ? AppColors.white : AppColors.black),
                    const Spacer(),
                    Text(
                      type.$2,
                      style: TextStyle(
                        color: selected ? AppColors.white : AppColors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dateButton(
                title: currentDeal.needsBestBeforeDate ? 'MHD Datum' : 'Verfügbar bis',
                value: currentDeal.needsBestBeforeDate
                    ? _formatDate(currentDeal.bestBeforeDate)
                    : _formatDate(currentDeal.availableUntil),
                onTap: () => _pickDate(isBestBefore: currentDeal.needsBestBeforeDate),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _descriptionPanel() {
    return _basePanel(
      children: [
        _input(
          controller: titleController,
          hint: 'Titel, z. B. Rette mich',
          icon: Icons.title_rounded,
          onChanged: (_) => _scheduleSave(),
        ),
        const SizedBox(height: 10),
        _input(
          controller: descriptionController,
          hint: 'Beschreibung optional, z. B. Heute frisch vorbereitet',
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
          icon: Icons.copy_rounded,
          title: 'Deal duplizieren',
          subtitle: 'Erstellt eine Kopie als Entwurf.',
          onTap: _duplicateCurrentDeal,
        ),
        const Divider(height: 18, color: AppColors.divider),
        _manageRow(
          icon: Icons.delete_forever_rounded,
          title: 'Deal löschen',
          subtitle: 'Zwei Fragen, dann weg.',
          onTap: _openDeleteSheet,
        ),
      ],
    );
  }

  void _openItemPicker() {
    final customController = TextEditingController();
    final customPriceController = TextEditingController();

    _darkSheet(
      title: 'Ware wählen',
      subtitle: 'Nimm einen Artikel aus dem Sortiment oder tippe schnell freie Ware ein.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _sheetInput(
                  controller: customController,
                  hint: 'Freier Artikel, z. B. 5x Bowl',
                  icon: Icons.edit_note_rounded,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 92,
                child: _sheetInput(
                  controller: customPriceController,
                  hint: 'Preis',
                  icon: Icons.euro_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _lightButton(
            text: 'Freie Ware übernehmen',
            onTap: () async {
              final name = customController.text.trim();
              if (name.isEmpty) return;

              final price = _parseMoney(customPriceController.text) ?? 0.0;

              setState(() {
                currentDeal.itemId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                currentDeal.itemName = name;
                currentDeal.itemImageUrl = '';
                currentDeal.itemOriginalPrice = price;
                currentDeal.itemSource = 'custom';
                currentDeal.newPrice = price > 0 ? price * 0.5 : currentDeal.newPrice;
                priceController.text = currentDeal.newPrice > 0 ? _money(currentDeal.newPrice) : '';
              });

              await _saveCurrent(silent: true);
              if (mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
          if (merchantItems.isEmpty)
            const Text(
              'Keine Artikel gefunden. Du kannst oben freie Ware eintragen.',
              style: TextStyle(
                color: AppColors.textDisabled,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...merchantItems.map((item) {
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    currentDeal.itemId = item.id;
                    currentDeal.itemName = item.name;
                    currentDeal.itemImageUrl = item.imageUrl;
                    currentDeal.itemOriginalPrice = item.price ?? 0.0;
                    currentDeal.itemSource = 'items';

                    if (currentDeal.itemOriginalPrice > 0) {
                      currentDeal.newPrice = currentDeal.itemOriginalPrice * 0.5;
                      priceController.text = _money(currentDeal.newPrice);
                    }
                  });

                  await _saveCurrent(silent: true);
                  if (mounted) Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.white.withOpacity(0.14)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: item.imageUrl.isEmpty
                            ? const Icon(Icons.inventory_2_rounded, color: AppColors.black)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(item.imageUrl, fit: BoxFit.cover),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: AppColors.textOnDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.price == null ? 'Preis nicht gesetzt' : '${_money(item.price!)} €',
                              style: const TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isBestBefore}) async {
    final initial = isBestBefore
        ? currentDeal.bestBeforeDate ?? DateTime.now()
        : currentDeal.availableUntil ?? DateTime.now().add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      if (isBestBefore) {
        currentDeal.bestBeforeDate = picked;
      } else {
        currentDeal.availableUntil = picked;
      }
    });

    await _saveCurrent(silent: true);
  }

  Widget _imageBox({required double size, bool dark = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? AppColors.surface : AppColors.inputFill,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: dark ? AppColors.surface : AppColors.border),
      ),
      child: currentDeal.itemImageUrl.isEmpty
          ? Icon(
              Icons.fastfood_rounded,
              color: dark ? AppColors.black : AppColors.textMuted,
              size: size * 0.42,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.24),
              child: Image.network(currentDeal.itemImageUrl, fit: BoxFit.cover),
            ),
    );
  }

  Widget _dateButton({
    required String title,
    required String value,
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
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              value,
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

  Widget _sheetInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textDisabled),
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
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

  double? _parseMoney(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  String _money(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Wählen';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
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
