import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';
import 'app_icon.dart';

class AppListItem extends StatelessWidget {
  final AppProcessInfo appInfo;

  const AppListItem({super.key, required this.appInfo});

  @override
  Widget build(BuildContext context) {
    final processCount = appInfo.pids.length;
    final serviceCount = appInfo.services.length;

    return ListTile(
      leading: AppIcon(appInfo: appInfo, size: 40),
      title: Text(appInfo.appName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
      subtitle: Text(
        '$processCount ${AppLocalizations.of(context)!.processAnd} $serviceCount ${AppLocalizations.of(context)!.services}',
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      ),
      trailing: Text(appInfo.totalRam, style: const TextStyle(fontSize: 14)),
      onTap: () {
        context.push('/app-details', extra: appInfo);
      },
    );
  }
}
