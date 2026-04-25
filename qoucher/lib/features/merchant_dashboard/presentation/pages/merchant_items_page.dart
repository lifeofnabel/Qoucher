import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_items_controller.dart';

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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MerchantItemsController>().loadItems(widget.merchantId);
    });
  }

  Future<void> _createItem() async {
    final controller = context.read<MerchantItemsController>();

    final success = await controller.createItem(
      merchantId: widget.merchantId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      originalPrice: double.tryParse(_priceController.text.trim()) ?? 0,
      imageUrl: _imageUrlController.text.trim(),
      category: _categoryController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Artikel erstellt.' : (controller.errorMessage ?? 'Fehler'),
        ),
      ),
    );

    if (success) {
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      _categoryController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantItemsController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meine Artikel'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Neuen Artikel erstellen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Originalpreis',
                  border: OutlineInputBorder(),
                  suffixText: '€',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Bild-URL / Asset',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategorie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isSaving ? null : _createItem,
                  child: controller.isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Artikel speichern'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bestehende Artikel',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (controller.items.isEmpty)
                const Text('Noch keine Artikel vorhanden.'),
              ...controller.items.map(
                    (item) => Card(
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.description}\n${item.originalPrice.toStringAsFixed(2)} € · ${item.category}',
                    ),
                    isThreeLine: true,
                    trailing: Icon(
                      item.isActive ? Icons.check_circle : Icons.pause_circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}