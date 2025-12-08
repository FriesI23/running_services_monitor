import 'package:flutter/material.dart';
import 'package:running_services_monitor/core/dependency_injection/dependency_injection.dart';
import 'package:running_services_monitor/core/theme/theme_bloc.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return IconButton(
      icon: Icon(brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => getIt<ThemeBloc>().add(ThemeEvent.toggleTheme(isDark: brightness == Brightness.dark)),
      tooltip: AppLocalizations.of(context)!.toggleTheme,
    );
  }
}
