// Modelo para representar una transacción financiera
class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome; // true para ingresos, false para gastos
  final String? description;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
    this.description,
  });

  // Constructor para crear una transacción desde un Map (útil para JSON)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      isIncome: map['isIncome'] ?? false,
      description: map['description'],
    );
  }

  // Convertir la transacción a Map (útil para JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
      'description': description,
    };
  }

  // Método para copiar una transacción con algunos campos modificados
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isIncome,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, title: $title, amount: $amount, category: $category, date: $date, isIncome: $isIncome}';
  }
}
