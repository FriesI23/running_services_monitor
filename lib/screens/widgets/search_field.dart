import 'package:flutter/material.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;

  const SearchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.searchApps,
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
