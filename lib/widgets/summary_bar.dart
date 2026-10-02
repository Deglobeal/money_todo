import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_todo/providers/task_provider.dart';
import 'package:provider/provider.dart';

class SummaryBar extends StatelessWidget {
  const SummaryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final currencyFormat = NumberFormat.currency(symbol: '\$');
        final variance = provider.totalVariance;
        final isOver = variance > 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Estimated',
                      currencyFormat.format(provider.totalEstimated),
                      Colors.blue,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    _buildStat(
                      'Actual',
                      currencyFormat.format(provider.totalActual),
                      isOver ? Colors.red : Colors.green,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    _buildStat(
                      'Variance',
                      '${isOver ? '+' : ''}${currencyFormat.format(variance)}',
                      isOver ? Colors.red : Colors.green,
                    ),
                  ],
                ),
                if (provider.overBudgetCount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, 
                          size: 14, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.overBudgetCount} task${provider.overBudgetCount > 1 ? 's' : ''} over budget',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}