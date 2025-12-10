import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:running_services_monitor/bloc/app_info_bloc/app_info_bloc.dart';
import 'package:running_services_monitor/core/dependency_injection/dependency_injection.dart';
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
    final loc = AppLocalizations.of(context)!;

    return ListTile(
      leading: AppIcon(appInfo: appInfo, size: 40.sp),
      title: BlocSelector<AppInfoBloc, AppInfoState, String?>(
        bloc: getIt<AppInfoBloc>(),
        selector: (state) {
          return state.value.cachedApps[appInfo.packageName]?.appName;
        },
        builder: (context, appName) {
          return Text(
            appName ?? appInfo.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16.sp),
          );
        },
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              if (processCount > 0) '$processCount ${loc.process}',
              if (serviceCount > 0) '$serviceCount ${loc.services}',
            ].join(' ${loc.and} '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 4.w,
            runSpacing: 2.h,
            children: [
              if (appInfo.isActive) _StateBadge(label: loc.active, color: Colors.green),
              if (appInfo.isCachedProcess) _StateBadge(label: loc.cached, color: Colors.grey),
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
