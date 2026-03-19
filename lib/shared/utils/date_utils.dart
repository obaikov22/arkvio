import 'package:flutter/material.dart';

enum DeadlineUrgency { none, urgent, soon, later }

DeadlineUrgency getDeadlineUrgency(DateTime? deadline) {
  if (deadline == null) return DeadlineUrgency.none;
  final now = DateTime.now();
  final diff = deadline.difference(now).inDays;
  if (diff < 0) return DeadlineUrgency.urgent;
  if (diff <= 14) return DeadlineUrgency.urgent;
  if (diff <= 30) return DeadlineUrgency.soon;
  return DeadlineUrgency.later;
}

Color deadlineColor(DateTime? deadline, BuildContext context) {
  final urgency = getDeadlineUrgency(deadline);
  switch (urgency) {
    case DeadlineUrgency.urgent:
      return Colors.red;
    case DeadlineUrgency.soon:
      return Colors.orange;
    case DeadlineUrgency.later:
      return Colors.grey;
    case DeadlineUrgency.none:
      return Colors.green;
  }
}

const _monthsRu = [
  'янв', 'фев', 'мар', 'апр', 'май', 'июн',
  'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
];

String formatDeadlineShort(DateTime deadline) {
  return 'До ${deadline.day} ${_monthsRu[deadline.month - 1]}';
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
