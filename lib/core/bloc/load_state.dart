import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/app_exception.dart';

enum ViewStatus { initial, loading, success, failure }

/// Trạng thái của một khối dữ liệu tải từ API. Khi tải lại hoặc lỗi,
/// dữ liệu cũ vẫn được giữ để màn hình không nháy trắng.
class LoadState<T> extends Equatable {
  const LoadState({
    this.status = ViewStatus.initial,
    this.data,
    this.error,
    this.errorKind,
  });

  final ViewStatus status;
  final T? data;
  final String? error;

  /// Nhóm lỗi để chọn component: mất mạng, lỗi hệ thống, lỗi yêu cầu.
  final AppErrorKind? errorKind;

  bool get isLoading => status == ViewStatus.loading;
  bool get isFailure => status == ViewStatus.failure;
  bool get hasData => data != null;

  LoadState<T> toLoading() => LoadState(status: ViewStatus.loading, data: data);

  LoadState<T> toSuccess(T value) =>
      LoadState(status: ViewStatus.success, data: value);

  /// Chuyển lỗi bất kỳ (DioException, AppException…) thành trạng thái lỗi đã phân loại.
  LoadState<T> toError(Object error) {
    final exception = AppException.from(error);
    return toFailure(exception.message, kind: exception.kind);
  }

  LoadState<T> toFailure(
    String message, {
    AppErrorKind kind = AppErrorKind.unknown,
  }) =>
      LoadState(
        status: ViewStatus.failure,
        data: data,
        error: message,
        errorKind: kind,
      );

  @override
  List<Object?> get props => [status, data, error, errorKind];
}

/// Cubit cơ sở cho màn chỉ cần tải một khối dữ liệu.
abstract class LoadCubit<T> extends Cubit<LoadState<T>> {
  LoadCubit() : super(LoadState<T>());

  Future<void> load();

  @protected
  Future<void> guard(Future<T> Function() task) async {
    emit(state.toLoading());
    try {
      final value = await task();
      if (!isClosed) emit(state.toSuccess(value));
    } catch (error) {
      if (!isClosed) emit(state.toError(error));
    }
  }
}

/// Kết quả một thao tác ghi (tạo/sửa/xoá) trả về cho màn hình.
class ActionResult<T> {
  const ActionResult.success([this.value]) : error = null;

  const ActionResult.failure(String this.error) : value = null;

  final T? value;
  final String? error;

  bool get isSuccess => error == null;
}

Future<ActionResult<T>> runAction<T>(Future<T> Function() task) async {
  try {
    return ActionResult.success(await task());
  } catch (error) {
    return ActionResult.failure(AppException.from(error).message);
  }
}
