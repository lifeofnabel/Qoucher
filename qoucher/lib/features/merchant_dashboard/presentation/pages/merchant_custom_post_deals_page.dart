import 'dart:async';

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
    required this.linkUrl,
    required this.templateType,
    required this.postWeekKey,
    required this.isActive,
    required this.isArchived,
  });

  factory MerchantCustomPostDealDraft.fromFirestore(String documentId, Map<String, dynamic> data) {
    return MerchantCustomPostDealDraft(
      id: data['id']?.toString() ?? documentId,
      merchantId: data['merchantId']?.toString() ?? '',
      shopName: data['merchantName']?.toString() ?? data['shopName']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Neuer Beitrag',
      subtitle: data['subtitle']?.toString() ?? 'Zusatz-Info',
      description: data['description']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      buttonText: data['buttonText']?.toString() ?? 'Mehr erfahren',
      linkUrl: data['linkUrl']?.toString() ?? '',
      templateType: data['templateType']?.toString() ?? 'news',
      postWeekKey: data['postWeekKey']?.toString() ?? '',
      isActive: data['isActive'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
    );
  }

  final String id;
  String merchantId;
  String shopName;
  String title;
  String subtitle;
  String description;
  String imageUrl;
  String buttonText;
  String linkUrl;
  String templateType;
  String postWeekKey;
  bool isActive;
  bool isArchived;

  bool get canGoLive => title.trim().isNotEmpty && imageUrl.trim().isNotEmpty;

  String get templateLabel {
    switch (templateType) {
      case 'new_item':
        return 'Neue Ware';
      case 'event':
        return 'Event';
      case 'notice':
        return 'Hinweis';
      case 'job':
        return 'Job/Team gesucht';
      case 'news':
      default:
        return 'News';
    }
  }

  Map<String, dynamic> toFeedMap({
    required String merchantId,
    required String merchantName,
    required String area,
    required List<String> shopTypes,
  }) {
    return {
      'id': id,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'shopName': merchantName,
      'area': area,
      'shopTypes': shopTypes,
      'type': 'custom_post',
      'title': title.trim().isEmpty ? 'Neuer Beitrag' : title.trim(),
      'subtitle': subtitle.trim(),
      'description': description.trim(),
      'imageUrl': imageUrl.trim(),
      'buttonText': buttonText.trim().isEmpty ? 'Mehr erfahren' : buttonText.trim(),
      'linkUrl': linkUrl.trim(),
      'templateType': templateType,
      'templateLabel': templateLabel,
      'postWeekKey': postWeekKey,
      'isActive': isActive,
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
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
  State<MerchantCustomPostDealsPage> createState() => _MerchantCustomPostDealsPageState();
}

class _MerchantCustomPostDealsPageState extends State<MerchantCustomPostDealsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<MerchantCustomPostDealDraft> deals = [];

  int selectedIndex = 0;
  bool isLoading = true;
  bool isSaving = false;
  String area = '';
  List<String> shopTypes = [];
  Timer? _saveTimer;

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();
  final buttonTextController = TextEditingController();
  final linkUrlController = TextEditingController();

  MerchantCustomPostDealDraft get currentDeal => deals[selectedIndex];
  CollectionReference<Map<String, dynamic>> get _feedRef => _firestore.collection('feed');
  CollectionReference<Map<String, dynamic>> get _merchantsRef => _firestore.collection('merchants');

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    titleController.dispose();
    subtitleController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    buttonTextController.dispose();
    linkUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadEverything() async {
    setState(() => isLoading = true);
    try {
      await Future.wait([_loadMerchantMeta(), _loadDeals()]);
      if (deals.isEmpty) {
        final draft = _defaultDeal();
        deals.add(draft);
        await _saveDeal(draft, silent: true);
      }
      final currentWeekIndex = deals.indexWhere((deal) => deal.postWeekKey == _currentWeekKey());
      selectedIndex = currentWeekIndex >= 0 ? currentWeekIndex : 0;
      _syncControllersFromCurrent();
    } catch (error) {
      debugPrint('Fehler beim Laden Custom Posts: $error');
      if (deals.isEmpty) {
        deals.add(_defaultDeal());
        selectedIndex = 0;
        _syncControllersFromCurrent();
      }
      _showMessage('Beiträge konnten nicht geladen werden', error: true);
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadMerchantMeta() async {
    final merchantDoc = await _merchantsRef.doc(widget.merchantId).get();
    final data = merchantDoc.data() ?? {};
    area = data['area']?.toString() ?? '';
    shopTypes = (data['shopTypes'] as List?)?.map((item) => item.toString()).toList() ?? [];
  }

  Future<void> _loadDeals() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _feedRef
          .where('merchantId', isEqualTo: widget.merchantId)
          .where('type', isEqualTo: 'custom_post')
          .orderBy('updatedAt', descending: true)
          .get();
    } catch (_) {
      snapshot = await _feedRef
          .where('merchantId', isEqualTo: widget.merchantId)
          .where('type', isEqualTo: 'custom_post')
          .get();
    }
    deals
      ..clear()
      ..addAll(snapshot.docs.map((doc) => MerchantCustomPostDealDraft.fromFirestore(doc.id, doc.data())));
  }

  void _syncControllersFromCurrent() {
    titleController.text = currentDeal.title;
    subtitleController.text = currentDeal.subtitle;
    descriptionController.text = currentDeal.description;
    imageUrlController.text = currentDeal.imageUrl;
    buttonTextController.text = currentDeal.buttonText;
    linkUrlController.text = currentDeal.linkUrl;
  }

  void _syncCurrentFromControllers() {
    currentDeal.title = titleController.text.trim();
    currentDeal.subtitle = subtitleController.text.trim();
    currentDeal.description = descriptionController.text.trim();
    currentDeal.imageUrl = imageUrlController.text.trim();
    currentDeal.buttonText = buttonTextController.text.trim();
    currentDeal.linkUrl = linkUrlController.text.trim();
  }

  void _scheduleSave() {
    _syncCurrentFromControllers();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 650), () => _saveCurrent(silent: true));
  }

  Future<void> _saveCurrent({bool silent = false}) async {
    _syncCurrentFromControllers();
    await _saveDeal(currentDeal, silent: silent);
  }

  Future<void> _saveDeal(MerchantCustomPostDealDraft deal, {bool silent = false}) async {
    if (!mounted) return;
    setState(() => isSaving = true);
    try {
      if (deal.isActive && !deal.canGoLive) {
        deal.isActive = false;
        _showMessage('Live geht erst, wenn Titel und Bild-URL gesetzt sind', error: true);
      }
      final doc = _feedRef.doc(deal.id);
      final existingDoc = await doc.get();
      final data = deal.toFeedMap(
        merchantId: widget.merchantId,
        merchantName: widget.shopName,
        area: area,
        shopTypes: shopTypes,
      );
      if (!existingDoc.exists) data['createdAt'] = FieldValue.serverTimestamp();
      await doc.set(data, SetOptions(merge: true));
      if (!silent) _showMessage('${deal.title.isEmpty ? 'Beitrag' : deal.title} gespeichert');
    } catch (error) {
      debugPrint('Fehler beim Speichern Custom Post: $error');
      _showMessage('Speichern fehlgeschlagen', error: true);
    }
    if (mounted) setState(() => isSaving = false);
  }

  Future<void> _createNewDeal() async {
    if (deals.any((deal) => deal.postWeekKey == _currentWeekKey())) {
      _showMessage('Diese Kalenderwoche hat schon einen freien Beitrag. Nächster Post nächste Woche.', error: true);
      return;
    }
    await _saveCurrent(silent: true);
    final draft = _defaultDeal();
    setState(() {
      deals.insert(0, draft);
      selectedIndex = 0;
      _syncControllersFromCurrent();
    });
    await _saveDeal(draft, silent: false);
  }

  void _openDeleteSheet() {
    bool secondStep = false;
    _darkSheet(
      title: 'Beitrag löschen',
      subtitle: 'Dieser freie Feed-Post wird endgültig entfernt.',
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
                  secondStep ? 'Letzte Warnung. Dieser Beitrag verschwindet aus dem Feed.' : 'Willst du „${currentDeal.title}“ wirklich löschen?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 13, height: 1.3, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 14),
              if (!secondStep)
                _lightButton(text: 'Ja, weiter', onTap: () => setSheetState(() => secondStep = true))
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
      _showMessage('Mindestens ein Beitrag muss bleiben', error: true);
      return;
    }
    final dealToDelete = currentDeal;
    try {
      await _feedRef.doc(dealToDelete.id).delete();
      if (!mounted) return;
      setState(() {
        deals.removeWhere((deal) => deal.id == dealToDelete.id);
        selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : 0;
        _syncControllersFromCurrent();
      });
      _showMessage('Beitrag gelöscht');
    } catch (error) {
      debugPrint('Fehler beim Löschen: $error');
      _showMessage('Löschen fehlgeschlagen', error: true);
    }
  }

  void _applyTemplate(String type) {
    setState(() {
      currentDeal.templateType = type;
      switch (type) {
        case 'new_item':
          currentDeal.title = 'Neu bei uns';
          currentDeal.subtitle = 'Frisch im Sortiment';
          currentDeal.buttonText = 'Entdecken';
          break;
        case 'event':
          currentDeal.title = 'Event im Laden';
          currentDeal.subtitle = 'Komm vorbei';
          currentDeal.buttonText = 'Mehr erfahren';
          break;
        case 'notice':
          currentDeal.title = 'Wichtiger Hinweis';
          currentDeal.subtitle = 'Kurz informiert';
          currentDeal.buttonText = 'Okay';
          break;
        case 'job':
          currentDeal.title = 'Wir suchen Team';
          currentDeal.subtitle = 'Job/Minijob möglich';
          currentDeal.buttonText = 'Kontakt aufnehmen';
          break;
        case 'news':
        default:
          currentDeal.title = 'News aus dem Laden';
          currentDeal.subtitle = 'Aktuelles Update';
          currentDeal.buttonText = 'Mehr erfahren';
          break;
      }
      _syncControllersFromCurrent();
    });
    _saveCurrent(silent: true);
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
      linkUrl: '',
      templateType: 'news',
      postWeekKey: _currentWeekKey(),
      isActive: false,
      isArchived: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.black)),
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
              _weekLimitStrip(),
              const SizedBox(height: 16),
              _postsSwitcher(),
              const SizedBox(height: 16),
              _posterPreview(),
              const SizedBox(height: 16),
              _quickStatus(),
              const SizedBox(height: 22),
              _sectionTitle('Vorlage', 'Wähle die Richtung. Der Text wird vorbereitet.'),
              const SizedBox(height: 12),
              _templatePanel(),
              const SizedBox(height: 22),
              _sectionTitle('Plakat-Inhalt', 'Titel, Untertitel, Bild und Beschreibung.'),
              const SizedBox(height: 12),
              _contentPanel(),
              const SizedBox(height: 22),
              _sectionTitle('Button & Link', 'Optionaler Link für später. Muss nicht gesetzt sein.'),
              const SizedBox(height: 12),
              _linkPanel(),
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
        boxShadow: const [BoxShadow(color: AppColors.shadowStrong, blurRadius: 26, offset: Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _heroButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
              const Spacer(),
              if (isSaving)
                const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.2))
              else
                _heroPill(currentDeal.isActive ? 'Live' : 'Entwurf'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Poster Builder',
            style: TextStyle(color: AppColors.textOnDark, fontSize: 38, height: 0.95, fontWeight: FontWeight.w900, letterSpacing: -1.7),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ein freier Post pro Kalenderwoche. Für News, Ware, Events oder Team-Suche.',
            style: TextStyle(color: AppColors.textDisabled, fontSize: 14, height: 1.3, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _darkChip('type: custom_post'),
              _darkChip('KW ${_weekNumber(DateTime.now())}'),
              _darkChip(currentDeal.templateLabel),
              _darkChip(currentDeal.isArchived ? 'Archiviert' : 'Feed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weekLimitStrip() {
    return GestureDetector(
      onTap: _createNewDeal,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Kalenderwoche ${_weekNumber(DateTime.now())}: maximal ein freier Beitrag.', style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w900, height: 1.25)),
            ),
            const Icon(Icons.add_circle_outline_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _postsSwitcher() {
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
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(26), border: Border.all(color: AppColors.border)),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_circle_outline_rounded), SizedBox(height: 8), Text('Neue Woche', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900))]),
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
              decoration: BoxDecoration(color: selected ? AppColors.black : AppColors.surface, borderRadius: BorderRadius.circular(26), border: Border.all(color: selected ? AppColors.black : AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(_templateIcon(deal.templateType), color: selected ? AppColors.white : AppColors.black),
                const Spacer(),
                Text(deal.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? AppColors.white : AppColors.black, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('${deal.templateLabel} · ${deal.isActive ? 'Live' : 'Entwurf'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: selected ? AppColors.textDisabled : AppColors.textMuted, fontWeight: FontWeight.w800)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _posterPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(36), boxShadow: const [BoxShadow(color: AppColors.shadowStrong, blurRadius: 24, offset: Offset(0, 14))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: currentDeal.imageUrl.isNotEmpty
                ? Image.network(currentDeal.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _posterPlaceholder())
                : _posterPlaceholder(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _darkChip(currentDeal.templateLabel),
            const SizedBox(height: 16),
            Text(currentDeal.title.isEmpty ? 'Titel' : currentDeal.title, style: const TextStyle(color: AppColors.textOnDark, fontSize: 32, height: 0.95, fontWeight: FontWeight.w900, letterSpacing: -1.3)),
            const SizedBox(height: 8),
            Text(currentDeal.subtitle.isEmpty ? 'Untertitel' : currentDeal.subtitle, style: const TextStyle(color: AppColors.textDisabled, fontSize: 14, height: 1.3, fontWeight: FontWeight.w700)),
            if (currentDeal.description.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(currentDeal.description, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textDisabled, fontSize: 13, height: 1.35, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999)),
              child: Text(currentDeal.buttonText.trim().isEmpty ? 'Mehr erfahren' : currentDeal.buttonText, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _posterPlaceholder() {
    return Container(color: AppColors.surfaceDark, child: const Center(child: Icon(Icons.image_outlined, size: 54, color: AppColors.textDisabled)));
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
                _showMessage('Erst Titel und Bild-URL setzen', error: true);
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

  Widget _templatePanel() {
    final templates = [
      ('news', 'News', Icons.newspaper_rounded),
      ('new_item', 'Neue Ware', Icons.shopping_bag_rounded),
      ('event', 'Event', Icons.event_rounded),
      ('notice', 'Hinweis', Icons.info_rounded),
      ('job', 'Job/Team gesucht', Icons.group_add_rounded),
    ];
    return _basePanel(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: templates.map((template) {
            final selected = currentDeal.templateType == template.$1;
            return GestureDetector(
              onTap: () => _applyTemplate(template.$1),
              child: Container(
                width: 150,
                height: 98,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: selected ? AppColors.black : AppColors.inputFill, borderRadius: BorderRadius.circular(24), border: Border.all(color: selected ? AppColors.black : AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(template.$3, color: selected ? AppColors.white : AppColors.black),
                  const Spacer(),
                  Text(template.$2, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? AppColors.white : AppColors.black, fontWeight: FontWeight.w900)),
                ]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _contentPanel() {
    return _basePanel(children: [
      _input(controller: titleController, hint: 'Titel, z. B. Neue Bowl ab heute', icon: Icons.title_rounded, onChanged: (_) => _scheduleSave()),
      const SizedBox(height: 10),
      _input(controller: subtitleController, hint: 'Untertitel, z. B. Nur diese Woche', icon: Icons.short_text_rounded, onChanged: (_) => _scheduleSave()),
      const SizedBox(height: 10),
      _input(controller: imageUrlController, hint: 'Bild URL Pflicht: https://...', icon: Icons.link_rounded, onChanged: (_) => _scheduleSave()),
      const SizedBox(height: 10),
      _input(controller: descriptionController, hint: 'Beschreibung optional', icon: Icons.notes_rounded, maxLines: 4, onChanged: (_) => _scheduleSave()),
    ]);
  }

  Widget _linkPanel() {
    return _basePanel(children: [
      _input(controller: buttonTextController, hint: 'Button Text, z. B. Mehr erfahren', icon: Icons.touch_app_rounded, onChanged: (_) => _scheduleSave()),
      const SizedBox(height: 10),
      _input(controller: linkUrlController, hint: 'Optionaler Link: Instagram, Website, WhatsApp...', icon: Icons.link_rounded, onChanged: (_) => _scheduleSave()),
    ]);
  }

  Widget _managePanel() {
    return _basePanel(children: [
      _manageRow(icon: Icons.add_circle_outline_rounded, title: 'Neuen Wochen-Post erstellen', subtitle: 'Nur möglich, wenn diese Kalenderwoche noch keinen freien Post hat.', onTap: _createNewDeal),
      const Divider(height: 18, color: AppColors.divider),
      _manageRow(icon: Icons.delete_forever_rounded, title: 'Beitrag löschen', subtitle: 'Zwei Fragen, dann weg.', onTap: _openDeleteSheet),
    ]);
  }

  Widget _quickPill({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.black, size: 21), const Spacer(), Text(title, style: const TextStyle(color: AppColors.black, fontSize: 12, fontWeight: FontWeight.w900))]),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: AppColors.black, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.3, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _basePanel({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.border), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 9))]),
      child: Column(children: children),
    );
  }

  Widget _input({required TextEditingController controller, required String hint, required IconData icon, TextInputType keyboardType = TextInputType.text, int maxLines = 1, ValueChanged<String>? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textDisabled),
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _manageRow({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Icon(icon, color: AppColors.black),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ]),
      ),
    );
  }

  Widget _darkChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.white.withOpacity(0.14))),
      child: Text(text, style: const TextStyle(color: AppColors.textOnDark, fontSize: 12, fontWeight: FontWeight.w900)),
    );
  }

  Widget _heroButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(17)), child: Icon(icon, color: AppColors.black)),
    );
  }

  Widget _heroPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: AppColors.black, fontSize: 12, fontWeight: FontWeight.w900)),
    );
  }

  void _darkSheet({required String title, required String subtitle, required Widget child}) {
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
            decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(36)),
            child: SafeArea(
              top: false,
              child: ListView(shrinkWrap: true, children: [
                Text(title, style: const TextStyle(color: AppColors.textOnDark, fontSize: 26, height: 1, fontWeight: FontWeight.w900, letterSpacing: -0.9)),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: AppColors.textDisabled, fontSize: 13, height: 1.3, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),
                child,
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _lightButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999)), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w900))),
    );
  }

  Widget _dangerButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(999)), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w900))),
    );
  }

  IconData _templateIcon(String type) {
    switch (type) {
      case 'new_item':
        return Icons.shopping_bag_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'notice':
        return Icons.info_rounded;
      case 'job':
        return Icons.group_add_rounded;
      case 'news':
      default:
        return Icons.newspaper_rounded;
    }
  }

  String _currentWeekKey() {
    final now = DateTime.now();
    final week = _weekNumber(now).toString().padLeft(2, '0');
    return '${now.year}-KW$week';
  }

  int _weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - DateTime.monday;
    final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
    final diff = date.difference(firstMonday).inDays;
    return (diff / 7).floor() + 1;
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? AppColors.error : AppColors.black));
  }
}
