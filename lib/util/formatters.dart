import 'package:cloud_firestore/cloud_firestore.dart';

/// Formats a number as a comma-separated whole-number string.
/// e.g. 371420 -> "371,420". Does not include the currency symbol —
/// callers prepend '₦' themselves, since not every use case wants it.
String formatMoney(num value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}

/// Parses a Firestore date field that may be stored as either a
/// [Timestamp] (server-side FieldValue.serverTimestamp() writes) or an
/// ISO 8601 [String] (e.g. new Date().toISOString() writes, as used by
/// fulfillOrder in functions/index.js). Returns null if neither shape
/// matches or the value is missing.
DateTime? parseFirestoreDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is Timestamp) return raw.toDate();
  if (raw is String) return DateTime.tryParse(raw);
  return null;
}

/// Formats a [DateTime] as e.g. "1 Sep 2026, 2:58 PM".
String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $period';
}

/// Truncates an ID (Firestore doc ID / Paystack reference) to [length]
/// characters for compact display, e.g. in a list row.
String shortId(String id, {int length = 8}) =>
    id.length <= length ? id : id.substring(0, length);
