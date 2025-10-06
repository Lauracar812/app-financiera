# Controladores en Flutter: Gestión de Estado en Aplicación Financiera

## 📚 Concepto de Controladores

### ¿Qué son los Controladores?

Los **controladores** en Flutter son clases especializadas que se encargan de **gestionar el estado** de la aplicación de manera centralizada y organizada. A diferencia del estado local de los widgets (StatefulWidget), los controladores permiten:

- **Separar la lógica de negocio de la UI**
- **Compartir estado entre múltiples widgets**
- **Mantener el estado durante la navegación**
- **Aplicar el patrón MVC (Model-View-Controller)**

### Características Principales

1. **Extienden ChangeNotifier**: Para notificar cambios a los widgets
2. **Encapsulación**: Los datos privados se acceden mediante getters públicos
3. **Métodos de negocio**: Contienen la lógica específica del dominio
4. **Gestión del ciclo de vida**: Se inicializan una vez y se mantienen durante toda la sesión

## 🏗️ Arquitectura Implementada

### Patrón MVC en la Aplicación Financiera

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│     MODELS      │    │   CONTROLLERS    │    │     VIEWS       │
├─────────────────┤    ├──────────────────┤    ├─────────────────┤
│ • Transaction   │───▶│ • TransactionCtrl│───▶│ • HomeView      │
│ • Category      │    │ • CategoryCtrl   │    │ • TransactionsV │
│ • Budget        │    │ • BudgetCtrl     │    │ • BudgetsView   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
     Datos                   Lógica                   UI
