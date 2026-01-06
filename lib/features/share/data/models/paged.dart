class Paged<T> {
  final List<T> content;
  final int page;
  final int size;
  final int? totalElements;
  final int? totalPages;

  Paged({
    required this.content,
    required this.page,
    required this.size,
    this.totalElements,
    this.totalPages,
  });
}
