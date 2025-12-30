// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_customer_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CreateCustomerState {
  CreateCustomerStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of CreateCustomerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateCustomerStateCopyWith<CreateCustomerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateCustomerStateCopyWith<$Res> {
  factory $CreateCustomerStateCopyWith(
          CreateCustomerState value, $Res Function(CreateCustomerState) then) =
      _$CreateCustomerStateCopyWithImpl<$Res, CreateCustomerState>;
  @useResult
  $Res call({CreateCustomerStatus status, String? errorMessage});
}

/// @nodoc
class _$CreateCustomerStateCopyWithImpl<$Res, $Val extends CreateCustomerState>
    implements $CreateCustomerStateCopyWith<$Res> {
  _$CreateCustomerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateCustomerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CreateCustomerStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateCustomerStateImplCopyWith<$Res>
    implements $CreateCustomerStateCopyWith<$Res> {
  factory _$$CreateCustomerStateImplCopyWith(_$CreateCustomerStateImpl value,
          $Res Function(_$CreateCustomerStateImpl) then) =
      __$$CreateCustomerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CreateCustomerStatus status, String? errorMessage});
}

/// @nodoc
class __$$CreateCustomerStateImplCopyWithImpl<$Res>
    extends _$CreateCustomerStateCopyWithImpl<$Res, _$CreateCustomerStateImpl>
    implements _$$CreateCustomerStateImplCopyWith<$Res> {
  __$$CreateCustomerStateImplCopyWithImpl(_$CreateCustomerStateImpl _value,
      $Res Function(_$CreateCustomerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateCustomerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$CreateCustomerStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CreateCustomerStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CreateCustomerStateImpl implements _CreateCustomerState {
  const _$CreateCustomerStateImpl(
      {this.status = CreateCustomerStatus.initial, this.errorMessage});

  @override
  @JsonKey()
  final CreateCustomerStatus status;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'CreateCustomerState(status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateCustomerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, errorMessage);

  /// Create a copy of CreateCustomerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateCustomerStateImplCopyWith<_$CreateCustomerStateImpl> get copyWith =>
      __$$CreateCustomerStateImplCopyWithImpl<_$CreateCustomerStateImpl>(
          this, _$identity);
}

abstract class _CreateCustomerState implements CreateCustomerState {
  const factory _CreateCustomerState(
      {final CreateCustomerStatus status,
      final String? errorMessage}) = _$CreateCustomerStateImpl;

  @override
  CreateCustomerStatus get status;
  @override
  String? get errorMessage;

  /// Create a copy of CreateCustomerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateCustomerStateImplCopyWith<_$CreateCustomerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
