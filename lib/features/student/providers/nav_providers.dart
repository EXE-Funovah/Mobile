import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/student_bottom_nav.dart';

/// Tab con đang chọn trong màn Thư viện: 'docs' | 'quiz' | 'flash'.
/// Controlled từ ngoài để sau khi xuất bản flashcard có thể mở đúng tab.
final libraryTabProvider = StateProvider<String>((_) => 'docs');

/// Yêu cầu chuyển tab dưới cùng của StudentShell (vd. về Library sau publish).
/// StudentShell lắng nghe, chuyển tab rồi tự set lại null.
final studentTabRequestProvider = StateProvider<NavTab?>((_) => null);
