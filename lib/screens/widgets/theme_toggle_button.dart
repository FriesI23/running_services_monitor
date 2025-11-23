import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:running_services_monitor/core/theme/theme_bloc.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => context.read<ThemeBloc>().toggleTheme(),
      tooltip: AppLocalizations.of(context)!.toggleTheme,
    );
  }
}
