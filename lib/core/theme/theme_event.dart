part of 'theme_bloc.dart';

@freezed
sealed class ThemeEvent with _$ThemeEvent {
  const factory ThemeEvent.toggleTheme({required bool isDark}) = _ToggleTheme;
  const factory ThemeEvent.setTheme({required AppThemeMode mode}) = _SetTheme;
}
