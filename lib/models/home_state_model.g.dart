// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeStateModel _$HomeStateModelFromJson(Map<String, dynamic> json) =>
    _HomeStateModel(
      allApps:
          (json['allApps'] as List<dynamic>?)
              ?.map((e) => AppProcessInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedProcessFilter:
          $enumDecodeNullable(
            _$ProcessStateFilterEnumMap,
            json['selectedProcessFilter'],
          ) ??
          ProcessStateFilter.all,
      sortAscending: json['sortAscending'] as bool? ?? false,
    );

Map<String, dynamic> _$HomeStateModelToJson(_HomeStateModel instance) =>
    <String, dynamic>{
      'allApps': instance.allApps,
      'selectedProcessFilter':
          _$ProcessStateFilterEnumMap[instance.selectedProcessFilter]!,
      'sortAscending': instance.sortAscending,
    };

const _$ProcessStateFilterEnumMap = {
  ProcessStateFilter.all: 'all',
  ProcessStateFilter.active: 'active',
  ProcessStateFilter.cached: 'cached',
  ProcessStateFilter.withServices: 'withServices',
};
