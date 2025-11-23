import 'package:flutter/material.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';

class AppDetailsDescription extends StatelessWidget {
  const AppDetailsDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.stopWarning,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
    );
  }
}