```

## 💰 Implementación: TransactionController

### Estructura Base del Controlador

```dart
/// Controlador para gestionar el estado de las transacciones financieras.
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
```

### Lógica de Negocio Centralizada

```dart
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
```

### Métodos de Operaciones CRUD

```dart
  /// Agregar una nueva transacción
  Future<void> addTransaction(Transaction transaction) async {
    _setLoading(true);
    _setError(null);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _transactions.add(transaction);
      _sortTransactionsByDate();
      notifyListeners(); // ← Notifica a todos los widgets que escuchan
    } catch (e) {
      _setError('Error al agregar la transacción: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar una transacción
  Future<void> removeTransaction(String id) async {
    _setLoading(true);
    try {
      _transactions.removeWhere((transaction) => transaction.id == id);
      notifyListeners(); // ← Actualiza automáticamente la UI
    } finally {
      _setLoading(false);
    }
  }
```

## 🏷️ CategoryController: Gestión de Categorías

### Implementación de Categorías Dinámicas

```dart
class CategoryController extends ChangeNotifier {
  List<Category> _categories = [];

  // Obtener categorías de gastos
  List<Category> get expenseCategories {
    return _categories.where((category) => !category.isIncomeCategory).toList();
  }

  // Obtener categorías de ingresos
  List<Category> get incomeCategories {
    return _categories.where((category) => category.isIncomeCategory).toList();
  }

  /// Método helper para obtener color por ID
  Color getCategoryColor(String categoryId) {
    try {
      final category = _categories.firstWhere((cat) => cat.id == categoryId);
      return Color(category.color);
    } catch (e) {
      return Colors.grey;
    }
  }
```

## 💳 BudgetController: Control de Presupuestos

### Cálculos Automáticos y Estados Derivados

```dart
class BudgetController extends ChangeNotifier {
  List<Budget> _budgets = [];

  // Calcular el total presupuestado
  double get totalBudgeted {
    return _budgets.fold(0.0, (total, budget) => total + budget.budgetAmount);
  }

  // Calcular el porcentaje total gastado
  double get totalSpentPercentage {
    if (totalBudgeted <= 0) return 0.0;
    return (totalSpent / totalBudgeted * 100).clamp(0.0, 100.0);
  }

  /// Obtener resumen de alertas de presupuesto
  Map<String, int> get budgetAlerts {
    return {
      'exceeded': exceededBudgets.length,
      'nearLimit': nearLimitBudgets.length,
      'healthy': activeBudgets.length - exceededBudgets.length - nearLimitBudgets.length,
    };
  }
```

## 🔄 Comunicación entre Controladores

### Inicialización Centralizada en Main.dart

```dart
class _FinancialAppHomeState extends State<FinancialAppHome> {
  // Instancias de los controladores - creados una sola vez
  late final TransactionController _transactionController;
  late final CategoryController _categoryController;
  late final BudgetController _budgetController;

  @override
  void initState() {
    super.initState();
    
    // Inicializar los controladores
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
```

## 🎯 Conexión con la UI: AnimatedBuilder

### Escucha Reactiva de Cambios

```dart
/// En HomeView - Dashboard que escucha múltiples controladores
AnimatedBuilder(
  // Escuchar cambios en los controladores principales
  animation: Listenable.merge([
    widget.transactionController,
    widget.budgetController,
  ]),
  builder: (context, child) {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _buildDashboard(),
        TransactionsView(
          transactionController: widget.transactionController,
          categoryController: widget.categoryController,
          budgetController: widget.budgetController,
        ),
        // ... otras vistas
      ],
    );
  },
),
```

### Uso en Widgets Individuales

```dart
/// En el balance card - Acceso directo a datos calculados
Widget _buildBalanceCard() {
  final totalBalance = widget.transactionController.totalBalance;
  final totalIncome = widget.transactionController.totalIncome;
  final totalExpenses = widget.transactionController.totalExpenses;

  return Container(
    child: Column(
      children: [
        Text(CurrencyFormatter.format(totalBalance)),
        _buildBalanceItem('Ingresos', totalIncome, Colors.green),
        _buildBalanceItem('Gastos', totalExpenses, Colors.red),
      ],
    ),
  );
}
```

## ⚙️ Ventajas de esta Implementación

### 1. **Separación de Responsabilidades**
- **Modelos**: Solo contienen datos y validaciones básicas
- **Controladores**: Manejan lógica de negocio y estado
- **Vistas**: Solo se enfocan en la presentación

### 2. **Estado Compartido**
```dart
// El mismo controlador se usa en múltiples vistas
HomeView(
  transactionController: _transactionController,  // ← Misma instancia
  categoryController: _categoryController,        // ← Misma instancia
  budgetController: _budgetController,           // ← Misma instancia
)
```

### 3. **Reactividad Automática**
- Cualquier cambio en `_transactions` notifica automáticamente a todos los widgets
- La UI se actualiza sin código adicional
- Los cálculos (balance, totales) se actualizan en tiempo real

### 4. **Mantenimiento del Estado**
- El estado persiste durante la navegación
- No se pierde información al cambiar de pantalla
- Gestión centralizada del ciclo de vida

## 🛠️ Casos de Uso Demostrados

### 1. **Agregar Transacción**
```
Usuario → AddTransactionDialog → transactionController.addTransaction() 
       → notifyListeners() → UI se actualiza automáticamente
```

### 2. **Cálculo de Balance**
```
Cualquier cambio en transacciones → getter totalBalance recalcula 
                                  → AnimatedBuilder detecta cambio
                                  → UI muestra nuevo balance
```

### 3. **Filtrado por Categorías**
```
categoryController.expenseCategories → Filtra automáticamente
                                    → DropdownButton se actualiza
                                    → Usuario ve solo categorías relevantes
```

## 📊 Beneficios Educativos Logrados

### ✅ **Conceptos Aprendidos**
1. **ChangeNotifier Pattern**: Implementación correcta de notificaciones
2. **Getter Computados**: Cálculos automáticos basados en estado
3. **Encapsulación**: Datos privados con acceso controlado
4. **Separación MVC**: Arquitectura limpia y mantenible
5. **Estado Reactivo**: UI que responde automáticamente a cambios

### ✅ **Mejores Prácticas Aplicadas**
1. **Dispose Pattern**: Limpieza correcta de recursos
2. **Async Operations**: Manejo de operaciones asíncronas
3. **Error Handling**: Gestión centralizada de errores
4. **Performance**: Uso de `List.unmodifiable()` para proteger datos
5. **Testabilidad**: Lógica separada facilita testing

## 🎓 Conclusión

La implementación de **controladores** en esta aplicación financiera demuestra cómo:

- **Centralizar el estado** mejora la organización del código
- **Separar responsabilidades** facilita el mantenimiento
- **Notificaciones automáticas** simplifican la actualización de UI
- **Estado compartido** permite comunicación fluida entre componentes
- **Patrón MVC** proporciona una arquitectura escalable

Los controladores transforman una aplicación Flutter de **estado local disperso** en una **arquitectura profesional** que es mantenible, testeable y escalable.

---

**Autor**: Desarrollado como proyecto educativo para demostrar gestión de estado con controladores en Flutter

**Tecnologías**: Flutter 3.29.2, Dart, Material Design 3

**Patrón**: MVC (Model-View-Controller) con ChangeNotifier