import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TaskCategory {
  final String id;
  final String name;
  final int colorValue;
  final String iconName;

  TaskCategory({
    String? id,
    required this.name,
    required this.colorValue,
    this.iconName = 'label',
  }) : id = id ?? const Uuid().v4();

  Color get color => Color(colorValue);

  IconData get iconData {
    switch (iconName) {
      case 'shopping': return Icons.shopping_bag;
      case 'work': return Icons.work;
      case 'home': return Icons.home;
      case 'health': return Icons.favorite;
      case 'finance': return Icons.account_balance_wallet;
      case 'travel': return Icons.flight;
      case 'food': return Icons.restaurant;
      case 'education': return Icons.school;
      default: return Icons.label;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'iconName': iconName,
      };

  factory TaskCategory.fromJson(Map<String, dynamic> json) => TaskCategory(
        id: json['id'],
        name: json['name'],
        colorValue: json['colorValue'],
        iconName: json['iconName'] ?? 'label',
      );

  TaskCategory copyWith({String? name, int? colorValue, String? iconName}) {
    return TaskCategory(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
    );
  }
}