import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/user_dashboard/presentation/controllers/user_dashboard_controller.dart';

class MyQrPage extends StatefulWidget {
  const MyQrPage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<MyQrPage> createState() => _MyQrPageState();
}

class _MyQrPageState extends State<MyQrPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserDashboardController>().loadQrData(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDashboardController>(
      builder: (context, controller, _) {
        final qrData = controller.qrData ?? {};
        final liveCode = (qrData['liveCode'] ?? '---').toString();
        final qrText = (qrData['qrText'] ?? liveCode).toString();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mein QR'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade200,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          qrText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Temporärer Live-Code',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        liveCode,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}