import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

/* -------------------------------------------------------------------------- */
/* MODELS */
/* -------------------------------------------------------------------------- */

class ExplorerFilterOption {
  const ExplorerFilterOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class ExplorerMerchant {
  const ExplorerMerchant({
    required this.id,
    required this.shopName,
    required this.areaId,
    required this.areaName,
    required this.shopTypeIds,
    required this.shopTypeNames,
    required this.isActive,
  });

  final String id;
  final String shopName;
  final String areaId;
  final String areaName;
  final List<String> shopTypeIds;
  final List<String> shopTypeNames;
  final bool isActive;

  factory ExplorerMerchant.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    final areaId = _readString(
      data,
      [
        'areaId',
        'area',
        'districtId',
        'selectedAreaId',
        'locationId',
      ],
    );

    final areaName = _readString(
      data,
      [
        'areaName',
        'areaLabel',
        'districtName',
        'district',
        'locationName',
      ],
      fallback: areaId,
    );

    final shopTypeIds = _readStringList(
      data,
      [
        'shopTypeIds',
        'shopTypes',
        'shopTypeId',
        'shopType',
        'categoryIds',
        'categories',
        'businessTypes',
      ],
    );

    final shopTypeNames = _readStringList(
      data,
      [
        'shopTypeNames',
        'shopTypeLabels',
        'categoryNames',
        'businessTypeNames',
      ],
    );

    return ExplorerMerchant(
      id: _readString(data, ['id'], fallback: doc.id),
      shopName: _readString(
        data,
        [
          'businessName',
          'shopName',
          'storeName',
          'name',
          'merchantName',
        ],
        fallback: 'Unbekannter Shop',
      ),
      areaId: areaId,
      areaName: areaName,
      shopTypeIds: shopTypeIds,
      shopTypeNames: shopTypeNames,
      isActive: _readBool(
        data,
        [
          'isActive',
          'active',
          'approved',
          'isApproved',
        ],
        fallback: true,
      ),
    );
  }
}

class ExplorerDeal {
  const ExplorerDeal({
    required this.id,
    required this.merchantId,
    required this.shopName,
    required this.areaId,
    required this.areaName,
    required this.shopTypeIds,
    required this.shopTypeNames,
    required this.dealType,
    required this.typeLabel,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.updatedAt,
  });

  final String id;
  final String merchantId;
  final String shopName;

  final String areaId;
  final String areaName;

  final List<String> shopTypeIds;
  final List<String> shopTypeNames;

  final String dealType;
  final String typeLabel;

  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;

  final DateTime updatedAt;
}

class _DealSource {
  const _DealSource({
    required this.collectionName,
    required this.dealType,
    required this.typeLabel,
  });

  final String collectionName;
  final String dealType;
  final String typeLabel;
}

/* -------------------------------------------------------------------------- */
/* PAGE */
/* -------------------------------------------------------------------------- */

