import 'package:flutter/material.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/budget_controller.dart';
import 'views/home_view.dart';

/// Aplicación Financiera que demuestra el uso de controladores para la administración del estado.
///
/// Esta aplicación muestra cómo los controladores pueden:
/// 1. Mantener el estado de la aplicación de forma centralizada
/// 2. Proporcionar métodos para manipular ese estado
/// 3. Notificar a los widgets cuando el estado cambia
/// 4. Coordinar operaciones entre diferentes tipos de datos
void main() {
  runApp(const FinancialApp());
}

class FinancialApp extends StatelessWidget {
  const FinancialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Financiera - Control de Estado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Tema moderno con colores vibrantes y profesionales
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Índigo moderno
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF1E293B),
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 8,
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const FinancialAppHome(),
    );
  }
}

/// Widget principal que inicializa y mantiene los controladores.
/// Este patrón demuestra cómo crear controladores una sola vez
/// y pasarlos a través de la jerarquía de widgets.
class FinancialAppHome extends StatefulWidget {
  const FinancialAppHome({super.key});

  @override
  State<FinancialAppHome> createState() => _FinancialAppHomeState();
}

class _FinancialAppHomeState extends State<FinancialAppHome> {
  // Instancias de los controladores - creados una sola vez
  // y mantenidos durante toda la vida de la aplicación
  late final TransactionController _transactionController;
  late final CategoryController _categoryController;
  late final BudgetController _budgetController;

  @override
  void initState() {
    super.initState();

    // Inicializar los controladores
    // Esto demuestra cómo crear instancias de controladores
    // que mantendrán el estado durante toda la sesión de la app
    _transactionController = TransactionController();
    _categoryController = CategoryController();
    _budgetController = BudgetController();

    // Cargar datos iniciales
    _loadInitialData();
  }

  /// Carga los datos iniciales de la aplicación
  Future<void> _loadInitialData() async {
    await _categoryController.loadDefaultCategories();
    await _transactionController.loadInitialTransactions();
    await _budgetController.loadInitialBudgets();
  }

  @override
  void dispose() {
    // Importante: Limpiar los controladores cuando no se necesiten más
    // Los controladores extienden ChangeNotifier, por lo que deben ser disposed
    _transactionController.dispose();
    _categoryController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pasar los controladores a la vista principal
    // Esto demuestra cómo los controladores se pueden compartir
    // entre múltiples widgets y vistas
    return HomeView(
      transactionController: _transactionController,
      categoryController: _categoryController,
      budgetController: _budgetController,
    );
  }
}
