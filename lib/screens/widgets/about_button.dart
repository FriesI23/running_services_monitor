import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';

class AboutButton extends StatelessWidget {
  const AboutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: () => context.push('/about'),
      tooltip: AppLocalizations.of(context)!.about,
    );
  }
}
