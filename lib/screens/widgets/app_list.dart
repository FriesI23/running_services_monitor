import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:running_services_monitor/bloc/home_bloc/home_bloc.dart';
import 'package:running_services_monitor/models/process_state_filter.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'dismissible_app_list_item.dart';
import 'empty_list_state.dart';

class AppList extends StatelessWidget {
  final List<AppProcessInfo> apps;

  const AppList({super.key, required this.apps});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      HomeBloc,
      HomeState,
      ({String searchQuery, ProcessStateFilter processFilter, bool sortAscending})
    >(
      selector: (state) => (
        searchQuery: state.value.searchQuery,
        processFilter: state.value.selectedProcessFilter,
        sortAscending: state.value.sortAscending,
      ),
      builder: (context, data) {
        var filteredApps = apps.where((app) {
          if (data.searchQuery.isNotEmpty) {
            final name = app.appName.toLowerCase();
            final pkg = app.packageName.toLowerCase();
            if (!name.contains(data.searchQuery) && !pkg.contains(data.searchQuery)) {
              return false;
            }
          }

          return data.processFilter.matchesAppState(app.processState, app.hasServices);
        }).toList();

        if (data.sortAscending) {
          filteredApps.sort((a, b) => a.totalRamInKb.compareTo(b.totalRamInKb));
        } else {
          filteredApps.sort((a, b) => b.totalRamInKb.compareTo(a.totalRamInKb));
        }

        Widget content;
        if (filteredApps.isEmpty) {
          content = EmptyListState(isSearching: data.searchQuery.isNotEmpty);
        } else {
          content = CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return DismissibleAppListItem(appInfo: filteredApps[index]);
                }, childCount: filteredApps.length),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final homeBloc = context.read<HomeBloc>();
            final future = homeBloc.stream.first;
            homeBloc.add(const HomeEvent.loadData());
            await future;
          },
          child: content,
        );
      },
    );
  }
}
