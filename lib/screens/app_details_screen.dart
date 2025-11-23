import 'package:flutter/material.dart';
import '../models/service_info.dart';
import 'package:running_services_monitor/l10n/app_localizations.dart';
import 'widgets/app_header.dart';
import 'widgets/service_list.dart';
import 'widgets/app_details_description.dart';
import 'widgets/app_details_section_title.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:running_services_monitor/bloc/app_details_bloc/app_details_bloc.dart';
import 'package:running_services_monitor/core/dependency_injection/dependency_injection.dart';

class AppDetailsScreen extends StatelessWidget {
  final AppProcessInfo appInfo;

  const AppDetailsScreen({super.key, required this.appInfo});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AppDetailsBloc>()..add(AppDetailsEvent.loadDetails(appInfo: appInfo)),
      child: BlocBuilder<AppDetailsBloc, AppDetailsState>(
        builder: (context, state) {
          final currentAppInfo = state.maybeWhen(
            success: (info) => info,
            loading: (info) => info,
            failure: (info, _) => info,
            orElse: () => appInfo,
          );

          return SelectionArea(
            child: Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.of(context)!.runningApp)),
              body: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(24.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        AppHeader(appInfo: currentAppInfo),
                        const SizedBox(height: 24),

                        // Description
                        const AppDetailsDescription(),

                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Service List
                        AppDetailsSectionTitle(title: AppLocalizations.of(context)!.activeServices),
                        const SizedBox(height: 8),
                      ]),
                    ),
                  ),
                  SliverFillRemaining(hasScrollBody: true, child: ServiceList(services: currentAppInfo.services)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
