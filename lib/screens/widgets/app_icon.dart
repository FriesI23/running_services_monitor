import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:running_services_monitor/bloc/app_info_bloc/app_info_bloc.dart';
import 'package:running_services_monitor/core/dependency_injection/dependency_injection.dart';
import 'package:running_services_monitor/models/service_info.dart';

class AppIcon extends StatelessWidget {
  final AppProcessInfo appInfo;
  final double size;

  const AppIcon({super.key, required this.appInfo, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppInfoBloc, AppInfoState, Uint8List?>(
      bloc: getIt<AppInfoBloc>(),
      selector: (state) {
        return state.value.cachedApps[appInfo.packageName]?.icon;
      },
      builder: (context, icon) {
        if (icon != null) {
          return Image.memory(icon, width: size, height: size);
        }

        if (appInfo.appInfo != null && appInfo.appInfo!.icon != null) {
          return Image.memory(appInfo.appInfo!.icon!, width: size, height: size);
        }

        for (var service in appInfo.services) {
          if (service.icon != null) {
            return Image.memory(service.icon!, width: size, height: size);
          }
        }

        return Icon(Icons.android, size: size);
      },
    );
  }
}
