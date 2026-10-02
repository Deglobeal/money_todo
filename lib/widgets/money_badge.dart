import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_todo/models/money.dart';

class MoneyBadge extends StatelessWidget {
  final Money money;
  final bool compact;

  const MoneyBadge({
    super.key,
    required this.money,
    this.compact = false,
  });

  Color get _statusColor {
    if (money.actual == null || money.estimated == null) return Colors.grey;
    if (money.isOverBudget) {
      if (money.budgetPercent >= 20) return Colors.red;
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _statusColor.withOpacity(0.3)),
        ),
        child: Text(
          money.actual != null
              ? currencyFormat.format(money.actual)
              : (money.estimated != null 
                  ? '${currencyFormat.format(money.estimated)} est'
                  : 'No cost'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _statusColor,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (money.estimated != null)
          Text(
            'Est: ${currencyFormat.format(money.estimated)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        if (money.actual != null)
          Text(
            'Act: ${currencyFormat.format(money.actual)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _statusColor,
            ),
          ),
        if (money.isOverBudget)
          Text(
            '+${money.budgetPercent.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}