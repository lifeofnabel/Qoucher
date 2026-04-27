import 'package:flutter/material.dart';

import 'stamp_design_sheet.dart';
import 'stamp_preview_sheet.dart';
import 'stamp_reward_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StampCardDraft {
  factory StampCardDraft.fromFirestore(
      String documentId,
      Map<String, dynamic> data,
      ) {
    final design = Map<String, dynamic>.from(data['design'] ?? {});

    return StampCardDraft(
      id: data['id'] ?? documentId,
      title: data['title'] ?? 'Stempelkarte',
      description: data['description'] ??
          'Sammle Stempel und sichere dir deine Belohnung.',
      isEnabled: data['isEnabled'] ?? false,
      isPublic: data['isPublic'] ?? true,
      stampCount: data['stampCount'] ?? 10,
      previewCollectedStamps: 0,
      triggerType: data['triggerType'] ?? 'per_visit',
      triggerLabel: data['triggerLabel'] ?? 'Pro Besuch',
      rewardTitle: data['rewardTitle'] ?? 'Belohnung',
      rewardDescription: data['rewardDescription'] ??
          'Nach voller Karte erhält der Kunde eine Belohnung.',
      autoRewardEnabled: data['autoRewardEnabled'] ?? true,
      themeName: design['theme'] ?? 'Tiffany',
      lookMode: design['lookMode'] ?? 'Soft',
      stampShape: design['shape'] ?? 'Kreis',
      iconCodePoint:
      design['iconCodePoint'] ?? Icons.restaurant_menu_outlined.codePoint,
      iconFontFamily: design['iconFontFamily'] ??
          Icons.restaurant_menu_outlined.fontFamily,
      fontStyle: design['fontStyle'] ?? 'Modern',
    );
  }
  StampCardDraft({
    required this.id,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.isPublic,
    required this.stampCount,
    required this.previewCollectedStamps,
    required this.triggerType,
    required this.triggerLabel,
    required this.rewardTitle,
    required this.rewardDescription,
    required this.autoRewardEnabled,
    required this.themeName,
    required this.lookMode,
    required this.stampShape,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.fontStyle,
  });

  final String id;

  String title;
  String description;

  bool isEnabled;
  bool isPublic;

  int stampCount;
  int previewCollectedStamps;

  String triggerType;
  String triggerLabel;

  String rewardTitle;
  String rewardDescription;
  bool autoRewardEnabled;

  String themeName;
  String lookMode;
  String stampShape;

  int iconCodePoint;
  String? iconFontFamily;

  String fontStyle;

  IconData get icon => IconData(
    iconCodePoint,
    fontFamily: iconFontFamily,
  );

  Map<String, dynamic> toFirestoreMap(String merchantId) {
    return {
      'id': id,
      'merchantId': merchantId,
      'title': title,
      'description': description,
      'isEnabled': isEnabled,
      'isPublic': isPublic,
      'stampCount': stampCount,
      'triggerType': triggerType,
      'triggerLabel': triggerLabel,
      'rewardTitle': rewardTitle,
      'rewardDescription': rewardDescription,
      'autoRewardEnabled': autoRewardEnabled,
      'design': {
        'theme': themeName,
        'lookMode': lookMode,
        'shape': stampShape,
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        'fontStyle': fontStyle,
      },
      'updatedAt': DateTime.now(),
    };
  }

  StampCardDraft copyWithNewId() {
    return StampCardDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$title Kopie',
      description: description,
      isEnabled: false,
      isPublic: isPublic,
      stampCount: stampCount,
      previewCollectedStamps: previewCollectedStamps,
      triggerType: triggerType,
      triggerLabel: triggerLabel,
      rewardTitle: rewardTitle,
      rewardDescription: rewardDescription,
      autoRewardEnabled: autoRewardEnabled,
      themeName: themeName,
      lookMode: lookMode,
      stampShape: stampShape,
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      fontStyle: fontStyle,
    );
  }
}

class MerchantStampSystemPage extends StatefulWidget {
  const MerchantStampSystemPage({
    super.key,
    required this.merchantId,
  });

  final String merchantId;

  @override
  State<MerchantStampSystemPage> createState() =>
      _MerchantStampSystemPageState();
}

