import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/public_home/presentation/controllers/public_home_controller.dart';

class PublicDealsPage extends StatefulWidget {
  const PublicDealsPage({super.key});

  @override
  State<PublicDealsPage> createState() => _PublicDealsPageState();
}

class _PublicDealsPageState extends State<PublicDealsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PublicHomeController>().loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicHomeController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Deals'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.errorMessage != null
              ? Center(child: Text(controller.errorMessage!))
              : controller.deals.isEmpty
              ? const Center(child: Text('Keine Deals gefunden.'))
              : RefreshIndicator(
            onRefresh: controller.loadHome,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.deals.length,
              itemBuilder: (context, index) {
                final deal = controller.deals[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    title: Text(
                      '${deal['title'] ?? 'Deal'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${deal['subtitle'] ?? ''}\n'
                            '${deal['description'] ?? ''}',
                      ),
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}