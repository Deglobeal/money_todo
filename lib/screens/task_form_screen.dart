import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_todo/models/money.dart';
import 'package:money_todo/models/task.dart';
import 'package:money_todo/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:money_todo/models/category.dart';
import 'package:money_todo/models/recurrence.dart';
import 'package:money_todo/screens/categories_screen.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _estimatedController = TextEditingController();
  final _actualController = TextEditingController();

  late bool _completed;
  late int _priority;
  late bool _noteChecked;
  DateTime? _date;
  TimeOfDay? _time;
  String _currency = 'USD';
  bool _isExpense = true;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'CNY', 'JPY'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _noteController.text = widget.task!.note;
      _completed = widget.task!.completed;
      _priority = widget.task!.priority;
      _noteChecked = widget.task!.noteChecked;
      _date = widget.task!.date;
      _time = widget.task!.time;
      _currency = widget.task!.money.currency;
      _isExpense = widget.task!.money.isExpense;
      _categoryId = widget.task?.categoryId;
      _recurrence = widget.task?.recurrence;
      
      if (widget.task!.money.estimated != null) {
        _estimatedController.text = widget.task!.money.estimated.toString();
      }
      if (widget.task!.money.actual != null) {
        _actualController.text = widget.task!.money.actual.toString();
      }
    } else {
      _completed = false;
      _priority = 1;
      _noteChecked = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _estimatedController.dispose();
    _actualController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final money = Money(
      currency: _currency,
      estimated: _estimatedController.text.isEmpty 
          ? null 
          : double.parse(_estimatedController.text),
      actual: _actualController.text.isEmpty 
          ? null 
          : double.parse(_actualController.text),
      isExpense: _isExpense,
    );

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      date: _date,
      time: _time,
      completed: _completed,
      priority: _priority,
      note: _noteController.text.trim(),
      noteChecked: _noteChecked,
      money: money,
    );

    final provider = context.read<TaskProvider>();
    if (widget.task == null) {
      provider.addTask(task);
    } else {
      provider.updateTask(task);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Task?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<TaskProvider>().deleteTask(widget.task!.id);
                          Navigator.pop(context); // dialog
                          Navigator.pop(context); // screen
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          TextButton(
            onPressed: _save,
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              
              const SizedBox(height: 20),
              
              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_date == null 
                          ? 'Pick Date' 
                          : DateFormat('MMM dd, yyyy').format(_date!)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_time == null 
                          ? 'Pick Time' 
                          : _time!.format(context)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Priority
              const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PriorityChip(
                    label: 'Low',
                    color: Colors.green,
                    selected: _priority == 0,
                    onTap: () => setState(() => _priority = 0),
                  ),
                  const SizedBox(width: 12),
                  _PriorityChip(
                    label: 'Medium',
                    color: Colors.orange,
                    selected: _priority == 1,
                    onTap: () => setState(() => _priority = 1),
                  ),
                  const SizedBox(width: 12),
                  _PriorityChip(
                    label: 'High',
                    color: Colors.red,
                    selected: _priority == 2,
                    onTap: () => setState(() => _priority = 2),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Note
              Row(
                children: [
                  Checkbox(
                    value: _noteChecked,
                    onChanged: (v) => setState(() => _noteChecked = v ?? false),
                  ),
                  const Text('Note checked'),
                ],
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note / Subtask',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 24),
              
              // Money Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Money Tracking',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        // Expense/Income toggle
                        ChoiceChip(
                          label: const Text('Expense'),
                          selected: _isExpense,
                          onSelected: (v) => setState(() => _isExpense = true),
                          selectedColor: Colors.red[100],
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Income'),
                          selected: !_isExpense,
                          onSelected: (v) => setState(() => _isExpense = false),
                          selectedColor: Colors.green[100],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Currency
                    DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: _currencies.map((c) => 
                        DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Estimated & Actual
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _estimatedController,
                            decoration: const InputDecoration(
                              labelText: 'Estimated',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _actualController,
                            decoration: const InputDecoration(
                              labelText: 'Actual',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Budget preview
                    if (_estimatedController.text.isNotEmpty && 
                        _actualController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildBudgetPreview(),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Completed toggle
              if (isEditing)
                SwitchListTile(
                  title: const Text('Mark as completed'),
                  value: _completed,
                  onChanged: (v) => setState(() => _completed = v),
                ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetPreview() {
    final est = double.tryParse(_estimatedController.text) ?? 0;
    final act = double.tryParse(_actualController.text) ?? 0;
    final diff = act - est;
    final percent = est > 0 ? (diff / est) * 100 : 0;
    
    Color color = Colors.green;
    String message = 'On budget';
    
    if (diff > 0) {
      color = percent >= 20 ? Colors.red : Colors.orange;
      message = '${percent.toStringAsFixed(0)}% over budget';
    } else if (diff < 0) {
      message = '${percent.abs().toStringAsFixed(0)}% under budget';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey[400]!,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : Colors.grey[700],
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}