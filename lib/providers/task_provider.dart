import 'package:flutter/material.dart';
import 'package:money_todo/models/category.dart';
import 'package:money_todo/models/recurrence.dart';
import 'package:money_todo/models/task.dart';
import 'package:money_todo/services/firebase_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService.instance;
  
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  
  List<TaskCategory> _categories = [];
  List<TaskCategory> get categories => _categories;

  String _filter = 'all';
  String get filter => _filter;
  
  String? _categoryFilter;
  String? get categoryFilter => _categoryFilter;

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _categoryFilter = categoryId;
    notifyListeners();
  }

  List<Task> get filteredTasks {
    var result = _tasks;
    
    // Status filter
    switch (_filter) {
      case 'pending':
        result = result.where((t) => !t.completed).toList();
        break;
      case 'completed':
        result = result.where((t) => t.completed).toList();
        break;
      case 'overBudget':
        result = result.where((t) => t.money.isOverBudget).toList();
        break;
      case 'recurring':
        result = result.where((t) => t.isRecurring).toList();
        break;
    }
    
    // Category filter
    if (_categoryFilter != null) {
      result = result.where((t) => t.categoryId == _categoryFilter).toList();
    }
    
    return result;
  }

  TaskCategory? getCategoryById(String? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Summaries by category
  Map<String, double> get actualByCategory {
    final map = <String, double>{};
    for (var task in _tasks.where((t) => t.money.actual != null && t.categoryId != null)) {
      map[task.categoryId!] = (map[task.categoryId!] ?? 0) + task.money.actual!;
    }
    return map;
  }

  double get totalEstimated => _tasks.fold(0.0, (sum, t) => sum + (t.money.estimated ?? 0));
  double get totalActual => _tasks.fold(0.0, (sum, t) => sum + (t.money.actual ?? 0));
  double get totalVariance => totalActual - totalEstimated;
  int get overBudgetCount => _tasks.where((t) => t.money.isOverBudget).length;

  // Recurring task logic
  Future<void> toggleComplete(Task task) async {
    final nowCompleted = !task.completed;
    final updated = task.copyWith(completed: nowCompleted);
    await _firebase.updateTask(updated);

    // If completing a recurring task, generate next instance
    if (nowCompleted && task.isRecurring && task.date != null) {
      final nextDate = task.recurrence!.getNextDate(task.date!);
      if (nextDate != null && task.recurrence!.shouldContinue(nextDate, task.recurrenceCount + 1)) {
        final nextTask = Task(
          title: task.title,
          date: nextDate,
          time: task.time,
          priority: task.priority,
          note: task.note,
          money: task.money.copyWith(actual: null), // reset actual for new instance
          categoryId: task.categoryId,
          recurrence: task.recurrence,
          parentTaskId: task.parentTaskId ?? task.id,
          recurrenceCount: task.recurrenceCount + 1,
        );
        await _firebase.addTask(nextTask);
      }
    }
  }

  Future<void> addTask(Task task) async => await _firebase.addTask(task);
  Future<void> updateTask(Task task) async => await _firebase.updateTask(task);
  Future<void> deleteTask(String taskId) async => await _firebase.deleteTask(taskId);

  // Categories
  Future<void> addCategory(TaskCategory category) async => await _firebase.addCategory(category);
  Future<void> updateCategory(TaskCategory category) async => await _firebase.updateCategory(category);
  Future<void> deleteCategory(String categoryId) async => await _firebase.deleteCategory(categoryId);
}