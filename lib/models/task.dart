import 'package:flutter/material.dart';
import 'package:money_todo/models/money.dart';
import 'package:money_todo/models/recurrence.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final DateTime? date;
  final TimeOfDay? time;
  final bool completed;
  final int priority;
  final String note;
  final bool noteChecked;
  final Money money;
  final String? categoryId;
  final RecurrenceRule? recurrence;
  final String? parentTaskId; // if this was generated from a recurring task
  final int recurrenceCount; // how many times this recurring task has fired
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    this.date,
    this.time,
    this.completed = false,
    this.priority = 1,
    this.note = '',
    this.noteChecked = false,
    Money? money,
    this.categoryId,
    this.recurrence,
    this.parentTaskId,
    this.recurrenceCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        money = money ?? const Money(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Color get priorityColor {
    switch (priority) {
      case 0: return Colors.green;
      case 1: return Colors.orange;
      case 2: return Colors.red;
      default: return Colors.grey;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 0: return 'Low';
      case 1: return 'Medium';
      case 2: return 'High';
      default: return 'None';
    }
  }

  bool get hasMoneyData => money.estimated != null || money.actual != null;
  bool get isRecurring => recurrence != null;
  bool get isGenerated => parentTaskId != null;

  Task copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? time,
    bool? completed,
    int? priority,
    String? note,
    bool? noteChecked,
    Money? money,
    String? categoryId,
    RecurrenceRule? recurrence,
    String? parentTaskId,
    int? recurrenceCount,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      note: note ?? this.note,
      noteChecked: noteChecked ?? this.noteChecked,
      money: money ?? this.money,
      categoryId: categoryId ?? this.categoryId,
      recurrence: recurrence ?? this.recurrence,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      recurrenceCount: recurrenceCount ?? this.recurrenceCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date?.toIso8601String(),
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'completed': completed,
      'priority': priority,
      'note': note,
      'noteChecked': noteChecked,
      'money': money.toJson(),
      'categoryId': categoryId,
      'recurrence': recurrence?.toJson(),
      'parentTaskId': parentTaskId,
      'recurrenceCount': recurrenceCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parsedTime;
    if (json['time'] != null) {
      final parts = json['time'].split(':');
      parsedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Task(
      id: json['id'],
      title: json['title'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: parsedTime,
      completed: json['completed'] ?? false,
      priority: json['priority'] ?? 1,
      note: json['note'] ?? '',
      noteChecked: json['noteChecked'] ?? false,
      money: json['money'] != null ? Money.fromJson(json['money']) : null,
      categoryId: json['categoryId'],
      recurrence: json['recurrence'] != null ? RecurrenceRule.fromJson(json['recurrence']) : null,
      parentTaskId: json['parentTaskId'],
      recurrenceCount: json['recurrenceCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}