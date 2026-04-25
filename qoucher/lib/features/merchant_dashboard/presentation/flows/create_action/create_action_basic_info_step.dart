import 'package:flutter/material.dart';

class CreateActionBasicInfoStep extends StatefulWidget {
  const CreateActionBasicInfoStep({
    super.key,
    this.initialTitle,
    this.initialSubtitle,
    this.initialDescription,
    this.initialImageUrl,
    this.initialLinkedItemId,
    required this.onChanged,
  });

  final String? initialTitle;
  final String? initialSubtitle;
  final String? initialDescription;
  final String? initialImageUrl;
  final String? initialLinkedItemId;
  final void Function({
  required String title,
  required String subtitle,
  required String description,
  String? imageUrl,
  String? linkedItemId,
  }) onChanged;

  @override
  State<CreateActionBasicInfoStep> createState() =>
      _CreateActionBasicInfoStepState();
}

class _CreateActionBasicInfoStepState extends State<CreateActionBasicInfoStep> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _linkedItemIdController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _subtitleController =
        TextEditingController(text: widget.initialSubtitle ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    _imageUrlController =
        TextEditingController(text: widget.initialImageUrl ?? '');
    _linkedItemIdController =
        TextEditingController(text: widget.initialLinkedItemId ?? '');
  }

  void _emit() {
    widget.onChanged(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      linkedItemId: _linkedItemIdController.text.trim().isEmpty
          ? null
          : _linkedItemIdController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basisinfos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Titel',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _subtitleController,
          decoration: const InputDecoration(
            labelText: 'Untertitel',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Beschreibung',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: 'Bild-URL oder Asset-Pfad',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _linkedItemIdController,
          decoration: const InputDecoration(
            labelText: 'Verknüpfte Artikel-ID (optional)',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _linkedItemIdController.dispose();
    super.dispose();
  }
}