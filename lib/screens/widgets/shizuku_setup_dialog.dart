import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';
import 'setup_step_item.dart';

class ShizukuSetupDialog extends StatelessWidget {
  final VoidCallback onRetry;

  const ShizukuSetupDialog({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.shizukuRequired),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.shizukuRequiredMessage,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.setupSteps, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SetupStepItem(number: '1', text: AppLocalizations.of(context)!.step1),
            SetupStepItem(number: '2', text: AppLocalizations.of(context)!.step2),
            SetupStepItem(number: '3', text: AppLocalizations.of(context)!.step3),
            SetupStepItem(number: '4', text: AppLocalizations.of(context)!.step4),
            SetupStepItem(number: '5', text: AppLocalizations.of(context)!.step5),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.quickStart,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.quickStartSteps,
                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => SystemNavigator.pop(), child: Text(AppLocalizations.of(context)!.exitApp)),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(AppLocalizations.of(context)!.retry),
        ),
      ],
    );
  }
}
