import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
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
          SizedBox(width: 8.w),
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
            SizedBox(height: 16.h),
            Text(AppLocalizations.of(context)!.setupSteps, style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            SetupStepItem(number: '1', text: AppLocalizations.of(context)!.step1),
            SetupStepItem(number: '2', text: AppLocalizations.of(context)!.step2),
            SetupStepItem(number: '3', text: AppLocalizations.of(context)!.step3),
            SetupStepItem(number: '4', text: AppLocalizations.of(context)!.step4),
            SetupStepItem(number: '5', text: AppLocalizations.of(context)!.step5),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.rSafe),
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
                  SizedBox(height: 8.h),
                  Text(
                    AppLocalizations.of(context)!.quickStartSteps,
                    style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onPrimaryContainer),
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
