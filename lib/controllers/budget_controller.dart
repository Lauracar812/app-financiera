import 'package:flutter/material.dart';
import '../models/budget.dart';

/// Controlador para gestionar los presupuestos.
/// Demuestra cómo un controlador puede calcular datos derivados
/// y mantener el estado de múltiples entidades relacionadas.
class BudgetController extends ChangeNotifier {
  // Lista privada de presupuestos
  List<Budget> _budgets = [];

  // Estado de carga
  bool _isLoading = false;

  // Getters públicos
  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;

  // Obtener presupuestos activos (no vencidos)
  List<Budget> get activeBudgets {
    final now = DateTime.now();
    return _budgets.where((budget) => budget.endDate.isAfter(now)).toList();
  }

  // Obtener presupuestos excedidos
  List<Budget> get exceededBudgets {
    return _budgets.where((budget) => budget.isExceeded).toList();
  }

  // Obtener presupuestos cerca del límite
  List<Budget> get nearLimitBudgets {
    return _budgets
        .where((budget) => budget.isNearLimit && !budget.isExceeded)
        .toList();
  }

  // Calcular el total presupuestado
  double get totalBudgeted {
    return _budgets.fold(0.0, (total, budget) => total + budget.budgetAmount);
  }

  // Calcular el total gastado
  double get totalSpent {
    return _budgets.fold(0.0, (total, budget) => total + budget.spentAmount);
  }

  // Calcular el porcentaje total gastado
  double get totalSpentPercentage {
    if (totalBudgeted <= 0) return 0.0;
    return (totalSpent / totalBudgeted * 100).clamp(0.0, 100.0);
  }

  /// Cargar presupuestos iniciales
  Future<void> loadInitialBudgets() async {
    _setLoading(true);

    try {
      // Simular carga asíncrona
      await Future.delayed(const Duration(milliseconds: 600));

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      _budgets = [
        Budget(
          id: '1',
          categoryId: '1',
          categoryName: 'Alimentación',
          budgetAmount: 400.0,
          spentAmount: 325.50,
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
        Budget(
          id: '2',
          categoryId: '2',
          categoryName: 'Transporte',
          budgetAmount: 200.0,
          spentAmount: 145.0,
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
        Budget(
          id: '3',
          categoryId: '3',
          categoryName: 'Entretenimiento',
          budgetAmount: 150.0,
          spentAmount: 180.0, // Excedido
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
        Budget(
          id: '4',
          categoryId: '7',
          categoryName: 'Compras',
          budgetAmount: 300.0,
          spentAmount: 275.0, // Cerca del límite
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
      ];

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar un nuevo presupuesto
  Future<void> addBudget(Budget budget) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _budgets.add(budget);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar el gasto de un presupuesto
  /// Este método demuestra cómo el controlador puede actualizar
  /// datos específicos y recalcular estados derivados
  Future<void> updateBudgetSpent(String budgetId, double newSpentAmount) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final index = _budgets.indexWhere((budget) => budget.id == budgetId);
      if (index != -1) {
        _budgets[index] = _budgets[index].copyWith(spentAmount: newSpentAmount);
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar un presupuesto completo
  Future<void> updateBudget(Budget updatedBudget) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _budgets.indexWhere(
        (budget) => budget.id == updatedBudget.id,
      );
      if (index != -1) {
        _budgets[index] = updatedBudget;
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar un presupuesto
  Future<void> removeBudget(String budgetId) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 250));
      _budgets.removeWhere((budget) => budget.id == budgetId);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener un presupuesto por ID
  Budget? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener presupuesto por categoría
  Budget? getBudgetByCategory(String categoryId) {
    try {
      return _budgets.firstWhere((budget) => budget.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Agregar gasto a un presupuesto específico
  /// Este método demuestra cómo los controladores pueden proporcionar
  /// métodos de conveniencia para operaciones comunes
  Future<void> addExpenseToBudget(String categoryId, double amount) async {
    final budget = getBudgetByCategory(categoryId);
    if (budget != null) {
      final newSpentAmount = budget.spentAmount + amount;
      await updateBudgetSpent(budget.id, newSpentAmount);
    }
  }

  /// Restar gasto de un presupuesto (por si se elimina una transacción)
  Future<void> removeExpenseFromBudget(String categoryId, double amount) async {
    final budget = getBudgetByCategory(categoryId);
    if (budget != null) {
      final newSpentAmount = (budget.spentAmount - amount).clamp(
        0.0,
        double.infinity,
      );
      await updateBudgetSpent(budget.id, newSpentAmount);
    }
  }

  /// Obtener resumen de alertas de presupuesto
  Map<String, int> get budgetAlerts {
    return {
      'exceeded': exceededBudgets.length,
      'nearLimit': nearLimitBudgets.length,
      'healthy':
          activeBudgets.length -
          exceededBudgets.length -
          nearLimitBudgets.length,
    };
  }

  // Método privado para manejar el estado de carga
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
