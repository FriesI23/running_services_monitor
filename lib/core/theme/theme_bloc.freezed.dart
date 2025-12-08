// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ThemeEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ThemeEvent()';
}


}

/// @nodoc
class $ThemeEventCopyWith<$Res>  {
$ThemeEventCopyWith(ThemeEvent _, $Res Function(ThemeEvent) __);
}


/// Adds pattern-matching-related methods to [ThemeEvent].
extension ThemeEventPatterns on ThemeEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ToggleTheme value)?  toggleTheme,TResult Function( _SetTheme value)?  setTheme,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToggleTheme() when toggleTheme != null:
return toggleTheme(_that);case _SetTheme() when setTheme != null:
return setTheme(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ToggleTheme value)  toggleTheme,required TResult Function( _SetTheme value)  setTheme,}){
final _that = this;
switch (_that) {
case _ToggleTheme():
return toggleTheme(_that);case _SetTheme():
return setTheme(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ToggleTheme value)?  toggleTheme,TResult? Function( _SetTheme value)?  setTheme,}){
final _that = this;
switch (_that) {
case _ToggleTheme() when toggleTheme != null:
return toggleTheme(_that);case _SetTheme() when setTheme != null:
return setTheme(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool isDark)?  toggleTheme,TResult Function( AppThemeMode mode)?  setTheme,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToggleTheme() when toggleTheme != null:
return toggleTheme(_that.isDark);case _SetTheme() when setTheme != null:
return setTheme(_that.mode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool isDark)  toggleTheme,required TResult Function( AppThemeMode mode)  setTheme,}) {final _that = this;
switch (_that) {
case _ToggleTheme():
return toggleTheme(_that.isDark);case _SetTheme():
return setTheme(_that.mode);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool isDark)?  toggleTheme,TResult? Function( AppThemeMode mode)?  setTheme,}) {final _that = this;
switch (_that) {
case _ToggleTheme() when toggleTheme != null:
return toggleTheme(_that.isDark);case _SetTheme() when setTheme != null:
return setTheme(_that.mode);case _:
  return null;

}
}

}

/// @nodoc


class _ToggleTheme implements ThemeEvent {
  const _ToggleTheme({required this.isDark});
  

 final  bool isDark;

/// Create a copy of ThemeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToggleThemeCopyWith<_ToggleTheme> get copyWith => __$ToggleThemeCopyWithImpl<_ToggleTheme>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleTheme&&(identical(other.isDark, isDark) || other.isDark == isDark));
}


@override
int get hashCode => Object.hash(runtimeType,isDark);

@override
String toString() {
  return 'ThemeEvent.toggleTheme(isDark: $isDark)';
}


}

/// @nodoc
abstract mixin class _$ToggleThemeCopyWith<$Res> implements $ThemeEventCopyWith<$Res> {
  factory _$ToggleThemeCopyWith(_ToggleTheme value, $Res Function(_ToggleTheme) _then) = __$ToggleThemeCopyWithImpl;
@useResult
$Res call({
 bool isDark
});




}
/// @nodoc
class __$ToggleThemeCopyWithImpl<$Res>
    implements _$ToggleThemeCopyWith<$Res> {
  __$ToggleThemeCopyWithImpl(this._self, this._then);

  final _ToggleTheme _self;
  final $Res Function(_ToggleTheme) _then;

/// Create a copy of ThemeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? isDark = null,}) {
  return _then(_ToggleTheme(
isDark: null == isDark ? _self.isDark : isDark // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _SetTheme implements ThemeEvent {
  const _SetTheme({required this.mode});
  

 final  AppThemeMode mode;

/// Create a copy of ThemeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetThemeCopyWith<_SetTheme> get copyWith => __$SetThemeCopyWithImpl<_SetTheme>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetTheme&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,mode);

@override
String toString() {
  return 'ThemeEvent.setTheme(mode: $mode)';
}


}

/// @nodoc
abstract mixin class _$SetThemeCopyWith<$Res> implements $ThemeEventCopyWith<$Res> {
  factory _$SetThemeCopyWith(_SetTheme value, $Res Function(_SetTheme) _then) = __$SetThemeCopyWithImpl;
@useResult
$Res call({
 AppThemeMode mode
});




}
/// @nodoc
class __$SetThemeCopyWithImpl<$Res>
    implements _$SetThemeCopyWith<$Res> {
  __$SetThemeCopyWithImpl(this._self, this._then);

  final _SetTheme _self;
  final $Res Function(_SetTheme) _then;

/// Create a copy of ThemeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mode = null,}) {
  return _then(_SetTheme(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,
  ));
}


}

// dart format on
