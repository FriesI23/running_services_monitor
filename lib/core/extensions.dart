import 'package:flutter/material.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