class _MerchantStampSystemPageState extends State<MerchantStampSystemPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<StampCardDraft> stampCards = [];

  int selectedIndex = 0;
  bool isLoading = true;

  StampCardDraft get currentCard => stampCards[selectedIndex];

  final List<Map<String, String>> triggers = [
    {'label': 'Pro Besuch', 'type': 'per_visit'},
    {'label': 'Pro Einkauf', 'type': 'per_purchase'},
    {'label': 'Pro Artikel', 'type': 'per_item'},
    {'label': 'Ab Betrag', 'type': 'min_amount'},
  ];

  bool get isBoldLook => currentCard.lookMode == 'Bold';

  Color get primaryColor {
    switch (currentCard.themeName) {
      case 'Gold':
        return const Color(0xFFD6A23D);
      case 'Dark':
        return const Color(0xFF111827);
      case 'Rose':
        return const Color(0xFFE87EA1);
      case 'Fresh':
        return const Color(0xFF4CAF50);
      case 'Ocean':
        return const Color(0xFF2563EB);
      case 'Tiffany':
      default:
        return const Color(0xFF00BFA6);
    }
  }

  Color get softColor {
    switch (currentCard.themeName) {
      case 'Gold':
        return const Color(0xFFFFF3CF);
      case 'Dark':
        return const Color(0xFFE5E7EB);
      case 'Rose':
        return const Color(0xFFFFE4EC);
      case 'Fresh':
        return const Color(0xFFE5FFE9);
      case 'Ocean':
        return const Color(0xFFE0ECFF);
      case 'Tiffany':
      default:
        return const Color(0xFFE5FFFA);
    }
  }

  Color get cardTextColor {
    if (!isBoldLook) return const Color(0xFF101827);
    if (currentCard.themeName == 'Gold' || currentCard.themeName == 'Rose') {
      return const Color(0xFF101827);
    }
    return Colors.white;
  }

  Color get cardSubTextColor {
    if (!isBoldLook) return const Color(0xFF4B5563);
    if (currentCard.themeName == 'Gold' || currentCard.themeName == 'Rose') {
      return const Color(0xFF374151);
    }
    return Colors.white.withOpacity(0.86);
  }

  Color get cardBackground {
    return isBoldLook ? primaryColor : softColor;
  }

  Color get stampEmptyColor {
    return isBoldLook ? Colors.white.withOpacity(0.20) : Colors.white;
  }

  Color get stampFilledColor {
    if (isBoldLook) return Colors.white;
    return primaryColor;
  }

  Color get stampFilledIconColor {
    if (isBoldLook) return primaryColor;
    return Colors.white;
  }

  TextStyle smartTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    switch (currentCard.fontStyle) {
      case 'Elegant':
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w700,
          color: color,
          fontFamily: 'serif',
          letterSpacing: 0.3,
        );
      case 'Playful':
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w900,
          color: color,
          letterSpacing: 0.1,
        );
      case 'Modern':
      default:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w800,
          color: color,
          letterSpacing: -0.2,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStampCards();
  }

  Future<void> _loadStampCards() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('merchants')
          .doc(widget.merchantId)
          .collection('stampCards')
          .orderBy('updatedAt', descending: true)
          .get();

      stampCards.clear();

      for (final doc in snapshot.docs) {
        stampCards.add(
          StampCardDraft.fromFirestore(
            doc.id,
            doc.data(),
          ),
        );
      }

      if (stampCards.isEmpty) {
        stampCards.add(_defaultStampCard());
      }

      selectedIndex = 0;
    } catch (error) {
      debugPrint('Fehler beim Laden der Stempelkarten: $error');

      if (stampCards.isEmpty) {
        stampCards.add(_defaultStampCard());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stempelkarten konnten nicht geladen werden'),
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }



  Future<void> _saveSettings() async {
    try {
      await _firestore
          .collection('merchants')
          .doc(widget.merchantId)
          .collection('stampCards')
          .doc(currentCard.id)
          .set(
        currentCard.toFirestoreMap(widget.merchantId),
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${currentCard.title} gespeichert'),
        ),
      );
    } catch (error) {
      debugPrint('Fehler beim Speichern der Stempelkarte: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speichern fehlgeschlagen'),
        ),
      );
    }
  }

  void _createNewCard() {
    final newCard = StampCardDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Neue Stempelkarte',
      description: 'Sammle Stempel und erhalte eine Belohnung.',
      isEnabled: false,
      isPublic: true,
      stampCount: 8,
      previewCollectedStamps: 0,
      triggerType: 'per_visit',
      triggerLabel: 'Pro Besuch',
      rewardTitle: 'Belohnung',
      rewardDescription: 'Der Kunde erhält eine Belohnung nach voller Karte.',
      autoRewardEnabled: true,
      themeName: 'Tiffany',
      lookMode: 'Soft',
      stampShape: 'Kreis',
      iconCodePoint: Icons.stars_outlined.codePoint,
      iconFontFamily: Icons.stars_outlined.fontFamily,
      fontStyle: 'Modern',
    );

    setState(() {
      stampCards.add(newCard);
      selectedIndex = stampCards.length - 1;
    });
  }

  void _duplicateCurrentCard() {
    setState(() {
      stampCards.add(currentCard.copyWithNewId());
      selectedIndex = stampCards.length - 1;
    });
  }

  Future<void> _deleteCurrentCard() async {
    if (stampCards.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mindestens eine Stempelkarte muss bleiben'),
        ),
      );
      return;
    }

    final cardToDelete = currentCard;

    try {
      await _firestore
          .collection('merchants')
          .doc(widget.merchantId)
          .collection('stampCards')
          .doc(cardToDelete.id)
          .delete();

      setState(() {
        stampCards.removeAt(selectedIndex);
        selectedIndex = 0;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cardToDelete.title} gelöscht'),
        ),
      );
    } catch (error) {
      debugPrint('Fehler beim Löschen der Stempelkarte: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Löschen fehlgeschlagen'),
        ),
      );
    }
  }

  void _openDesignSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return StampDesignSheet(
          selectedTheme: currentCard.themeName,
          selectedLookMode: currentCard.lookMode,
          selectedShape: currentCard.stampShape,
          selectedIcon: currentCard.icon,
          selectedFontStyle: currentCard.fontStyle,
          onApply: ({
            required String theme,
            required String lookMode,
            required String shape,
            required IconData icon,
            required String fontStyle,
          }) {
            setState(() {
              currentCard.themeName = theme;
              currentCard.lookMode = lookMode;
              currentCard.stampShape = shape;
              currentCard.iconCodePoint = icon.codePoint;
              currentCard.iconFontFamily = icon.fontFamily;
              currentCard.fontStyle = fontStyle;
            });
          },
        );
      },
    );
  }

  void _openRewardSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return StampRewardSheet(
          rewardTitle: currentCard.rewardTitle,
          rewardDescription: currentCard.rewardDescription,
          autoRewardEnabled: currentCard.autoRewardEnabled,
          onApply: ({
            required String title,
            required String description,
            required bool autoReward,
          }) {
            setState(() {
              currentCard.rewardTitle = title;
              currentCard.rewardDescription = description;
              currentCard.autoRewardEnabled = autoReward;
            });
          },
        );
      },
    );
  }

  void _openPreviewSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return StampPreviewSheet(
          title: currentCard.title,
          description: currentCard.description,
          rewardTitle: currentCard.rewardTitle,
          stampCount: currentCard.stampCount,
          collectedStamps: currentCard.previewCollectedStamps,
          primaryColor: primaryColor,
          softColor: softColor,
          lookMode: currentCard.lookMode,
          stampShape: currentCard.stampShape,
          icon: currentCard.icon,
          fontStyle: currentCard.fontStyle,
        );
      },
    );
  }

  void _editCardTexts() {
    final titleController = TextEditingController(text: currentCard.title);
    final descriptionController =
    TextEditingController(text: currentCard.description);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            8,
            18,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Stempelkarte bearbeiten',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Beschreibung',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      currentCard.title = titleController.text.trim().isEmpty
                          ? 'Treuekarte'
                          : titleController.text.trim();

                      currentCard.description =
                      descriptionController.text.trim().isEmpty
                          ? 'Sammle Stempel und sichere dir deine Belohnung.'
                          : descriptionController.text.trim();
                    });

                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Übernehmen'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final progress = currentCard.previewCollectedStamps / currentCard.stampCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stempelkarten'),
        actions: [
          IconButton(
            onPressed: _openPreviewSheet,
            icon: const Icon(Icons.visibility_outlined),
          ),
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.check_circle_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardsSwitcher(),
          const SizedBox(height: 16),
          _previewCard(progress),
          const SizedBox(height: 18),
          _quickActionsCard(),
          const SizedBox(height: 18),
          _sectionTitle('Aufbau'),
          const SizedBox(height: 10),
          _setupCard(),
          const SizedBox(height: 18),
          _sectionTitle('Kundenerlebnis'),
          const SizedBox(height: 10),
          _customerViewCard(),
          const SizedBox(height: 18),
          _sectionTitle('Design'),
          const SizedBox(height: 10),
          _designCard(),
          const SizedBox(height: 18),
          _sectionTitle('Belohnung'),
          const SizedBox(height: 10),
          _rewardCard(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Aktuelle Karte speichern'),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _cardsSwitcher() {
    return SizedBox(
      height: 102,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stampCards.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == stampCards.length) {
            return InkWell(
              onTap: _createNewCard,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.25),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(height: 8),
                    Text(
                      'Neue Karte',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            );
          }

          final card = stampCards[index];
          final selected = index == selectedIndex;

          return InkWell(
            onTap: () => setState(() => selectedIndex = index),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 158,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: selected
                    ? primaryColor.withOpacity(0.13)
                    : Theme.of(context).cardColor,
                border: Border.all(
                  color: selected
                      ? primaryColor
                      : Theme.of(context).dividerColor.withOpacity(0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(card.icon, color: selected ? primaryColor : null),
                  const Spacer(),
                  Text(
                    card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.isEnabled ? 'Aktiv' : 'Pausiert',
                    style: TextStyle(
                      fontSize: 12,
                      color: card.isEnabled ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w700,
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

  Widget _previewCard(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: cardBackground,
        border: Border.all(color: primaryColor.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 12),
            color: primaryColor.withOpacity(isBoldLook ? 0.20 : 0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                isBoldLook ? Colors.white.withOpacity(0.18) : Colors.white,
                child: Icon(
                  currentCard.icon,
                  color: isBoldLook ? Colors.white : primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentCard.title,
                      style: smartTextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: cardTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentCard.themeName} · ${currentCard.lookMode} · ${currentCard.fontStyle}',
                      style: TextStyle(
                        color: cardSubTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: currentCard.isEnabled,
                onChanged: (value) {
                  setState(() => currentCard.isEnabled = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            currentCard.description,
            style: TextStyle(
              color: cardSubTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(99),
            color: isBoldLook ? Colors.white : primaryColor,
            backgroundColor:
            isBoldLook ? Colors.white.withOpacity(0.18) : Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            '${currentCard.previewCollectedStamps} von ${currentCard.stampCount} Stempeln gesammelt',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: cardTextColor,
            ),
          ),
          const SizedBox(height: 18),
          _responsiveStampGrid(
            stampCount: currentCard.stampCount,
            collected: currentCard.previewCollectedStamps,
            size: 48,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openPreviewSheet,
              icon: const Icon(Icons.remove_red_eye_outlined),
              label: const Text('Kunden-Vorschau öffnen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cardTextColor,
                side: BorderSide(color: cardTextColor.withOpacity(0.35)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard() {
    return _baseCard(
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: currentCard.isPublic,
            onChanged: (value) {
              setState(() => currentCard.isPublic = value);
            },
            title: const Text(
              'Öffentlich',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text('Kunde kann diese Karte sehen'),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _duplicateCurrentCard,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Duplizieren'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _deleteCurrentCard,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Karte löschen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _setupCard() {
    return _baseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wie viele Stempel braucht der Kunde?',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: currentCard.stampCount > 3
                    ? () {
                  setState(() {
                    currentCard.stampCount--;
                    if (currentCard.previewCollectedStamps >
                        currentCard.stampCount) {
                      currentCard.previewCollectedStamps =
                          currentCard.stampCount;
                    }
                  });
                }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${currentCard.stampCount} Stempel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: currentCard.stampCount < 20
                    ? () => setState(() => currentCard.stampCount++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Test-Vorschau',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          Slider(
            value: currentCard.previewCollectedStamps.toDouble(),
            min: 0,
            max: currentCard.stampCount.toDouble(),
            divisions: currentCard.stampCount,
            label: '${currentCard.previewCollectedStamps}',
            onChanged: (value) {
              setState(() {
                currentCard.previewCollectedStamps = value.round();
              });
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'Wofür bekommt der Kunde einen Stempel?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: triggers.map((trigger) {
              final label = trigger['label']!;
              final type = trigger['type']!;

              return ChoiceChip(
                label: Text(label),
                selected: currentCard.triggerType == type,
                onSelected: (_) {
                  setState(() {
                    currentCard.triggerType = type;
                    currentCard.triggerLabel = label;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _customerViewCard() {
    return _baseCard(
      child: Column(
        children: [
          _infoRow(
            icon: Icons.title_outlined,
            title: 'Titel',
            value: currentCard.title,
            onTap: _editCardTexts,
          ),
          const Divider(),
          _infoRow(
            icon: Icons.notes_outlined,
            title: 'Beschreibung',
            value: currentCard.description,
            onTap: _editCardTexts,
          ),
          const Divider(),
          _infoRow(
            icon: Icons.touch_app_outlined,
            title: 'Stempel-Regel',
            value: currentCard.triggerLabel,
          ),
        ],
      ),
    );
  }

  Widget _designCard() {
    return _baseCard(
      child: Column(
        children: [
          _infoRow(
            icon: Icons.palette_outlined,
            title: 'Look',
            value: '${currentCard.themeName} · ${currentCard.lookMode}',
            onTap: _openDesignSheet,
          ),
          const Divider(),
          _infoRow(
            icon: Icons.stars_outlined,
            title: 'Stempelform',
            value: currentCard.stampShape,
            onTap: _openDesignSheet,
          ),
          const Divider(),
          _infoRow(
            icon: Icons.text_fields_outlined,
            title: 'Schrift',
            value: currentCard.fontStyle,
            onTap: _openDesignSheet,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openDesignSheet,
              icon: const Icon(Icons.tune_outlined),
              label: const Text('Design anpassen'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardCard() {
    return _baseCard(
      child: Column(
        children: [
          _infoRow(
            icon: Icons.card_giftcard_outlined,
            title: 'Belohnung',
            value: currentCard.rewardTitle,
            onTap: _openRewardSheet,
          ),
          const Divider(),
          _infoRow(
            icon: Icons.auto_awesome_outlined,
            title: 'Automatisch auslösen',
            value: currentCard.autoRewardEnabled ? 'Ja' : 'Nein',
            onTap: _openRewardSheet,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openRewardSheet,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Belohnung bearbeiten'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsiveStampGrid({
    required int stampCount,
    required int collected,
    required double size,
  }) {
    if (stampCount <= 5) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stampCount, (index) {
          return _stampBubble(
            filled: index < collected,
            size: size,
          );
        }),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(stampCount, (index) {
        return _stampBubble(
          filled: index < collected,
          size: size,
        );
      }),
    );
  }

  Widget _stampBubble({
    required bool filled,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: currentCard.stampShape == 'Kreis'
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: currentCard.stampShape == 'Kreis'
            ? null
            : BorderRadius.circular(
          currentCard.stampShape == 'Quadrat' ? 12 : 18,
        ),
        color: filled ? stampFilledColor : stampEmptyColor,
        border: Border.all(
          color: isBoldLook
              ? Colors.white.withOpacity(0.42)
              : primaryColor.withOpacity(0.50),
          width: 1.6,
        ),
      ),
      child: Icon(
        _stampIcon(),
        size: size * 0.50,
        color: filled ? stampFilledIconColor : primaryColor,
      ),
    );
  }

  IconData _stampIcon() {
    switch (currentCard.stampShape) {
      case 'Herz':
        return Icons.favorite;
      case 'Stern':
        return Icons.star;
      case 'Quadrat':
        return Icons.check_box_outline_blank;
      case 'Kreis':
      default:
        return Icons.check;
    }
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(value),
      trailing: onTap == null
          ? null
          : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
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

  Widget _baseCard({required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

StampCardDraft _defaultStampCard() {
  return StampCardDraft(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: 'Neue Stempelkarte',
    description: 'Sammle Stempel und sichere dir deine Belohnung.',
    isEnabled: false,
    isPublic: true,
    stampCount: 10,
    previewCollectedStamps: 0,
    triggerType: 'per_visit',
    triggerLabel: 'Pro Besuch',
    rewardTitle: 'Belohnung',
    rewardDescription: 'Nach voller Karte erhält der Kunde eine Belohnung.',
    autoRewardEnabled: true,
    themeName: 'Tiffany',
    lookMode: 'Soft',
    stampShape: 'Kreis',
    iconCodePoint: Icons.restaurant_menu_outlined.codePoint,
    iconFontFamily: Icons.restaurant_menu_outlined.fontFamily,
    fontStyle: 'Modern',
  );
}