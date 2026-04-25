import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/user_dashboard/presentation/controllers/user_dashboard_controller.dart';

class MyActivityPage extends StatefulWidget {
  const MyActivityPage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<MyActivityPage> createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserDashboardController>().loadActivities(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDashboardController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meine Aktivitäten'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.activities.isEmpty
              ? const Center(child: Text('Noch keine Aktivitäten.'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.activities.length,
            itemBuilder: (context, index) {
              final activity = controller.activities[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  title: Text(
                    '${activity['title'] ?? 'Aktivität'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${activity['description'] ?? ''}\n'
                        '${activity['createdAt'] ?? ''}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
    );
  }
}