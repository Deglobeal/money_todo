class Money {
  final String currency;
  final double? estimated;
  final double? actual;
  final bool isExpense;

  const Money({
    this.currency = 'USD',
    this.estimated,
    this.actual,
    this.isExpense = true,
  });

  double get displayEstimated => estimated ?? 0.0;
  double get displayActual => actual ?? 0.0;
  
  double? get variance {
    if (actual == null || estimated == null) return null;
    return actual! - estimated!;
  }

  bool get isOverBudget {
    if (actual == null || estimated == null) return false;
    return actual! > estimated!;
  }

  bool get isUnderBudget {
    if (actual == null || estimated == null) return false;
    return actual! < estimated!;
  }

  double get budgetPercent {
    if (actual == null || estimated == null || estimated == 0) return 0;
    return ((actual! - estimated!) / estimated!) * 100;
  }

  Money copyWith({
    String? currency,
    double? estimated,
    double? actual,
    bool? isExpense,
  }) {
    return Money(
      currency: currency ?? this.currency,
      estimated: estimated ?? this.estimated,
      actual: actual ?? this.actual,
      isExpense: isExpense ?? this.isExpense,
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'estimated': estimated,
        'actual': actual,
        'isExpense': isExpense,
      };

  factory Money.fromJson(Map<String, dynamic> json) => Money(
        currency: json['currency'] ?? 'USD',
        estimated: json['estimated']?.toDouble(),
        actual: json['actual']?.toDouble(),
        isExpense: json['isExpense'] ?? true,
      );
}