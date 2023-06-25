// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$MainState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            bool isAdRemoved, String chosenLanguage, String localeLanguage)
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            bool isAdRemoved, String chosenLanguage, String localeLanguage)?
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            bool isAdRemoved, String chosenLanguage, String localeLanguage)?
        loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MainStateLoading value) loading,
    required TResult Function(MainStateLoaded value) loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MainStateLoading value)? loading,
    TResult? Function(MainStateLoaded value)? loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MainStateLoading value)? loading,
    TResult Function(MainStateLoaded value)? loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MainStateCopyWith<$Res> {
  factory $MainStateCopyWith(MainState value, $Res Function(MainState) then) =
      _$MainStateCopyWithImpl<$Res, MainState>;
}

/// @nodoc
class _$MainStateCopyWithImpl<$Res, $Val extends MainState>
    implements $MainStateCopyWith<$Res> {
  _$MainStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MainStateLoadingCopyWith<$Res> {
  factory _$$MainStateLoadingCopyWith(
          _$MainStateLoading value, $Res Function(_$MainStateLoading) then) =
      __$$MainStateLoadingCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MainStateLoadingCopyWithImpl<$Res>
    extends _$MainStateCopyWithImpl<$Res, _$MainStateLoading>
    implements _$$MainStateLoadingCopyWith<$Res> {
  __$$MainStateLoadingCopyWithImpl(
      _$MainStateLoading _value, $Res Function(_$MainStateLoading) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MainStateLoading implements MainStateLoading {
  const _$MainStateLoading();

  @override
  String toString() {
    return 'MainState.loading()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MainStateLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            bool isAdRemoved, String chosenLanguage, String localeLanguage)
        loaded,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            bool isAdRemoved, String chosenLanguage, String localeLanguage)?
        loaded,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            bool isAdRemoved, String chosenLanguage, String localeLanguage)?
        loaded,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MainStateLoading value) loading,
    required TResult Function(MainStateLoaded value) loaded,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MainStateLoading value)? loading,
    TResult? Function(MainStateLoaded value)? loaded,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MainStateLoading value)? loading,
    TResult Function(MainStateLoaded value)? loaded,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class MainStateLoading implements MainState {
  const factory MainStateLoading() = _$MainStateLoading;
}

/// @nodoc
abstract class _$$MainStateLoadedCopyWith<$Res> {
  factory _$$MainStateLoadedCopyWith(
          _$MainStateLoaded value, $Res Function(_$MainStateLoaded) then) =
      __$$MainStateLoadedCopyWithImpl<$Res>;
  @useResult
  $Res call({bool isAdRemoved, String chosenLanguage, String localeLanguage});
}

/// @nodoc
class __$$MainStateLoadedCopyWithImpl<$Res>
    extends _$MainStateCopyWithImpl<$Res, _$MainStateLoaded>
    implements _$$MainStateLoadedCopyWith<$Res> {
  __$$MainStateLoadedCopyWithImpl(
      _$MainStateLoaded _value, $Res Function(_$MainStateLoaded) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isAdRemoved = null,
    Object? chosenLanguage = null,
    Object? localeLanguage = null,
  }) {
    return _then(_$MainStateLoaded(
      isAdRemoved: null == isAdRemoved
          ? _value.isAdRemoved
          : isAdRemoved // ignore: cast_nullable_to_non_nullable
              as bool,
      chosenLanguage: null == chosenLanguage
          ? _value.chosenLanguage
          : chosenLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      localeLanguage: null == localeLanguage
          ? _value.localeLanguage
          : localeLanguage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MainStateLoaded implements MainStateLoaded {
  const _$MainStateLoaded(
      {required this.isAdRemoved,
      required this.chosenLanguage,
      required this.localeLanguage});

  @override
  final bool isAdRemoved;
  @override
  final String chosenLanguage;
  @override
  final String localeLanguage;

  @override
  String toString() {
    return 'MainState.loaded(isAdRemoved: $isAdRemoved, chosenLanguage: $chosenLanguage, localeLanguage: $localeLanguage)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MainStateLoaded &&
            (identical(other.isAdRemoved, isAdRemoved) ||
                other.isAdRemoved == isAdRemoved) &&
            (identical(other.chosenLanguage, chosenLanguage) ||
                other.chosenLanguage == chosenLanguage) &&
            (identical(other.localeLanguage, localeLanguage) ||
                other.localeLanguage == localeLanguage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isAdRemoved, chosenLanguage, localeLanguage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MainStateLoadedCopyWith<_$MainStateLoaded> get copyWith =>
      __$$MainStateLoadedCopyWithImpl<_$MainStateLoaded>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            bool isAdRemoved, String chosenLanguage, String localeLanguage)
        loaded,
  }) {
    return loaded(isAdRemoved, chosenLanguage, localeLanguage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            bool isAdRemoved, String chosenLanguage, String localeLanguage)?
        loaded,
  }) {
    return loaded?.call(isAdRemoved, chosenLanguage, localeLanguage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            bool isAdRemoved, String chosenLanguage, String localeLanguage)?
        loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(isAdRemoved, chosenLanguage, localeLanguage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MainStateLoading value) loading,
    required TResult Function(MainStateLoaded value) loaded,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MainStateLoading value)? loading,
    TResult? Function(MainStateLoaded value)? loaded,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MainStateLoading value)? loading,
    TResult Function(MainStateLoaded value)? loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class MainStateLoaded implements MainState {
  const factory MainStateLoaded(
      {required final bool isAdRemoved,
      required final String chosenLanguage,
      required final String localeLanguage}) = _$MainStateLoaded;

  bool get isAdRemoved;
  String get chosenLanguage;
  String get localeLanguage;
  @JsonKey(ignore: true)
  _$$MainStateLoadedCopyWith<_$MainStateLoaded> get copyWith =>
      throw _privateConstructorUsedError;
}
