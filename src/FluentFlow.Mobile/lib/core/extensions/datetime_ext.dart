import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get ddMM => DateFormat('dd/MM').format(this);
  String get ddMMYYYY => DateFormat('dd/MM/yyyy').format(this);
  String get ddMMMYYYY => DateFormat('dd MMM yyyy', 'pt_PT').format(this);
  String get timeHHmm => DateFormat('HH:mm').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isOverdue => isBefore(DateTime.now().toUtc());

  String get relativeLabel {
    if (isToday) return 'Hoje';
    if (isOverdue) return 'Atrasado (${ddMM})';
    return ddMMYYYY;
  }
}

extension NullableDateTimeExt on DateTime? {
  String get relativeOrDash {
    if (this == null) return '—';
    return this!.relativeLabel;
  }
}
