// Modelo para representar un presupuesto
class Budget {
  final String id;
  final String categoryId;
  final String categoryName;
  final double budgetAmount; // cantidad presupuestada
  final double spentAmount; // cantidad gastada
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.budgetAmount,
    required this.spentAmount,
    required this.startDate,
    required this.endDate,
  });

  // Calcular el porcentaje gastado
  double get spentPercentage {
    if (budgetAmount <= 0) return 0.0;
    return (spentAmount / budgetAmount * 100).clamp(0.0, 100.0);
  }

  // Calcular la cantidad restante
  double get remainingAmount {
    return (budgetAmount - spentAmount).clamp(0.0, double.infinity);
  }

  // Verificar si el presupuesto está excedido
  bool get isExceeded => spentAmount > budgetAmount;

  // Verificar si el presupuesto está cerca del límite (90%)
  bool get isNearLimit => spentPercentage >= 90.0;

  // Constructor desde Map
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      budgetAmount: (map['budgetAmount'] ?? 0.0).toDouble(),
      spentAmount: (map['spentAmount'] ?? 0.0).toDouble(),
      startDate: DateTime.parse(
        map['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        map['endDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'budgetAmount': budgetAmount,
      'spentAmount': spentAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  // Método para copiar con campos modificados
  Budget copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    double? budgetAmount,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  String toString() {
    return 'Budget{id: $id, categoryName: $categoryName, budgetAmount: $budgetAmount, spentAmount: $spentAmount}';
  }
}
