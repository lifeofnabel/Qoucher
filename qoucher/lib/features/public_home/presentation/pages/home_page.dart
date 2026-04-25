import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/public_home/presentation/controllers/public_home_controller.dart';
import 'package:qoucher/features/public_home/presentation/pages/merchant_detail_page.dart';
import 'package:qoucher/features/public_home/presentation/pages/deals_pages.dart';
import 'deals_pages.dart';
import 'merchant_detail_page.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({super.key});

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = const [
    '',
    'Restaurant',
    'Kiosk',
    'Hotel',
    'Beauty',
    'Barber',
    'Hygiene',
  ];

  final List<String> areas = const [
    '',
    'Westend',
    'Innenstadt',
    'Sachsenhausen',
    'Nordend',
    'Frankfurt Süd',
    'Frankfurt Berg',
  ];

  String selectedCategory = '';
  String selectedArea = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PublicHomeController>().loadHome();
    });
  }

  Future<void> _applyFilters() async {
    await context.read<PublicHomeController>().applyFilters(
      category: selectedCategory,
      area: selectedArea,
      query: _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicHomeController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Qoucher'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: controller.loadHome,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Heißeste Deals',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Lokal. Schnell. Ohne unnötigen Müll.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Suchen...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Kategorie',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: categories
                            .map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.isEmpty ? 'Alle' : e),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value ?? '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedArea,
                        decoration: InputDecoration(
                          labelText: 'Ort',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: areas
                            .map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.isEmpty ? 'Alle' : e),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedArea = value ?? '';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Filter anwenden'),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Aktuelle Deals',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PublicDealsPage(),
                        ),
                      );
                    },
                    child: const Text('Alle sehen'),
                  ),
                ),
                if (controller.deals.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Keine Deals gefunden.'),
                    ),
                  )
                else
                  ...controller.deals.take(5).map(
                        (deal) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        title: Text(
                          '${deal['title'] ?? 'Deal'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${deal['subtitle'] ?? ''}',
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Läden',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                if (controller.featuredShops.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Keine Läden gefunden.'),
                    ),
                  )
                else
                  ...controller.featuredShops.map(
                        (shop) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        title: Text(
                          '${shop['businessName'] ?? 'Shop'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${shop['description'] ?? ''}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          final merchantId =
                          (shop['merchantId'] ?? shop['id'] ?? '')
                              .toString();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MerchantDetailsPage(
                                merchantId: merchantId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}