import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';

class MerchantCustomPostDealDraft {
  MerchantCustomPostDealDraft({
    required this.id,
    required this.merchantId,
    required this.shopName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.buttonText,
    required this.isActive,
    required this.isArchived,
  });

  final String id;

  String merchantId;
  String shopName;

  String title;
  String subtitle;
  String description;
  String imageUrl;
  String buttonText;

  bool isActive;
  bool isArchived;

  factory MerchantCustomPostDealDraft.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return MerchantCustomPostDealDraft(
      id: data['id'] as String? ?? documentId,
      merchantId: data['merchantId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      title: data['title'] as String? ?? 'Neuer Beitrag',
      subtitle: data['subtitle'] as String? ?? 'Zusatz-Info',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      buttonText: data['buttonText'] as String? ?? 'Mehr erfahren',
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
      'type': 'custom_post_deal',
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'imageUrl': imageUrl,
      'buttonText': buttonText,
      'isActive': isActive,
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MerchantCustomPostDealDraft copyWithNewId() {
    return MerchantCustomPostDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: merchantId,
      shopName: shopName,
      title: '$title Kopie',
      subtitle: subtitle,
      description: description,
      imageUrl: imageUrl,
      buttonText: buttonText,
      isActive: false,
      isArchived: false,
    );
  }
}

class MerchantCustomPostDealsPage extends StatefulWidget {
  const MerchantCustomPostDealsPage({
    super.key,
    required this.merchantId,
    required this.shopName,
  });

  final String merchantId;
  final String shopName;

  @override
  State<MerchantCustomPostDealsPage> createState() =>
      _MerchantCustomPostDealsPageState();
}

class _MerchantCustomPostDealsPageState extends State<MerchantCustomPostDealsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<MerchantCustomPostDealDraft> deals = [];

  int selectedIndex = 0;

  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController buttonTextController = TextEditingController();

  MerchantCustomPostDealDraft get currentDeal => deals[selectedIndex];

  CollectionReference<Map<String, dynamic>> get _customPostDealsRef {
    return _firestore
        .collection('merchants')
        .doc(widget.merchantId)
        .collection('customPostDeals');
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
    imageUrlController.dispose();
    buttonTextController.dispose();
    super.dispose();
  }

  Future<void> _loadEverything() async {
    setState(() => isLoading = true);

    try {
      await _loadDeals();

      if (deals.isEmpty) {
        deals.add(_defaultDeal());
      }

      selectedIndex = 0;
      _syncControllersFromCurrent();

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (error) {
      debugPrint('Fehler beim Laden Custom Post Deals: $error');

      if (deals.isEmpty) {
        deals.add(_defaultDeal());
        selectedIndex = 0;
        _syncControllersFromCurrent();
      }

      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Beiträge konnten nicht geladen werden');
    }
  }

  Future<void> _loadDeals() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _customPostDealsRef.orderBy('updatedAt', descending: true).get();
    } catch (_) {
      snapshot = await _customPostDealsRef.get();
    }

    deals
      ..clear()
      ..addAll(
        snapshot.docs.map(
          (doc) => MerchantCustomPostDealDraft.fromFirestore(
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
    imageUrlController.text = currentDeal.imageUrl;
    buttonTextController.text = currentDeal.buttonText;
  }

  void _syncCurrentFromControllers() {
    currentDeal.title = titleController.text.trim();
    currentDeal.subtitle = subtitleController.text.trim();
    currentDeal.description = descriptionController.text.trim();
    currentDeal.imageUrl = imageUrlController.text.trim();
    currentDeal.buttonText = buttonTextController.text.trim();
  }

  Future<void> _saveCurrentDeal() async {
    _syncCurrentFromControllers();

    if (currentDeal.title.trim().isEmpty) {
      _showMessage('Bitte Titel eingeben');
      return;
    }

    if (currentDeal.imageUrl.trim().isEmpty) {
      _showMessage('Bitte Bild-URL eingeben');
      return;
    }

    setState(() => isSaving = true);

    try {
      final doc = _customPostDealsRef.doc(currentDeal.id);
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
      debugPrint('Fehler beim Speichern Custom Post Deal: $error');

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
      _showMessage('Mindestens ein Beitrag muss bleiben');
      return;
    }

    final dealToDelete = currentDeal;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Beitrag löschen?'),
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
      await _customPostDealsRef.doc(dealToDelete.id).delete();

      if (!mounted) return;

      setState(() {
        deals.removeWhere((deal) => deal.id == dealToDelete.id);
        selectedIndex = selectedIndex.clamp(0, deals.length - 1);
        _syncControllersFromCurrent();
      });

      _showMessage('Beitrag gelöscht');
    } catch (error) {
      debugPrint('Fehler beim Löschen: $error');
      _showMessage('Löschen fehlgeschlagen');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  MerchantCustomPostDealDraft _defaultDeal() {
    return MerchantCustomPostDealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantId: widget.merchantId,
      shopName: widget.shopName,
      title: 'Neuer Beitrag',
      subtitle: 'Zusatz-Info',
      description: '',
      imageUrl: '',
      buttonText: 'Mehr erfahren',
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
            _previewCard(),
            const SizedBox(height: 12),
            _sectionTitle('Bild & Medien'),
            const SizedBox(height: 10),
            _imageCard(),
            const SizedBox(height: 12),
            _mainInfoCard(),
            const SizedBox(height: 12),
            _buttonCard(),
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
                'Freier Beitrag',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Angebote oder News teilen',
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
                      'Neuer Post',
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
                    Icons.edit_note_rounded,
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

  Widget _previewCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: currentDeal.imageUrl.isNotEmpty
                  ? Image.network(
                      currentDeal.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentDeal.title.isEmpty ? 'Titel' : currentDeal.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentDeal.subtitle.isEmpty
                      ? 'Untertitel'
                      : currentDeal.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    currentDeal.buttonText.isEmpty
                        ? 'Mehr erfahren'
                        : currentDeal.buttonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
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

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.inputFill,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _imageCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: imageUrlController,
            onChanged: (value) => setState(() => currentDeal.imageUrl = value),
            decoration: const InputDecoration(
              labelText: 'Bild URL (Pflicht)',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.link_rounded),
            ),
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
            onChanged: (value) => setState(() => currentDeal.title = value),
            decoration: const InputDecoration(
              labelText: 'Titel',
              hintText: 'z. B. Neue Bowl ab heute',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: subtitleController,
            onChanged: (value) => setState(() => currentDeal.subtitle = value),
            decoration: const InputDecoration(
              labelText: 'Untertitel',
              hintText: 'z. B. In allen Filialen',
              prefixIcon: Icon(Icons.short_text_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Button Beschriftung',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: buttonTextController,
            onChanged: (value) => setState(() => currentDeal.buttonText = value),
            decoration: const InputDecoration(
              labelText: 'Button Text',
              hintText: 'z. B. Einlösen, Mehr erfahren...',
              prefixIcon: Icon(Icons.touch_app_rounded),
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
              hintText: 'Details zum Beitrag...',
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
              'Beitrag aktiv',
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
          isSaving ? 'Speichert...' : 'Aktuellen Post speichern',
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
