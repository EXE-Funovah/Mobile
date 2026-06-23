import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/api/document_api.dart';
import '../../../data/models/document.dart';

/// Trạng thái danh sách tài liệu của user.
class DocumentsState {
  final bool loading;
  final List<DocumentDto> items;
  final String? error;

  const DocumentsState({
    this.loading = false,
    this.items = const [],
    this.error,
  });

  DocumentsState copyWith({
    bool? loading,
    List<DocumentDto>? items,
    String? error,
    bool clearError = false,
  }) => DocumentsState(
    loading: loading ?? this.loading,
    items: items ?? this.items,
    error: clearError ? null : (error ?? this.error),
  );
}

class DocumentsController extends StateNotifier<DocumentsState> {
  DocumentsController() : super(const DocumentsState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final list = await DocumentApi.instance.getMine();
      // Sắp xếp mới nhất trước
      list.sort(
        (a, b) => (b.uploadedAt ?? DateTime(1970)).compareTo(
          a.uploadedAt ?? DateTime(1970),
        ),
      );
      state = DocumentsState(items: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: _msg(e));
    }
  }

  Future<void> remove(int id) async {
    try {
      await DocumentApi.instance.delete(id);
      state = state.copyWith(
        items: state.items.where((d) => d.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: _msg(e));
    }
  }

  /// Sau khi upload xong, push doc mới lên đầu rồi refresh ngầm.
  void addOptimistic(DocumentDto doc) {
    state = state.copyWith(items: [doc, ...state.items]);
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');
}

final documentsProvider =
    StateNotifierProvider<DocumentsController, DocumentsState>(
      (ref) => DocumentsController(),
    );

/// Lấy 1 document theo id từ cache, fallback fetch.
final documentByIdProvider = FutureProvider.family<DocumentDto, int>((
  ref,
  id,
) async {
  final cached = ref
      .read(documentsProvider)
      .items
      .where((d) => d.id == id)
      .cast<DocumentDto?>()
      .firstWhere((_) => true, orElse: () => null);
  if (cached != null) return cached;
  return DocumentApi.instance.getById(id);
});
