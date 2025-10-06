import 'package:flutter/material.dart';
import '../models/transaction.dart';

/// ControllerControlador para gestionar el estado de las transacciones financieras.
/// Este controlador demuestra cómo administrar el estado en Flutter usando controladores
/// en lugar de variables locales en los widgets.
class TransactionController extends ChangeNotifier {
  // Lista privada de transacciones
  List<Transaction> _transactions = [];

  // Variable para controlar el estado de carga
  bool _isLoading = false;

  // Variable para manejar mensajes de error
  String? _errorMessage;

  // Getters públicos para acceder a los datos desde los widgets
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter para obtener el balance total
  double get totalBalance {
    double balance = 0.0;
    for (var transaction in _transactions) {
      if (transaction.isIncome) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  // Getter para obtener el total de ingresos
  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.isIncome)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  // Getter para obtener el total de gastos
  double get totalExpenses {
    return _transactions
        .where((transaction) => !transaction.isIncome)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  // Getter para obtener transacciones por categoría
  Map<String, List<Transaction>> get transactionsByCategory {
    Map<String, List<Transaction>> grouped = {};
    for (var transaction in _transactions) {
      if (!grouped.containsKey(transaction.category)) {
        grouped[transaction.category] = [];
      }
      grouped[transaction.category]!.add(transaction);
    }
    return grouped;
  }

  /// Agregar una nueva transacción
  /// Este método demuestra cómo el controlador mantiene el estado
  /// y notifica a los widgets cuando hay cambios
  Future<void> addTransaction(Transaction transaction) async {
    _setLoading(true);
    _clearError();

    try {
      // Simular una operación asíncrona (como guardar en base de datos)
      await Future.delayed(const Duration(milliseconds: 500));

      _transactions.add(transaction);

      // Ordenar transacciones por fecha (más recientes primero)
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      // Notificar a todos los widgets que escuchan este controlador
      notifyListeners();
    } catch (e) {
      _setError('Error al agregar la transacción: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar una transacción por ID
  Future<void> removeTransaction(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _transactions.removeWhere((transaction) => transaction.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar la transacción: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar una transacción existente
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final index = _transactions.indexWhere(
        (transaction) => transaction.id == updatedTransaction.id,
      );

      if (index != -1) {
        _transactions[index] = updatedTransaction;
        _transactions.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      } else {
        throw Exception('Transacción no encontrada');
      }
    } catch (e) {
      _setError('Error al actualizar la transacción: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener transacciones filtradas por categoría
  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions
        .where((transaction) => transaction.category == category)
        .toList();
  }

  /// Obtener transacciones de un rango de fechas
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(
            start.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Obtener transacciones del mes actual
  List<Transaction> getCurrentMonthTransactions() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(firstDay, lastDay);
  }

  /// Cargar transacciones iniciales (simula cargar desde una base de datos)
  Future<void> loadInitialTransactions() async {
    _setLoading(true);
    _clearError();

    try {
      // Simular carga desde base de datos
      await Future.delayed(const Duration(seconds: 1));

      // Agregar algunas transacciones de ejemplo
      _transactions = [
        Transaction(
          id: '1',
          title: 'Salario',
          amount: 2500.00,
          category: 'Trabajo',
          date: DateTime.now().subtract(const Duration(days: 1)),
          isIncome: true,
          description: 'Salario mensual',
        ),
        Transaction(
          id: '2',
          title: 'Supermercado',
          amount: 120.50,
          category: 'Alimentación',
          date: DateTime.now().subtract(const Duration(days: 2)),
          isIncome: false,
          description: 'Compras semanales',
        ),
        Transaction(
          id: '3',
          title: 'Gasolina',
          amount: 45.00,
          category: 'Transporte',
          date: DateTime.now().subtract(const Duration(days: 3)),
          isIncome: false,
          description: 'Combustible auto',
        ),
      ];

      notifyListeners();
    } catch (e) {
      _setError('Error al cargar las transacciones: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpiar todas las transacciones
  void clearAllTransactions() {
    _transactions.clear();
    notifyListeners();
  }

  // Métodos privados para manejar el estado interno
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Limpiar errores manualmente
  void clearError() {
    _clearError();
  }
}
