// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_type_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RoomTypeState {
  RoomTypeStatus get status => throw _privateConstructorUsedError;
  List<RoomType>? get items => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of RoomTypeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomTypeStateCopyWith<RoomTypeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomTypeStateCopyWith<$Res> {
  factory $RoomTypeStateCopyWith(
          RoomTypeState value, $Res Function(RoomTypeState) then) =
      _$RoomTypeStateCopyWithImpl<$Res, RoomTypeState>;
  @useResult
  $Res call(
      {RoomTypeStatus status, List<RoomType>? items, String? errorMessage});
}

/// @nodoc
class _$RoomTypeStateCopyWithImpl<$Res, $Val extends RoomTypeState>
    implements $RoomTypeStateCopyWith<$Res> {
  _$RoomTypeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomTypeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? items = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomTypeStatus,
      items: freezed == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<RoomType>?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomTypeStateImplCopyWith<$Res>
    implements $RoomTypeStateCopyWith<$Res> {
  factory _$$RoomTypeStateImplCopyWith(
          _$RoomTypeStateImpl value, $Res Function(_$RoomTypeStateImpl) then) =
      __$$RoomTypeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RoomTypeStatus status, List<RoomType>? items, String? errorMessage});
}

/// @nodoc
class __$$RoomTypeStateImplCopyWithImpl<$Res>
    extends _$RoomTypeStateCopyWithImpl<$Res, _$RoomTypeStateImpl>
    implements _$$RoomTypeStateImplCopyWith<$Res> {
  __$$RoomTypeStateImplCopyWithImpl(
      _$RoomTypeStateImpl _value, $Res Function(_$RoomTypeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoomTypeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? items = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$RoomTypeStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomTypeStatus,
      items: freezed == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<RoomType>?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RoomTypeStateImpl implements _RoomTypeState {
  const _$RoomTypeStateImpl(
      {this.status = RoomTypeStatus.initial,
      final List<RoomType>? items,
      this.errorMessage})
      : _items = items;

  @override
  @JsonKey()
  final RoomTypeStatus status;
  final List<RoomType>? _items;
  @override
  List<RoomType>? get items {
    final value = _items;
    if (value == null) return null;
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'RoomTypeState(status: $status, items: $items, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomTypeStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status,
      const DeepCollectionEquality().hash(_items), errorMessage);

  /// Create a copy of RoomTypeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomTypeStateImplCopyWith<_$RoomTypeStateImpl> get copyWith =>
      __$$RoomTypeStateImplCopyWithImpl<_$RoomTypeStateImpl>(this, _$identity);
}

abstract class _RoomTypeState implements RoomTypeState {
  const factory _RoomTypeState(
      {final RoomTypeStatus status,
      final List<RoomType>? items,
      final String? errorMessage}) = _$RoomTypeStateImpl;

  @override
  RoomTypeStatus get status;
  @override
  List<RoomType>? get items;
  @override
  String? get errorMessage;

  /// Create a copy of RoomTypeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomTypeStateImplCopyWith<_$RoomTypeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
