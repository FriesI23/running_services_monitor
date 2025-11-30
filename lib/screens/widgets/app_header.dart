import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'app_icon.dart';

class AppHeader extends StatelessWidget {
  final AppProcessInfo appInfo;

  const AppHeader({super.key, required this.appInfo});

  @override
  Widget build(BuildContext context) {
    final processCount = appInfo.pids.length;
    final serviceCount = appInfo.services.length;

    return Row(
      children: [
        AppIcon(appInfo: appInfo),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appInfo.appName, style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 4.h),
              Text(
                '$processCount process and $serviceCount services',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Text(appInfo.totalRam, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
