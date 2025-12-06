import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'package:running_services_monitor/models/process_state_filter.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';
import 'app_icon.dart';

class AppListItem extends StatelessWidget {
  final AppProcessInfo appInfo;

  const AppListItem({super.key, required this.appInfo});

  @override
  Widget build(BuildContext context) {
    final processCount = appInfo.pids.length;
    final serviceCount = appInfo.services.length;
    final loc = AppLocalizations.of(context)!;

    final isActive = isActiveState(appInfo.processState, hasServices: appInfo.hasServices);
    final isCached = isCachedState(appInfo.processState);

    return ListTile(
      leading: AppIcon(appInfo: appInfo, size: 40.sp),
      title: Text(
        appInfo.appName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 16.sp),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$processCount ${loc.processAnd} $serviceCount ${loc.services}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 4.w,
            runSpacing: 2.h,
            children: [
              if (isActive) _StateBadge(label: loc.active, color: Colors.green),
              if (isCached) _StateBadge(label: loc.cached, color: Colors.grey),
              if (appInfo.hasServices) _StateBadge(label: loc.services, color: Colors.blue),
            ],
          ),
        ],
      ),
      trailing: Text(appInfo.totalRam, style: TextStyle(fontSize: 14.sp)),
      onTap: () {
        context.push('/app-details', extra: appInfo.packageName);
      },
    );
  }
}

class _StateBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StateBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
