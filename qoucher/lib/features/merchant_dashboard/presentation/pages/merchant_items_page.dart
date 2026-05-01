import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/pages/merchant_item_editor_page.dart';

class MerchantItemCategory {
  const MerchantItemCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final int sortOrder;

  factory MerchantItemCategory.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    return MerchantItemCategory(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? 'Kategorie',
      sortOrder: data['sortOrder'] as int? ?? 999,
    );
  }
}

class MerchantItemPreview {
  const MerchantItemPreview({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isActive,
    required this.isAvailable,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isActive;
  final bool isAvailable;

  factory MerchantItemPreview.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    return MerchantItemPreview(
      id: data['id'] as String? ?? doc.id,
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      name: data['name'] as String? ??
          data['title'] as String? ??
          'Unbenannter Artikel',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ??
          (data['originalPrice'] as num?)?.toDouble() ??
          0,
      imageUrl: data['imageUrl'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }
}

class MerchantItemsPage extends StatefulWidget {
  const MerchantItemsPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantItemsPage> createState() => _MerchantItemsPageState();
}

class _MerchantItemsPageState extends State<MerchantItemsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedCategoryId = 'all';
  String selectedCategoryName = 'Alle';

  CollectionReference<Map<String, dynamic>> get _categoriesRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('itemCategories');
  }

  CollectionReference<Map<String, dynamic>> get _itemsRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('items');
  }

  Query<Map<String, dynamic>> get _itemsQuery {
    if (selectedCategoryId == 'all') {
      return _itemsRef;
    }

    return _itemsRef.where(
      'categoryId',
      isEqualTo: selectedCategoryId,
    );
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();

    await showModalBottomSheet(
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Neue Kategorie',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'z. B. Wraps, Bowls, Getränke',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentSoft,
                    foregroundColor: AppColors.black,
                  ),
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;

                    await _createCategory(name);

                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Kategorie speichern',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }

  Future<void> _createCategory(String name) async {
    final id = _slugify(name);
    final doc = _categoriesRef.doc(id);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      if (!mounted) return;

      setState(() {
        selectedCategoryId = id;
        selectedCategoryName = name;
      });

      _showMessage('Kategorie existiert bereits');
      return;
    }

    await doc.set({
      'id': id,
      'merchantId': widget.merchantId,
      'name': name,
      'normalizedName': name.toLowerCase(),
      'sortOrder': DateTime.now().millisecondsSinceEpoch,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    setState(() {
      selectedCategoryId = id;
      selectedCategoryName = name;
    });

    _showMessage('Kategorie gespeichert');
  }

  Future<void> _openCreateItemPage() async {
    if (selectedCategoryId == 'all') {
      _showMessage('Bitte zuerst eine Kategorie wählen');
      return;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MerchantItemEditorPage(
          merchantId: widget.merchantId,
          categoryId: selectedCategoryId,
          categoryName: selectedCategoryName,
        ),
      ),
    );
  }

  Future<void> _openEditItemPage(MerchantItemPreview item) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MerchantItemEditorPage(
          merchantId: widget.merchantId,
          categoryId: item.categoryId,
          categoryName: item.categoryName,
          itemId: item.id,
        ),
      ),
    );
  }

  String _slugify(String value) {
    final cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    if (cleaned.isEmpty) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }

    return cleaned;
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentSoft,
        foregroundColor: AppColors.black,
        elevation: 4,
        onPressed: _openCreateItemPage,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Artikel',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _categoriesRef.orderBy('sortOrder').snapshots(),
          builder: (context, categorySnapshot) {
            if (categorySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categorySnapshot.hasError) {
              return _infoBox(
                icon: Icons.error_outline_rounded,
                title: 'Kategorien konnten nicht geladen werden',
                text: categorySnapshot.error.toString(),
              );
            }

            final categories = categorySnapshot.data?.docs
                .map(MerchantItemCategory.fromDoc)
                .toList() ??
                [];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _topBar(),
                const SizedBox(height: 18),
                _categoryHeader(),
                const SizedBox(height: 10),
                _categorySelector(categories),
                const SizedBox(height: 22),
                _itemsHeader(),
                const SizedBox(height: 12),
                _itemsList(),
              ],
            );
          },
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
                'Meine Artikel',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kategorien wählen, Artikel pflegen',
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

  Widget _categoryHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Kategorien',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        InkWell(
          onTap: _addCategory,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _categorySelector(List<MerchantItemCategory> categories) {
    final allCategories = [
      const MerchantItemCategory(
        id: 'all',
        name: 'Alle',
        sortOrder: -1,
      ),
      ...categories,
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final selected = selectedCategoryId == category.id;

          return InkWell(
            onTap: () {
              setState(() {
                selectedCategoryId = category.id;
                selectedCategoryName = category.name;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.accentSoft : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.border,
                  width: selected ? 1.4 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category.name,
                style: TextStyle(
                  color: selected ? AppColors.black : AppColors.textMuted,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _itemsHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            selectedCategoryId == 'all'
                ? 'Alle Artikel'
                : 'Artikel in $selectedCategoryName',
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (selectedCategoryId != 'all')
          TextButton.icon(
            onPressed: _openCreateItemPage,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.black,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Neu',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
      ],
    );
  }

  Widget _itemsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _itemsQuery.snapshots(),
      builder: (context, itemSnapshot) {
        if (itemSnapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (itemSnapshot.hasError) {
          return _infoBox(
            icon: Icons.error_outline_rounded,
            title: 'Artikel konnten nicht geladen werden',
            text: itemSnapshot.error.toString(),
          );
        }

        final items = itemSnapshot.data?.docs
            .map(MerchantItemPreview.fromDoc)
            .toList() ??
            [];

        items.sort((a, b) => a.name.compareTo(b.name));

        if (items.isEmpty) {
          return _infoBox(
            icon: Icons.inventory_2_outlined,
            title: selectedCategoryId == 'all'
                ? 'Noch keine Artikel'
                : 'Keine Artikel in $selectedCategoryName',
            text: selectedCategoryId == 'all'
                ? 'Erstelle zuerst eine Kategorie und füge dann Artikel hinzu.'
                : 'Füge deinen ersten Artikel in dieser Kategorie hinzu.',
          );
        }

        return Column(
          children: items.map(_itemCard).toList(),
        );
      },
    );
  }

  Widget _itemCard(MerchantItemPreview item) {
    return InkWell(
      onTap: () => _openEditItemPage(item),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            _itemImageBox(item.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.categoryName.isEmpty
                        ? 'Ohne Kategorie'
                        : item.categoryName,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Text(
                    '${_formatPrice(item.price)} €',
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              item.isActive && item.isAvailable
                  ? Icons.check_circle_rounded
                  : Icons.pause_circle_rounded,
              color: item.isActive && item.isAvailable
                  ? AppColors.black
                  : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemImageBox(String imageUrl) {
    if (imageUrl.trim().isNotEmpty && imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          imageUrl,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackImageBox(),
        ),
      );
    }

    return _fallbackImageBox();
  }

  Widget _fallbackImageBox() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(
        Icons.fastfood_rounded,
        color: AppColors.black,
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}