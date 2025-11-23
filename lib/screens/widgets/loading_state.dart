import 'package:flutter/material.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.loadingServices),
        ],
      ),
    );
  }
}
