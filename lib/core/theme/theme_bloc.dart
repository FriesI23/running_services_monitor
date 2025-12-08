import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

part 'theme_bloc.freezed.dart';
part 'theme_event.dart';

enum AppThemeMode { system, light, dark }

@singleton
class ThemeBloc extends HydratedBloc<ThemeEvent, AppThemeMode> {
  ThemeBloc() : super(AppThemeMode.system) {
    on<_ToggleTheme>(_onToggleTheme);
    on<_SetTheme>(_onSetTheme);
  }

  void _onToggleTheme(_ToggleTheme event, Emitter<AppThemeMode> emit) {
    if (state == AppThemeMode.system) {
      event.isDark ? emit(AppThemeMode.light) : emit(AppThemeMode.dark);
    } else {
      state == AppThemeMode.dark ? emit(AppThemeMode.light) : emit(AppThemeMode.dark);
    }
  }

  void _onSetTheme(_SetTheme event, Emitter<AppThemeMode> emit) {
    emit(event.mode);
  }

  @override
  AppThemeMode? fromJson(Map<String, dynamic> json) {
    return AppThemeMode.values[json['theme_mode'] as int];
  }

  @override
  Map<String, dynamic>? toJson(AppThemeMode state) {
    return {'theme_mode': state.index};
  }
}
