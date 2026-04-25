import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/controllers/merchant_create_action_controller.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/flows/create_action/create_action_basic_info_step.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/flows/create_action/create_action_flow_data.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/flows/create_action/create_action_preview_step.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/flows/create_action/create_action_rules_step.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/flows/create_action/create_action_schedule_step.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/flows/create_action/create_action_type_step.dart';
import 'package:qoucher/features/merchant_dashboard/presentation/flows/create_action/create_action_visibility_step.dart';

class MerchantCreateActionPage extends StatefulWidget {
  const MerchantCreateActionPage({
    super.key,
    required this.merchantId,
    required this.shopName,
  });

  final String merchantId;
  final String shopName;

  @override
  State<MerchantCreateActionPage> createState() =>
      _MerchantCreateActionPageState();
}

class _MerchantCreateActionPageState extends State<MerchantCreateActionPage> {
  int currentStep = 0;
  CreateActionFlowData data = const CreateActionFlowData();

  Future<void> _submit() async {
    final controller = context.read<MerchantCreateActionController>();

    final success = await controller.createAction(
      merchantId: widget.merchantId,
      shopName: widget.shopName,
      type: data.type ?? 'deal',
      title: data.title ?? '',
      subtitle: data.subtitle ?? '',
      description: data.description ?? '',
      status: data.status,
      isVisible: data.isVisible,
      imageUrl: data.imageUrl,
      linkedItemId: data.linkedItemId,
      rules: data.rules,
      startsAt: data.startsAt,
      endsAt: data.endsAt,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Aktion erstellt' : (controller.errorMessage ?? 'Fehler')),
      ),
    );

    if (success) {
      Navigator.of(context).pop();
    }
  }

  void _next() {
    if (currentStep < 5) {
      setState(() {
        currentStep++;
      });
    }
  }

  void _back() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Widget _buildStep() {
    switch (currentStep) {
      case 0:
        return CreateActionTypeStep(
          selectedType: data.type,
          onSelected: (value) {
            setState(() {
              data = data.copyWith(type: value);
            });
          },
        );
      case 1:
        return CreateActionBasicInfoStep(
          initialTitle: data.title,
          initialSubtitle: data.subtitle,
          initialDescription: data.description,
          initialImageUrl: data.imageUrl,
          initialLinkedItemId: data.linkedItemId,
          onChanged: ({
            required String title,
            required String subtitle,
            required String description,
            String? imageUrl,
            String? linkedItemId,
          }) {
            data = data.copyWith(
              title: title,
              subtitle: subtitle,
              description: description,
              imageUrl: imageUrl,
              linkedItemId: linkedItemId,
            );
          },
        );
      case 2:
        return CreateActionRulesStep(
          initialRules: data.rules,
          onChanged: (rules) {
            data = data.copyWith(rules: rules);
          },
        );
      case 3:
        return CreateActionScheduleStep(
          startsAt: data.startsAt,
          endsAt: data.endsAt,
          onChanged: (startsAt, endsAt) {
            setState(() {
              data = data.copyWith(
                startsAt: startsAt,
                endsAt: endsAt,
              );
            });
          },
        );
      case 4:
        return CreateActionVisibilityStep(
          isVisible: data.isVisible,
          status: data.status,
          onVisibilityChanged: (value) {
            setState(() {
              data = data.copyWith(isVisible: value);
            });
          },
          onStatusChanged: (value) {
            setState(() {
              data = data.copyWith(status: value);
            });
          },
        );
      default:
        return CreateActionPreviewStep(data: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantCreateActionController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Neue Aktion erstellen'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(child: SingleChildScrollView(child: _buildStep())),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: currentStep == 0 ? null : _back,
                        child: const Text('Zurück'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isLoading
                            ? null
                            : currentStep == 5
                            ? _submit
                            : _next,
                        child: controller.isLoading
                            ? const CircularProgressIndicator()
                            : Text(currentStep == 5 ? 'Erstellen' : 'Weiter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}