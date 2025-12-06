import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:running_services_monitor/bloc/home_bloc/home_bloc.dart';
import 'package:running_services_monitor/core/extensions.dart';
import 'package:running_services_monitor/models/process_state_filter.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'app_list.dart';
import 'ram_bar.dart';
import 'loading_state.dart';
import 'error_state.dart';
import 'package:running_services_monitor/models/home_state_model.dart';

class HomeBody extends StatelessWidget {
  final TabController tabController;

  const HomeBody({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      HomeBloc,
      HomeState,
      ({bool isLoading, String? loadingMessage, bool isError, String? errorMessage, bool hasApps, HomeStateModel model})
    >(
      selector: (state) {
        final (isLoading, loadingMessage) = state.mapOrNull(loading: (s) => (true, s.message)) ?? (false, null);

        final (isError, errorMessage) = state.mapOrNull(failure: (s) => (true, s.message)) ?? (false, null);

        return (
          isLoading: isLoading,
          loadingMessage: loadingMessage,
          isError: isError,
          errorMessage: errorMessage,
          hasApps: state.value.allApps.isNotEmpty,
          model: state.value,
        );
      },
      builder: (context, data) {
        if (data.isLoading && !data.hasApps) {
          return LoadingState(status: data.loadingMessage);
        }

        if (data.isError && !data.hasApps) {
          return ErrorState(
            errorMessage: data.errorMessage ?? context.loc.error,
            onRetry: () => context.read<HomeBloc>().add(const HomeEvent.initializeShizuku()),
          );
        }

        final ram = (total: data.model.totalRamKb, used: data.model.usedRamKb, free: data.model.freeRamKb);

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterChipsDelegate(
                  child: _ProcessFilterChips(
                    selectedFilter: data.model.selectedProcessFilter,
                    apps: data.model.allApps,
                    sortAscending: data.model.sortAscending,
                  ),
                ),
              ),
              if (ram.total > 0)
                SliverPersistentHeader(
                  pinned: false,
                  delegate: _RamBarDelegate(
                    ramBar: RamBar(totalRamKb: ram.total, usedRamKb: ram.used, freeRamKb: ram.free),
                  ),
                ),
              SliverToBoxAdapter(child: Divider(height: 1.h)),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              AppList(apps: data.model.allApps),
              AppList(apps: data.model.userApps),
              AppList(apps: data.model.systemApps),
            ],
          ),
        );
      },
    );
  }
}

class _ProcessFilterChips extends StatelessWidget {
  final ProcessStateFilter selectedFilter;
  final List<AppProcessInfo> apps;
  final bool sortAscending;

  const _ProcessFilterChips({required this.selectedFilter, required this.apps, required this.sortAscending});

  @override
  Widget build(BuildContext context) {
    final activeCount = apps.where((a) => isActiveState(a.processState, hasServices: a.hasServices)).length;
    final cachedCount = apps.where((a) => isCachedState(a.processState)).length;
    final servicesCount = apps.where((a) => a.hasServices).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          _FilterChip(
            label: context.loc.all,
            isSelected: selectedFilter == ProcessStateFilter.all,
            onSelected: () => context.read<HomeBloc>().add(const HomeEvent.setProcessFilter(ProcessStateFilter.all)),
            sortAscending: selectedFilter == ProcessStateFilter.all ? sortAscending : null,
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: '${context.loc.active} ($activeCount)',
            isSelected: selectedFilter == ProcessStateFilter.active,
            onSelected: () => context.read<HomeBloc>().add(const HomeEvent.setProcessFilter(ProcessStateFilter.active)),
            color: Colors.green,
            sortAscending: selectedFilter == ProcessStateFilter.active ? sortAscending : null,
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: '${context.loc.cached} ($cachedCount)',
            isSelected: selectedFilter == ProcessStateFilter.cached,
            onSelected: () => context.read<HomeBloc>().add(const HomeEvent.setProcessFilter(ProcessStateFilter.cached)),
            color: Colors.grey,
            sortAscending: selectedFilter == ProcessStateFilter.cached ? sortAscending : null,
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: '${context.loc.services} ($servicesCount)',
            isSelected: selectedFilter == ProcessStateFilter.withServices,
            onSelected: () =>
                context.read<HomeBloc>().add(const HomeEvent.setProcessFilter(ProcessStateFilter.withServices)),
            color: Colors.blue,
            sortAscending: selectedFilter == ProcessStateFilter.withServices ? sortAscending : null,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? color;
  final bool? sortAscending;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.color,
    this.sortAscending,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (isSelected && sortAscending != null) ...[
            SizedBox(width: 4.w),
            Icon(
              sortAscending! ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14.sp,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        if (isSelected) {
          context.read<HomeBloc>().add(const HomeEvent.toggleSortOrder());
        } else {
          onSelected();
        }
      },
      selectedColor: color?.withValues(alpha: 0.3) ?? Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: color ?? Theme.of(context).colorScheme.primary,
      side: isSelected && color != null ? BorderSide(color: color!, width: 1) : null,
    );
  }
}

class _RamBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget ramBar;

  _RamBarDelegate({required this.ramBar});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).colorScheme.surface, child: ramBar);
  }

  @override
  double get maxExtent => 150.h;

  @override
  double get minExtent => 150.h;

  @override
  bool shouldRebuild(covariant _RamBarDelegate oldDelegate) {
    return ramBar != oldDelegate.ramBar;
  }
}

class _FilterChipsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterChipsDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).colorScheme.surface, child: child);
  }

  @override
  double get maxExtent => 52.h;

  @override
  double get minExtent => 52.h;

  @override
  bool shouldRebuild(covariant _FilterChipsDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
