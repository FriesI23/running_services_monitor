import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:running_services_monitor/bloc/stop_service_bloc/stop_service_bloc.dart';
import 'package:running_services_monitor/bloc/home_bloc/home_bloc.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';
import 'package:running_services_monitor/core/dependency_injection/dependency_injection.dart';
import 'app_list_item.dart';

class DismissibleAppListItem extends StatefulWidget {
  final AppProcessInfo appInfo;

  const DismissibleAppListItem({super.key, required this.appInfo});

  @override
  State<DismissibleAppListItem> createState() => _DismissibleAppListItemState();
}

class _DismissibleAppListItemState extends State<DismissibleAppListItem> {
  late final StopServiceBloc _stopServiceBloc;

  @override
  void initState() {
    super.initState();
    _stopServiceBloc = getIt<StopServiceBloc>();
  }

  @override
  void dispose() {
    _stopServiceBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _stopServiceBloc,
      child: BlocListener<StopServiceBloc, StopServiceState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            stopping: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Text(AppLocalizations.of(context)!.loading, style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                  duration: const Duration(seconds: 10),
                  backgroundColor: Colors.blue[700],
                ),
              );
            },
            success: (packageName, pid) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(child: Text(AppLocalizations.of(context)!.allServicesStopped, style: TextStyle(fontSize: 14.sp))),
                    ],
                  ),
                  backgroundColor: Colors.green[700],
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              if (packageName != null) {
                context.read<HomeBloc>().add(HomeEvent.removeApp(packageName));
              }
            },
            error: (message) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(child: Text('${AppLocalizations.of(context)!.stopServiceError}: $message', style: TextStyle(fontSize: 14.sp))),
                    ],
                  ),
                  backgroundColor: Colors.red[700],
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
                ),
              );
            },
          );
        },
        child: Dismissible(
          key: Key(widget.appInfo.packageName),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.stopAllServicesConfirm, style: TextStyle(fontSize: 18.sp)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.appInfo.appName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.stopServiceWarning, style: TextStyle(fontSize: 14.sp)),
                    if (widget.appInfo.isSystemApp) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[900]?.withValues(alpha: 0.3),
                          border: Border.all(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.systemAppWarning,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(fontSize: 14.sp)),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                      _stopServiceBloc.add(
                        StopServiceEvent.stopAllServices(
                          packageName: widget.appInfo.packageName,
                          pids: widget.appInfo.pids,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(AppLocalizations.of(context)!.stop, style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            );
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stop_circle, color: Colors.white, size: 32),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.stop,
                  style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          child: AppListItem(appInfo: widget.appInfo),
        ),
      ),
    );
  }
}
