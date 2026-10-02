enum RecurrenceFrequency { daily, weekly, monthly, yearly }

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval; // every N days/weeks/months/years
  final DateTime? endDate;
  final int? maxOccurrences;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.endDate,
    this.maxOccurrences,
  });

  String get label {
    final freq = frequency.name;
    if (interval == 1) return 'Every ${freq.replaceFirst(freq[0], freq[0].toUpperCase())}';
    return 'Every $interval ${freq}s';
  }

  DateTime? getNextDate(DateTime from) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return from.add(Duration(days: interval));
      case RecurrenceFrequency.weekly:
        return from.add(Duration(days: 7 * interval));
      case RecurrenceFrequency.monthly:
        return DateTime(from.year, from.month + interval, from.day);
      case RecurrenceFrequency.yearly:
        return DateTime(from.year + interval, from.month, from.day);
    }
  }

  bool shouldContinue(DateTime nextDate, int occurrenceCount) {
    if (endDate != null && nextDate.isAfter(endDate!)) return false;
    if (maxOccurrences != null && occurrenceCount >= maxOccurrences!) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency.name,
        'interval': interval,
        'endDate': endDate?.toIso8601String(),
        'maxOccurrences': maxOccurrences,
      };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) => RecurrenceRule(
        frequency: RecurrenceFrequency.values.byName(json['frequency']),
        interval: json['interval'] ?? 1,
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        maxOccurrences: json['maxOccurrences'],
      );
}