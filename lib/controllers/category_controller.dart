import 'package:flutter/material.dart';
import '../models/category.dart';

/// Controlador para gestionar las categorías de transacciones.
/// Demuestra cómo los controladores pueden mantener listas de datos
/// y proporcionar métodos para manipularlas de forma centralizada.
class CategoryController extends ChangeNotifier {
  // Lista privada de categorías
  List<Category> _categories = [];

  // Estado de carga
  bool _isLoading = false;

  // Getters públicos
  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;

  // Obtener categorías de gastos
  List<Category> get expenseCategories {
    return _categories.where((category) => !category.isIncomeCategory).toList();
  }

  // Obtener categorías de ingresos
  List<Category> get incomeCategories {
    return _categories.where((category) => category.isIncomeCategory).toList();
  }

  /// Cargar categorías predeterminadas
  Future<void> loadDefaultCategories() async {
    _setLoading(true);

    try {
      // Simular carga asíncrona
      await Future.delayed(const Duration(milliseconds: 800));

      _categories = [
        // Categorías de gastos
        Category(
          id: '1',
          name: 'Alimentación',
          icon: 'restaurant',
          color: 0xFFE57373,
          isIncomeCategory: false,
        ),
        Category(
          id: '2',
          name: 'Transporte',
          icon: 'directions_car',
          color: 0xFF81C784,
          isIncomeCategory: false,
        ),
        Category(
          id: '3',
          name: 'Entretenimiento',
          icon: 'movie',
          color: 0xFF64B5F6,
          isIncomeCategory: false,
        ),
        Category(
          id: '4',
          name: 'Salud',
          icon: 'local_hospital',
          color: 0xFFFFB74D,
          isIncomeCategory: false,
        ),
        Category(
          id: '5',
          name: 'Educación',
          icon: 'school',
          color: 0xFFBA68C8,
          isIncomeCategory: false,
        ),
        Category(
          id: '6',
          name: 'Servicios',
          icon: 'build',
          color: 0xFF4DB6AC,
          isIncomeCategory: false,
        ),
        Category(
          id: '7',
          name: 'Compras',
          icon: 'shopping_cart',
          color: 0xFFF06292,
          isIncomeCategory: false,
        ),

        // Categorías de ingresos
        Category(
          id: '8',
          name: 'Trabajo',
          icon: 'work',
          color: 0xFF66BB6A,
          isIncomeCategory: true,
        ),
        Category(
          id: '9',
          name: 'Freelance',
          icon: 'computer',
          color: 0xFF42A5F5,
          isIncomeCategory: true,
        ),
        Category(
          id: '10',
          name: 'Inversiones',
          icon: 'trending_up',
          color: 0xFF26A69A,
          isIncomeCategory: true,
        ),
        Category(
          id: '11',
          name: 'Otros ingresos',
          icon: 'attach_money',
          color: 0xFF9CCC65,
          isIncomeCategory: true,
        ),
      ];

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar una nueva categoría
  Future<void> addCategory(Category category) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _categories.add(category);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener una categoría por ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener nombre de categoría por ID
  String getCategoryName(String id) {
    final category = getCategoryById(id);
    return category?.name ?? 'Sin categoría';
  }

  /// Obtener color de categoría por ID
  Color getCategoryColor(String id) {
    final category = getCategoryById(id);
    return Color(category?.color ?? 0xFF2196F3);
  }

  /// Eliminar una categoría
  Future<void> removeCategory(String id) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 200));
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar una categoría
  Future<void> updateCategory(Category updatedCategory) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 250));

      final index = _categories.indexWhere(
        (category) => category.id == updatedCategory.id,
      );

      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Método privado para manejar el estado de carga
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
