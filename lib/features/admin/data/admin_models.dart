// Models khớp DTO backend (`/api/Admin/*`). JSON camelCase (System.Text.Json).

double _toD(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _toI(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

class AdminKpi {
  final String key;
  final String label;
  final double value;
  final String format; // int | currency | percent
  final double deltaPercent;
  final bool up;

  AdminKpi({
    required this.key,
    required this.label,
    required this.value,
    required this.format,
    required this.deltaPercent,
    required this.up,
  });

  factory AdminKpi.fromJson(Map j) => AdminKpi(
    key: '${j['key'] ?? ''}',
    label: '${j['label'] ?? ''}',
    value: _toD(j['value']),
    format: '${j['format'] ?? 'int'}',
    deltaPercent: _toD(j['deltaPercent']),
    up: j['up'] == true,
  );
}

class NamedValue {
  final String label;
  final num value;
  final String? color;
  NamedValue({required this.label, required this.value, this.color});
  factory NamedValue.fromJson(Map j) => NamedValue(
    label: '${j['label'] ?? ''}',
    value: _toD(j['value']),
    color: j['color']?.toString(),
  );
}

class MonthPoint {
  final String label;
  final num value;
  MonthPoint({required this.label, required this.value});
  factory MonthPoint.fromJson(Map j) =>
      MonthPoint(label: '${j['label'] ?? ''}', value: _toD(j['value']));
}

class AdminOverview {
  final List<AdminKpi> kpis;
  final List<MonthPoint> mrrSeries;
  final List<NamedValue> featureUsage;
  AdminOverview({
    required this.kpis,
    required this.mrrSeries,
    required this.featureUsage,
  });
  factory AdminOverview.fromJson(Map j) => AdminOverview(
    kpis: (j['kpis'] as List? ?? []).map((e) => AdminKpi.fromJson(e)).toList(),
    mrrSeries: (j['mrrSeries'] as List? ?? [])
        .map((e) => MonthPoint.fromJson(e))
        .toList(),
    featureUsage: (j['featureUsage'] as List? ?? [])
        .map((e) => NamedValue.fromJson(e))
        .toList(),
  );
}

class AdminRevenue {
  final num mrr;
  final num arr;
  final num arpu;
  final double? churnRate;
  final num? ltv;
  final List<MonthPoint> mrrSeries;
  final List<NamedValue> planDistribution;
  final List<NamedValue> funnel;
  final List<NamedValue> movement;
  AdminRevenue({
    required this.mrr,
    required this.arr,
    required this.arpu,
    required this.churnRate,
    required this.ltv,
    required this.mrrSeries,
    required this.planDistribution,
    required this.funnel,
    required this.movement,
  });
  factory AdminRevenue.fromJson(Map j) => AdminRevenue(
    mrr: _toD(j['mrr']),
    arr: _toD(j['arr']),
    arpu: _toD(j['arpu']),
    churnRate: j['churnRate'] == null ? null : _toD(j['churnRate']),
    ltv: j['ltv'] == null ? null : _toD(j['ltv']),
    mrrSeries: (j['mrrSeries'] as List? ?? [])
        .map((e) => MonthPoint.fromJson(e))
        .toList(),
    planDistribution: (j['planDistribution'] as List? ?? [])
        .map((e) => NamedValue.fromJson(e))
        .toList(),
    funnel: (j['funnel'] as List? ?? [])
        .map((e) => NamedValue.fromJson(e))
        .toList(),
    movement: (j['movement'] as List? ?? [])
        .map((e) => NamedValue.fromJson(e))
        .toList(),
  );
}

class AdminAccount {
  final int id;
  final String name;
  final String email;
  final String type;
  final String plan;
  final bool premiumActive;
  final int questions;
  final int minutes;
  final String status; // on | idle | trial
  final String? lastActive;
  AdminAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.plan,
    required this.premiumActive,
    required this.questions,
    required this.minutes,
    required this.status,
    required this.lastActive,
  });
  factory AdminAccount.fromJson(Map j) => AdminAccount(
    id: _toI(j['id']),
    name: '${j['name'] ?? ''}',
    email: '${j['email'] ?? ''}',
    type: '${j['type'] ?? ''}',
    plan: '${j['plan'] ?? ''}',
    premiumActive: j['premiumActive'] == true,
    questions: _toI(j['questions']),
    minutes: _toI(j['minutes']),
    status: '${j['status'] ?? 'idle'}',
    lastActive: j['lastActive']?.toString(),
  );
}

class AdminAccounts {
  final int totalAccounts;
  final int payingAccounts;
  final int total;
  final List<AdminAccount> items;
  AdminAccounts({
    required this.totalAccounts,
    required this.payingAccounts,
    required this.total,
    required this.items,
  });
  factory AdminAccounts.fromJson(Map j) => AdminAccounts(
    totalAccounts: _toI(j['totalAccounts']),
    payingAccounts: _toI(j['payingAccounts']),
    total: _toI(j['total']),
    items: (j['items'] as List? ?? [])
        .map((e) => AdminAccount.fromJson(e))
        .toList(),
  );
}
