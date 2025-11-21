import 'package:flutter/material.dart';
import '../models/service_info.dart';
import '../screens/app_details_screen.dart';

class AppListItem extends StatelessWidget {
  final AppProcessInfo appInfo;

  const AppListItem({super.key, required this.appInfo});

  @override
  Widget build(BuildContext context) {
    final processCount = appInfo.pids.length;
    final serviceCount = appInfo.services.length;

    return ListTile(
      leading: _buildAppIcon(),
      title: Text(appInfo.appName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
      subtitle: Text(
        '$processCount process and $serviceCount services',
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      ),
      trailing: Text(appInfo.totalRam, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppDetailsScreen(appInfo: appInfo)));
      },
    );
  }

  Widget _buildAppIcon() {
    if (appInfo.appInfo != null && appInfo.appInfo!.icon != null) {
      return Image.memory(appInfo.appInfo!.icon!, width: 40, height: 40);
    }
    return const Icon(Icons.android, size: 40);
  }
}