class _ExplorerPageState extends State<ExplorerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  String? errorMessage;

  ExplorerFilterOption? selectedArea;
  ExplorerFilterOption? selectedShopType;

  List<ExplorerMerchant> allMerchants = [];
  List<ExplorerMerchant> filteredMerchants = [];

  List<ExplorerFilterOption> areas = [];
  List<ExplorerFilterOption> shopTypes = [];

  List<ExplorerDeal> deals = [];

  final List<_DealSource> dealSources = const [
    _DealSource(
      collectionName: 'freeItemDeals',
      dealType: 'free_item_deal',
      typeLabel: 'Gratis',
    ),
    _DealSource(
      collectionName: 'bundleDeals',
      dealType: 'bundle_deal',
      typeLabel: '2 für 1',
    ),
    _DealSource(
      collectionName: 'happyHourDeals',
      dealType: 'happy_hour_deal',
      typeLabel: 'Happy Hour',
    ),
    _DealSource(
      collectionName: 'customPostDeals',
      dealType: 'custom_post_deal',
      typeLabel: 'Beitrag',
    ),
    _DealSource(
      collectionName: 'rescueDeals',
      dealType: 'rescue_deal',
      typeLabel: 'Rette mich',
    ),
    _DealSource(
      collectionName: 'discountDeals',
      dealType: 'discount_deal',
      typeLabel: 'Rabatt',
    ),
    _DealSource(
      collectionName: 'discountActions',
      dealType: 'discount_deal',
      typeLabel: 'Rabatt',
    ),
    _DealSource(
      collectionName: 'actions',
      dealType: 'action_deal',
      typeLabel: 'Aktion',
    ),
  ];

  CollectionReference<Map<String, dynamic>> get _merchantsRef {
    return _firestore.collection('merchants');
  }

  @override
  void initState() {
    super.initState();
    _loadExplorer();
  }

  Future<void> _loadExplorer() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      debugPrint('--- EXPLORER START ---');

      await _loadMerchants();
      _buildFiltersFromMerchants();
      _applyMerchantFilters();
      await _loadDealsFromFilteredMerchants();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('--- EXPLORER DONE ---');
      debugPrint('MERCHANTS ALL: ${allMerchants.length}');
      debugPrint('MERCHANTS FILTERED: ${filteredMerchants.length}');
      debugPrint('AREAS: ${areas.length}');
      debugPrint('SHOP TYPES: ${shopTypes.length}');
      debugPrint('DEALS: ${deals.length}');
    } catch (error) {
      debugPrint('EXPLORER ERROR: $error');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Future<void> _loadMerchants() async {
    final snapshot = await _merchantsRef.get();

    debugPrint('MERCHANT DOCS COUNT: ${snapshot.docs.length}');

    final loaded = snapshot.docs.map((doc) {
      debugPrint('MERCHANT ${doc.id}: ${doc.data()}');
      return ExplorerMerchant.fromDoc(doc);
    }).where((merchant) {
      return merchant.isActive;
    }).toList();

    allMerchants = loaded;
  }

  void _buildFiltersFromMerchants() {
    final areaMap = <String, ExplorerFilterOption>{};
    final typeMap = <String, ExplorerFilterOption>{};

    for (final merchant in allMerchants) {
      final areaName = merchant.areaName.trim();
      final areaId = merchant.areaId.trim().isEmpty
          ? _normalize(areaName)
          : merchant.areaId.trim();

      if (areaName.isNotEmpty) {
        areaMap[areaId] = ExplorerFilterOption(
          id: areaId,
          name: areaName,
        );
      }

      final maxLength = merchant.shopTypeIds.length > merchant.shopTypeNames.length
          ? merchant.shopTypeIds.length
          : merchant.shopTypeNames.length;

      for (int i = 0; i < maxLength; i++) {
        final rawId = i < merchant.shopTypeIds.length ? merchant.shopTypeIds[i] : '';
        final rawName =
        i < merchant.shopTypeNames.length ? merchant.shopTypeNames[i] : '';

        final name = rawName.trim().isNotEmpty ? rawName.trim() : rawId.trim();
        final id = rawId.trim().isNotEmpty ? rawId.trim() : _normalize(name);

        if (id.isEmpty && name.isEmpty) continue;

        typeMap[id] = ExplorerFilterOption(
          id: id,
          name: name.isEmpty ? id : name,
        );
      }
    }

    areas = areaMap.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    shopTypes = typeMap.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    debugPrint('BUILT AREAS: ${areas.map((e) => e.name).toList()}');
    debugPrint('BUILT SHOP TYPES: ${shopTypes.map((e) => e.name).toList()}');
  }

  void _applyMerchantFilters() {
    filteredMerchants = allMerchants.where((merchant) {
      final areaOk = selectedArea == null ||
          _sameValue(merchant.areaId, selectedArea!.id) ||
          _sameValue(merchant.areaName, selectedArea!.name);

      final typeOk = selectedShopType == null ||
          merchant.shopTypeIds.any((id) => _sameValue(id, selectedShopType!.id)) ||
          merchant.shopTypeIds.any((id) => _sameValue(id, selectedShopType!.name)) ||
          merchant.shopTypeNames.any((name) => _sameValue(name, selectedShopType!.id)) ||
          merchant.shopTypeNames.any((name) => _sameValue(name, selectedShopType!.name));

      return areaOk && typeOk;
    }).toList();
  }

  Future<void> _loadDealsFromFilteredMerchants() async {
    final loadedDeals = <ExplorerDeal>[];

    for (final merchant in filteredMerchants) {
      for (final source in dealSources) {
        loadedDeals.addAll(
          await _loadMerchantDealCollection(
            merchant: merchant,
            source: source,
          ),
        );
      }
    }

    loadedDeals.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    deals = loadedDeals;
  }

  Future<List<ExplorerDeal>> _loadMerchantDealCollection({
    required ExplorerMerchant merchant,
    required _DealSource source,
  }) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _merchantsRef
          .doc(merchant.id)
          .collection(source.collectionName)
          .orderBy('updatedAt', descending: true)
          .get();
    } catch (error) {
      debugPrint(
        '${merchant.shopName}/${source.collectionName} orderBy failed: $error',
      );

      snapshot = await _merchantsRef
          .doc(merchant.id)
          .collection(source.collectionName)
          .get();
    }

    debugPrint(
      '${merchant.shopName}/${source.collectionName}: ${snapshot.docs.length}',
    );

    final result = <ExplorerDeal>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      debugPrint('DEAL ${source.collectionName}/${doc.id}: $data');

      if (!_dealIsVisible(data, source.dealType)) {
        debugPrint('DEAL HIDDEN ${source.collectionName}/${doc.id}');
        continue;
      }

      result.add(
        ExplorerDeal(
          id: _readString(data, ['id'], fallback: doc.id),
          merchantId: merchant.id,
          shopName: merchant.shopName,
          areaId: merchant.areaId,
          areaName: merchant.areaName,
          shopTypeIds: merchant.shopTypeIds,
          shopTypeNames: merchant.shopTypeNames,
          dealType: source.dealType,
          typeLabel: _dealTypeLabel(source, data),
          title: _dealTitle(data, source.dealType),
          subtitle: _dealSubtitle(data, source.dealType),
          description: _readString(
            data,
            ['description', 'body', 'text'],
          ),
          imageUrl: _dealImageUrl(data),
          updatedAt: _parseDate(data['updatedAt']) ??
              _parseDate(data['createdAt']) ??
              DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }

    return result;
  }

  bool _dealIsVisible(Map<String, dynamic> data, String dealType) {
    final isActive = _readBool(
      data,
      ['isActive', 'active', 'published'],
      fallback: false,
    );

    final isArchived = _readBool(
      data,
      ['isArchived', 'archived'],
      fallback: false,
    );

    if (!isActive || isArchived) return false;

    if (dealType == 'rescue_deal') {
      final soldOut = _readBool(
        data,
        ['soldOut', 'isSoldOut'],
        fallback: false,
      );

      final quantity = data['quantityAvailable'] ?? data['quantity'];

      if (soldOut) return false;
      if (quantity is num && quantity <= 0) return false;
    }

    final startDate = _parseDate(data['startDate']);
    final endDate = _parseDate(data['endDate']);

    final now = DateTime.now();

    if (startDate != null && now.isBefore(startDate)) return false;

    if (endDate != null) {
      final endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );

      if (now.isAfter(endOfDay)) return false;
    }

    return true;
  }

  String _dealTypeLabel(_DealSource source, Map<String, dynamic> data) {
    final customType = _readString(data, ['type']);

    if (customType == 'free_item_deal') return 'Gratis';
    if (customType == 'bundle_deal') return '2 für 1';
    if (customType == 'happy_hour_deal') return 'Happy Hour';
    if (customType == 'custom_post_deal') return 'Beitrag';
    if (customType == 'rescue_deal') return 'Rette mich';
    if (customType == 'discount_deal') return 'Rabatt';

    return source.typeLabel;
  }

  String _dealTitle(Map<String, dynamic> data, String dealType) {
    if (dealType == 'rescue_deal') {
      return _readString(
        data,
        ['title', 'itemName', 'name'],
        fallback: 'Rette mich Deal',
      );
    }

    return _readString(
      data,
      ['title', 'name', 'headline'],
      fallback: 'Angebot',
    );
  }

  String _dealSubtitle(Map<String, dynamic> data, String dealType) {
    if (dealType == 'free_item_deal') {
      final buy = _readString(
        data,
        ['buyItemName'],
        fallback: 'Artikel',
      );

      final free = _readString(
        data,
        ['freeItemName', 'getItemName'],
        fallback: 'Gratis Artikel',
      );

      return 'Kaufe $buy, erhalte $free gratis';
    }

    if (dealType == 'bundle_deal') {
      final buy = _readString(
        data,
        ['buyItemName'],
        fallback: 'Artikel',
      );

      final get = _readString(
        data,
        ['getItemName'],
        fallback: 'Artikel',
      );

      return 'Kombi: $buy + $get';
    }

    if (dealType == 'rescue_deal') {
      final price = _readDouble(data, ['newPrice', 'price']);

      if (price != null) {
        return 'Jetzt für ${price.toStringAsFixed(2).replaceAll('.', ',')} €';
      }
    }

    return _readString(
      data,
      ['subtitle', 'shortDescription', 'teaser'],
    );
  }

  String _dealImageUrl(Map<String, dynamic> data) {
    return _readString(
      data,
      [
        'imageUrl',
        'image',
        'photoUrl',
        'itemImageUrl',
        'freeItemImageUrl',
        'coverImageUrl',
      ],
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  bool _sameValue(String a, String b) {
    return _normalize(a) == _normalize(b);
  }

  Future<void> _selectArea(ExplorerFilterOption? area) async {
    Navigator.pop(context);

    setState(() {
      selectedArea = area;
    });

    await _loadExplorer();
  }

  Future<void> _selectShopType(ExplorerFilterOption? type) async {
    Navigator.pop(context);

    setState(() {
      selectedShopType = type;
    });

    await _loadExplorer();
  }

  Future<void> _resetFilters() async {
    setState(() {
      selectedArea = null;
      selectedShopType = null;
    });

    await _loadExplorer();
  }

  void _showAreaPicker() {
    _showPickerSheet(
      title: 'Ort wählen',
      allLabel: 'Alle Orte',
      selected: selectedArea,
      options: areas,
      onSelect: _selectArea,
    );
  }

  void _showShopTypePicker() {
    _showPickerSheet(
      title: 'Kategorie wählen',
      allLabel: 'Alle Kategorien',
      selected: selectedShopType,
      options: shopTypes,
      onSelect: _selectShopType,
    );
  }

  void _showPickerSheet({
    required String title,
    required String allLabel,
    required ExplorerFilterOption? selected,
    required List<ExplorerFilterOption> options,
    required Future<void> Function(ExplorerFilterOption? value) onSelect,
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
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _pickerTile(
                title: allLabel,
                selected: selected == null,
                onTap: () => onSelect(null),
              ),
              if (options.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Keine Einträge gefunden.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ...options.map(
                    (option) => _pickerTile(
                  title: option.name,
                  selected: selected?.id == option.id,
                  onTap: () => onSelect(option),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pickerTile({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.accentSoft : AppColors.inputFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.border,
          width: selected ? 1.3 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: AppColors.black,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  void _handleDealClick(ExplorerDeal deal) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (!isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    _showDealPreviewDialog(deal);
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Login erforderlich'),
          content: const Text(
            'Melde dich an, um weitere Infos zu sehen und Angebote zu nutzen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Später'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentSoft,
                foregroundColor: AppColors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Einloggen'),
            ),
          ],
        );
      },
    );
  }

  void _showDealPreviewDialog(ExplorerDeal deal) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(deal.title),
          content: Text(
            deal.description.trim().isEmpty
                ? 'Detailseite bauen wir später.'
                : deal.description,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.black,
          backgroundColor: AppColors.surface,
          onRefresh: _loadExplorer,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              SliverToBoxAdapter(child: _filterHeader()),
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (errorMessage != null)
                SliverFillRemaining(
                  child: _infoState(
                    icon: Icons.error_outline_rounded,
                    title: 'Explorer konnte nicht geladen werden',
                    text: errorMessage!,
                    actionText: 'Neu laden',
                    onTap: _loadExplorer,
                  ),
                )
              else if (deals.isEmpty)
                  SliverFillRemaining(
                    child: _infoState(
                      icon: Icons.search_off_rounded,
                      title: 'Keine Deals gefunden',
                      text:
                      'Es gibt gerade keine aktiven Angebote für diesen Filter.',
                      actionText: 'Filter zurücksetzen',
                      onTap: _resetFilters,
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: deals.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          index == 0 ? 8 : 0,
                          16,
                          14,
                        ),
                        child: _dealCard(deals[index]),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
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
                  'Explorer',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Finde Angebote in Frankfurt',
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
      ),
    );
  }

  Widget _filterHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _filterBox(
              label: 'Ort',
              value: selectedArea?.name ?? 'Alle Orte',
              icon: Icons.location_on_rounded,
              onTap: _showAreaPicker,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _filterBox(
              label: 'Kategorie',
              value: selectedShopType?.name ?? 'Alle Kategorien',
              icon: Icons.storefront_rounded,
              onTap: _showShopTypePicker,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBox({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.black,
              size: 22,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dealCard(ExplorerDeal deal) {
    return InkWell(
      onTap: () => _handleDealClick(deal),
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dealImage(deal),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (deal.subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      deal.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (deal.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      deal.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.textMuted,
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${deal.shopName} · ${deal.areaName.isEmpty ? 'Frankfurt' : deal.areaName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accentSoft,
                        foregroundColor: AppColors.black,
                      ),
                      onPressed: () => _handleDealClick(deal),
                      child: const Text(
                        'Mehr erfahren',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dealImage(ExplorerDeal deal) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(26),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: deal.imageUrl.trim().isNotEmpty &&
                deal.imageUrl.trim().startsWith('http')
                ? Image.network(
              deal.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _stdImage(),
            )
                : _stdImage(),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.accent,
              ),
            ),
            child: Text(
              deal.typeLabel,
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stdImage() {
    return Image.asset(
      'lib/std.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: AppColors.inputFill,
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              size: 52,
              color: AppColors.textMuted,
            ),
          ),
        );
      },
    );
  }

  Widget _infoState({
    required IconData icon,
    required String title,
    required String text,
    required String actionText,
    required Future<void> Function() onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 52,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentSoft,
                  foregroundColor: AppColors.black,
                ),
                onPressed: onTap,
                child: Text(
                  actionText,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* HELPERS */
/* -------------------------------------------------------------------------- */

String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
      String fallback = '',
    }) {
  for (final key in keys) {
    final value = data[key];

    if (value == null) continue;

    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    if (value is num || value is bool) {
      return value.toString();
    }
  }

  return fallback;
}

double? _readDouble(
    Map<String, dynamic> data,
    List<String> keys,
    ) {
  for (final key in keys) {
    final value = data[key];

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '.'));
      if (parsed != null) return parsed;
    }
  }

  return null;
}

bool _readBool(
    Map<String, dynamic> data,
    List<String> keys, {
      bool fallback = false,
    }) {
  for (final key in keys) {
    final value = data[key];

    if (value is bool) return value;

    if (value is String) {
      final normalized = value.trim().toLowerCase();

      if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
        return true;
      }

      if (normalized == 'false' || normalized == 'no' || normalized == '0') {
        return false;
      }
    }

    if (value is num) return value != 0;
  }

  return fallback;
}

List<String> _readStringList(
    Map<String, dynamic> data,
    List<String> keys,
    ) {
  final result = <String>[];

  for (final key in keys) {
    final value = data[key];

    if (value is List) {
      result.addAll(
        value
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty),
      );
    }

    if (value is String && value.trim().isNotEmpty) {
      result.add(value.trim());
    }
  }

  return result.toSet().toList();
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}