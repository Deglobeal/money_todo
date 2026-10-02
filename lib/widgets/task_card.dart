import 'package:flutter/material.dart';
import 'package:money_todo/models/task.dart';
import 'package:money_todo/providers/task_provider.dart';
import 'package:money_todo/screens/task_form_screen.dart';
import 'package:money_todo/widgets/money_badge.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final category = context.read<TaskProvider>().getCategoryById(task.categoryId);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        elevation: task.completed ? 0 : 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: task.priorityColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Checkbox(
                    value: task.completed,
                    onChanged: (_) => onToggle(),
                    activeColor: task.priorityColor,
                  ),
                ),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with category & recurrence
                      Row(
                        children: [
                          if (task.isRecurring) ...[
                            Icon(Icons.repeat, size: 14, color: Colors.indigo[400]),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: task.completed ? TextDecoration.lineThrough : null,
                                color: task.completed ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Category chip
                      if (category != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(category.iconData, size: 12, color: category.color),
                              const SizedBox(width: 4),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: category.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Date/time
                      if (task.date != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              [
                                dateFormat.format(task.date!),
                                if (task.time != null) task.time!.format(context),
                              ].join(' · '),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                      
                      // Note
                      if (task.note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.notes, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                task.note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  decoration: task.noteChecked ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            if (task.noteChecked)
                              const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Money badge & priority
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: task.priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (task.hasMoneyData)
                      MoneyBadge(money: task.money, compact: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}