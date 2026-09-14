import 'package:equatable/equatable.dart';

import 'json_reader.dart';

/// `PageResponse` của BE: `{content, page, size, totalElements, totalPages}`.
class Paged<T> extends Equatable {
  const Paged({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory Paged.fromJson(Json json, T Function(Json json) parse) => Paged(
        items: json.listOf('content', parse),
        page: json.integer('page'),
        size: json.integer('size'),
        totalElements: json.integer('totalElements'),
        totalPages: json.integer('totalPages'),
      );

  const Paged.empty()
      : items = const [],
        page = 0,
        size = 0,
        totalElements = 0,
        totalPages = 0;

  final List<T> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  bool get hasMore => page + 1 < totalPages;

  @override
  List<Object?> get props => [items, page, size, totalElements, totalPages];
}
