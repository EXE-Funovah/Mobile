/// Mock data — sẽ thay bằng API call sau.

class DocItem {
  final String title;
  final String meta;
  final int pages;
  final int questions;
  final int tint;
  final String icon; // material name
  DocItem({
    required this.title,
    required this.meta,
    required this.pages,
    required this.questions,
    required this.tint,
    required this.icon,
  });
}

class QuizItem {
  final String title;
  final int total;
  final int done;
  final int tint;
  QuizItem({
    required this.title,
    required this.total,
    required this.done,
    required this.tint,
  });
}

class QuizQ {
  final String q;
  final List<String> opts;
  final int correct;
  final int lv;
  const QuizQ({
    required this.q,
    required this.opts,
    required this.correct,
    required this.lv,
  });
}

const activeDoc = (
  title: 'Sinh học 10 — Tế bào',
  meta: '14 trang · Sinh học',
  pages: 14,
  summary: [
    'Tế bào là đơn vị cấu trúc và chức năng cơ bản của mọi sinh vật sống.',
    'Các bào quan chính: nhân, ti thể, ribosome, màng và tế bào chất.',
    'Nguyên phân giúp tế bào sinh sản tạo hai tế bào con giống hệt nhau.',
  ],
);

final mockQuizQs = <QuizQ>[
  const QuizQ(
    q: 'Đơn vị cấu trúc và chức năng cơ bản của sự sống là gì?',
    opts: ['Tế bào', 'Mô', 'Cơ quan', 'Phân tử'],
    correct: 0,
    lv: 1,
  ),
  const QuizQ(
    q: 'Bào quan nào được gọi là "nhà máy năng lượng" của tế bào?',
    opts: ['Nhân', 'Ti thể', 'Ribosome', 'Lục lạp'],
    correct: 1,
    lv: 1,
  ),
  const QuizQ(
    q: 'Thành phần nào điều khiển mọi hoạt động của tế bào?',
    opts: ['Màng tế bào', 'Tế bào chất', 'Nhân', 'Không bào'],
    correct: 2,
    lv: 2,
  ),
  const QuizQ(
    q: 'Quá trình một tế bào phân chia thành hai tế bào con giống hệt gọi là?',
    opts: ['Giảm phân', 'Thụ tinh', 'Hô hấp', 'Nguyên phân'],
    correct: 3,
    lv: 2,
  ),
  const QuizQ(
    q: 'Ribosome trong tế bào có chức năng chính là gì?',
    opts: [
      'Tổng hợp protein',
      'Quang hợp',
      'Tiêu hóa nội bào',
      'Vận chuyển nước',
    ],
    correct: 0,
    lv: 3,
  ),
];

final mockDocs = <DocItem>[
  DocItem(
    title: 'Sinh học 10 — Tế bào',
    meta: '14 trang',
    pages: 14,
    questions: 24,
    tint: 0,
    icon: 'doc',
  ),
  DocItem(
    title: 'Lịch sử — Cách mạng tháng 8',
    meta: '9 trang',
    pages: 9,
    questions: 18,
    tint: 2,
    icon: 'doc',
  ),
  DocItem(
    title: 'Hóa học — Bảng tuần hoàn',
    meta: '21 trang',
    pages: 21,
    questions: 0,
    tint: 1,
    icon: 'doc',
  ),
  DocItem(
    title: 'Tiếng Anh — Unit 5 Vocabulary',
    meta: '6 trang',
    pages: 6,
    questions: 12,
    tint: 3,
    icon: 'globe',
  ),
];

final mockQuizzes = <QuizItem>[
  QuizItem(title: 'Tế bào & cấu trúc', total: 24, done: 18, tint: 0),
  QuizItem(title: 'Cách mạng tháng 8', total: 18, done: 18, tint: 2),
  QuizItem(title: 'Unit 5 — Từ vựng', total: 12, done: 4, tint: 3),
];
