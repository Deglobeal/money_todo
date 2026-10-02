import 'package:flutter/material.dart';
import 'package:money_todo/models/task.dart';
import 'package:money_todo/providers/task_provider.dart';
import 'package:money_todo/screens/task_form_screen.dart';
import 'package:money_todo/widgets/summary_bar.dart';
import 'package:money_todo/widgets/task_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Todo'),
        elevation: 0,
        actions: [
          _FilterDropdown(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: context.read<TaskProvider>().tasksStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data ?? [];
                
                // Update provider's local cache for calculations
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.read<TaskProvider>()._tasks = tasks;
                  }
                });

                if (tasks.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Tap + to add a task with money tracking',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return Consumer<TaskProvider>(
                  builder: (context, provider, _) {
                    final displayTasks = provider.filteredTasks;
                    
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: displayTasks.length,
                      itemBuilder: (context, index) {
                        final task = displayTasks[index];
                        return TaskCard(
                          task: task,
                          onToggle: () => provider.toggleComplete(task),
                          onDelete: () => provider.deleteTask(task.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SummaryBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return PopupMenuButton<String>(
          initialValue: provider.filter,
          onSelected: provider.setFilter,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'all', child: Text('All Tasks')),
            const PopupMenuItem(value: 'pending', child: Text('Pending')),
            const PopupMenuItem(value: 'completed', child: Text('Completed')),
            const PopupMenuItem(value: 'overBudget', child: Text('Over Budget')),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  provider.filter.toUpperCase(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}