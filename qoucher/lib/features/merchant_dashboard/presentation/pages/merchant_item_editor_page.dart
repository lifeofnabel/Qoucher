import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class MerchantItemEditorPage extends StatefulWidget {
  const MerchantItemEditorPage({
    super.key,
    required this.merchantId,
    required this.categoryId,
    required this.categoryName,
    this.itemId,
  });

  final String merchantId;
  final String categoryId;
  final String categoryName;
  final String? itemId;

  bool get isEditing => itemId != null && itemId!.trim().isNotEmpty;

  @override
  State<MerchantItemEditorPage> createState() => _MerchantItemEditorPageState();
}

class _MerchantItemEditorPageState extends State<MerchantItemEditorPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController articleNumberController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;
  bool isActive = true;
  bool isAvailable = true;

  String? createdItemId;

  String get _itemId {
    if (widget.itemId != null && widget.itemId!.trim().isNotEmpty) {
      return widget.itemId!;
    }

    createdItemId ??= DateTime.now().millisecondsSinceEpoch.toString();
    return createdItemId!;
  }

  DocumentReference<Map<String, dynamic>> get _itemRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('items')
        .doc(_itemId);
  }

  DocumentReference<Map<String, dynamic>> get _categoryRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('itemCategories')
        .doc(widget.categoryId);
  }

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      _loadItem();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    articleNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await _itemRef.get();

      if (!snapshot.exists) {
        if (!mounted) return;

        setState(() => isLoading = false);
        _showMessage('Artikel nicht gefunden');
        return;
      }

      final data = snapshot.data() ?? {};

      nameController.text =
          data['name'] as String? ?? data['title'] as String? ?? '';

      descriptionController.text = data['description'] as String? ?? '';

      final price = (data['price'] as num?)?.toDouble() ??
          (data['originalPrice'] as num?)?.toDouble();

      priceController.text = price == null ? '' : _formatPriceInput(price);

      imageUrlController.text = data['imageUrl'] as String? ?? '';

      articleNumberController.text = data['articleNumber'] as String? ?? '';

      isActive = data['isActive'] as bool? ?? true;
      isAvailable = data['isAvailable'] as bool? ?? true;

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (error) {
      debugPrint('Fehler beim Laden vom Artikel: $error');

      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Artikel konnte nicht geladen werden');
    }
  }

  Future<void> _saveItem() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final imageUrl = imageUrlController.text.trim();
    final articleNumber = articleNumberController.text.trim();

    final price = double.tryParse(
      priceController.text.trim().replaceAll(',', '.'),
    );

    if (name.isEmpty) {
      _showMessage('Bitte Artikelnamen eingeben');
      return;
    }

    if (price == null || price < 0) {
      _showMessage('Bitte gültigen Preis eingeben');
      return;
    }

    setState(() => isSaving = true);

    try {
      final now = FieldValue.serverTimestamp();
      final existingDoc = await _itemRef.get();

      final data = <String, dynamic>{
        'id': _itemId,
        'merchantId': widget.merchantId,

        'categoryId': widget.categoryId,
        'categoryName': widget.categoryName,

        'name': name,
        'title': name,
        'description': description,

        'price': price,
        'originalPrice': price,

        'imageUrl': imageUrl,
        'articleNumber': articleNumber,

        'isActive': isActive,
        'isAvailable': isAvailable,

        'type': 'merchant_item',
        'searchName': name.toLowerCase(),

        'updatedAt': now,
      };

      if (!existingDoc.exists) {
        data['createdAt'] = now;
      }

      await _itemRef.set(data, SetOptions(merge: true));

      await _categoryRef.set(
        {
          'id': widget.categoryId,
          'merchantId': widget.merchantId,
          'name': widget.categoryName,
          'normalizedName': widget.categoryName.toLowerCase(),
          'updatedAt': now,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() => isSaving = false);

      _showMessage(
        widget.isEditing ? 'Artikel aktualisiert' : 'Artikel gespeichert',
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('Fehler beim Speichern vom Artikel: $error');

      if (!mounted) return;

      setState(() => isSaving = false);
      _showMessage('Speichern fehlgeschlagen');
    }
  }

  Future<void> _deleteItem() async {
    if (!widget.isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Artikel löschen?'),
          content: const Text(
            'Dieser Artikel wird dauerhaft gelöscht.',
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
      await _itemRef.delete();

      if (!mounted) return;

      _showMessage('Artikel gelöscht');
      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('Fehler beim Löschen vom Artikel: $error');
      _showMessage('Löschen fehlgeschlagen');
    }
  }

  String _formatPriceInput(double price) {
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
            const SizedBox(height: 18),
            _previewCard(),
            const SizedBox(height: 14),
            _mainInfoCard(),
            const SizedBox(height: 12),
            _priceCard(),
            const SizedBox(height: 12),
            _imageCard(),
            const SizedBox(height: 12),
            _statusCard(),
            const SizedBox(height: 20),
            _saveButton(),
            if (widget.isEditing) ...[
              const SizedBox(height: 10),
              _deleteButton(),
            ],
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Artikel bearbeiten' : 'Neuer Artikel',
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.categoryName,
                style: const TextStyle(
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

  Widget _previewCard() {
    final name = nameController.text.trim().isEmpty
        ? 'Artikelname'
        : nameController.text.trim();

    final price = priceController.text.trim().isEmpty
        ? '0,00'
        : priceController.text.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.accent,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          _imagePreviewBox(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$price €',
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePreviewBox() {
    final imageUrl = imageUrlController.text.trim();

    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackImageBox(),
        ),
      );
    }

    return _fallbackImageBox();
  }

  Widget _fallbackImageBox() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(
        Icons.fastfood_rounded,
        color: AppColors.black,
        size: 32,
      ),
    );
  }

  Widget _mainInfoCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Artikel-Infos',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'z. B. Chicken Wrap',
              prefixIcon: Icon(Icons.restaurant_menu_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: articleNumberController,
            decoration: const InputDecoration(
              labelText: 'Artikelnummer optional',
              hintText: 'z. B. 01',
              prefixIcon: Icon(Icons.tag_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Beschreibung',
              hintText: 'Kurze Beschreibung für Kunden',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_rounded),
            ),
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
          TextField(
            controller: priceController,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Preis',
              hintText: 'z. B. 7,50',
              prefixIcon: Icon(Icons.euro_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bild',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: imageUrlController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Bild-URL',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.image_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return _baseCard(
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: isActive,
            onChanged: (value) => setState(() => isActive = value),
            title: const Text(
              'Aktiv',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text('Artikel wird grundsätzlich angezeigt'),
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: isAvailable,
            onChanged: (value) => setState(() => isAvailable = value),
            title: const Text(
              'Verfügbar',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text('Artikel ist aktuell bestellbar / kaufbar'),
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
        onPressed: isSaving ? null : _saveItem,
        icon: isSaving
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          isSaving ? 'Speichert...' : 'Artikel speichern',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isSaving ? null : _deleteItem,
        icon: const Icon(Icons.delete_outline_rounded),
        label: const Text(
          'Artikel löschen',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
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