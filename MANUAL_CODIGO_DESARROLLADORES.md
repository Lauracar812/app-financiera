# 📋 MANUAL DE CÓDIGO - APLICACIÓN FINANCIERA FLUTTER

**MANUAL TÉCNICO PARA DESARROLLADORES**  
**Versión 1.0 - Octubre 2025**  
**Autor: Laura Marcela Cardona Rojas**

---

## ÍNDICE

1. [INTRODUCCIÓN AL PROYECTO](#1-introducción-al-proyecto)
2. [ARQUITECTURA DEL SISTEMA](#2-arquitectura-del-sistema)
3. [CONTROLADORES - FRAGMENTOS CLAVE](#3-controladores---fragmentos-clave)
4. [MODELOS DE DATOS](#4-modelos-de-datos)
5. [VISTAS Y WIDGETS](#5-vistas-y-widgets)
6. [UTILIDADES Y FORMATEO](#6-utilidades-y-formateo)
7. [PUNTOS CRÍTICOS PARA ACTUALIZACIONES](#7-puntos-críticos-para-actualizaciones)
8. [GUÍA DE MANTENIMIENTO](#8-guía-de-mantenimiento)

---

## 1. INTRODUCCIÓN AL PROYECTO

### 1.1 Descripción General
La Aplicación Financiera es un sistema desarrollado en Flutter que utiliza el patrón de arquitectura MVC (Modelo-Vista-Controlador) con controladores basados en ChangeNotifier para la gestión del estado. El proyecto está diseñado para ser escalable, mantenible y educativo.

### 1.2 Tecnologías Utilizadas
- **Framework**: Flutter 3.29.2
- **Lenguaje**: Dart
- **Patrón de Estado**: ChangeNotifier (sin dependencias externas)
- **Arquitectura**: MVC (Model-View-Controller)
- **UI Design**: Material Design 3

### 1.3 Estructura de Directorios
```
lib/
├── controllers/          # Lógica de negocio y estado
├── models/              # Estructuras de datos
├── views/               # Interfaces de usuario
├── widgets/             # Componentes reutilizables
├── utils/               # Utilidades
└── main.dart           # Punto de entrada
```

---

## 2. ARQUITECTURA DEL SISTEMA

### 2.1 Patrón MVC Implementado

**MODELO (Model)**
- Representan la estructura de datos (Transaction, Category, Budget)
- Son inmutables y contienen solo datos
- Incluyen métodos para serialización JSON

**VISTA (View)**
- Interfaces de usuario (HomeView, TransactionsView, etc.)
- Solo muestran datos y capturan eventos del usuario
- Escuchan cambios de los controladores usando AnimatedBuilder

**CONTROLADOR (Controller)**
- Contienen toda la lógica de negocio y estado
- Gestionan las operaciones CRUD
- Extienden ChangeNotifier para notificación reactiva automática

### 2.2 Flujo de Datos Reactivo
```
Usuario → Vista → Controlador → Modelo → Controlador → Vista (actualizada automáticamente)
```

El sistema utiliza el patrón Observer donde las vistas se suscriben a cambios en los controladores mediante `AnimatedBuilder` y se reconstruyen automáticamente cuando el estado cambia.

---

## 3. CONTROLADORES - FRAGMENTOS CLAVE

### 3.1 TransactionController - Estructura y Conceptos Clave

**Principio de Encapsulación:**
```dart
class TransactionController extends ChangeNotifier {
  // Estado privado - No accesible desde fuera
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Acceso público de solo lectura
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
}
```

**Explicación Crítica:**
- Las variables privadas (con `_`) impiden modificaciones directas desde las vistas
- Los getters públicos exponen solo lectura, manteniendo la integridad de los datos
- `List.unmodifiable()` garantiza que nadie pueda modificar la lista externamente

**Cálculos Automáticos y Getters Computados:**
```dart
// Se recalcula automáticamente cada vez que se accede
double get totalBalance {
  double balance = 0.0;
  for (var transaction in _transactions) {
    balance += transaction.isIncome ? transaction.amount : -transaction.amount;
  }
  return balance;
}

// Filtros reactivos
List<Transaction> get incomeTransactions => 
  _transactions.where((t) => t.isIncome).toList();
```

**Explicación Crítica:**
- Los getters se ejecutan cada vez que se acceden, siempre reflejando el estado actual
- No se almacena estado calculado, se computa en tiempo real
- Garantiza consistencia automática sin necesidad de sincronización manual

**Patrón de Notificación Reactiva:**
```dart
Future<void> addTransaction(Transaction transaction) async {
  _setLoading(true);  // Notifica cambio de estado de carga
  
  try {
    _transactions.add(transaction);
    _sortTransactionsByDate();
    notifyListeners();  // CRÍTICO: Actualiza TODAS las vistas que escuchan
  } catch (e) {
    _setError('Error: $e');
  } finally {
    _setLoading(false);
  }
}

void _setLoading(bool loading) {
  _isLoading = loading;
  notifyListeners();  // Inmediatamente notifica el cambio
}
```

**Explicación Crítica:**
- `notifyListeners()` es el corazón del patrón reactivo
- Se llama automáticamente cada vez que el estado interno cambia
- Todas las vistas suscritas se reconstruyen inmediatamente
- Elimina la necesidad de `setState()` manual en las vistas

### 3.2 CategoryController - Gestión de Categorías

**Filtrado Inteligente por Tipo:**
```dart
List<Category> getCategoriesByType(bool isIncome) {
  return _categories.where((category) => 
    category.isForIncome == isIncome
  ).toList();
}

Category? getCategoryById(String categoryId) {
  try {
    return _categories.firstWhere((c) => c.id == categoryId);
  } catch (e) {
    return null; // Manejo seguro de categorías no encontradas
  }
}
```

**Explicación Crítica:**
- El filtrado por tipo es esencial para los dropdowns de transacciones
- Categorías de ingresos y gastos se mantienen separadas lógicamente
- El manejo de excepciones previene crashes cuando se buscan IDs inexistentes

**Validación de Duplicados:**
```dart
Future<void> addCategory(Category category) async {
  // Validación crítica antes de agregar
  bool exists = _categories.any((c) => 
    c.name.toLowerCase() == category.name.toLowerCase() &&
    c.isForIncome == category.isForIncome
  );
  
  if (exists) {
    throw Exception('Categoría duplicada para este tipo');
  }
  
  _categories.add(category);
  notifyListeners();
}
```

**Explicación Crítica:**
- Previene duplicados considerando tanto nombre como tipo
- La validación es case-insensitive para mejor UX
- Las excepciones son capturadas por las vistas para mostrar errores apropiados

### 3.3 BudgetController - Control Financiero

**Cálculos de Presupuesto en Tiempo Real:**
```dart
double getBudgetUsagePercentage(String categoryId, double spentAmount) {
  final budget = getBudgetByCategory(categoryId);
  if (budget == null || budget.amount == 0) return 0.0;
  
  return (spentAmount / budget.amount) * 100;
}

bool isBudgetExceeded(String categoryId, double spentAmount) {
  final budget = getBudgetByCategory(categoryId);
  return budget != null && spentAmount > budget.amount;
}
```

**Explicación Crítica:**
- Los cálculos se basan en datos en tiempo real, no almacenados
- Manejo defensivo de casos edge (budget null, amount 0)
- Estos métodos son llamados por las vistas para mostrar alertas visuales

**Integración Cross-Controller:**
```dart
// En las vistas, los controladores se combinan para cálculos complejos
AnimatedBuilder(
  animation: Listenable.merge([
    transactionController,  // Escucha cambios en transacciones
    budgetController,       // Escucha cambios en presupuestos
  ]),
  builder: (context, child) {
    // Se recalcula automáticamente cuando CUALQUIERA cambia
    double spent = transactionController
      .getTransactionsByCategory(categoryId)
      .fold(0.0, (sum, t) => sum + t.amount);
    
    double percentage = budgetController
      .getBudgetUsagePercentage(categoryId, spent);
  }
)
```

**Explicación Crítica:**
- `Listenable.merge()` permite escuchar múltiples controladores
- La vista se actualiza cuando cualquier controlador relevante cambia
- Elimina la necesidad de sincronización manual entre controladores

---

## 4. MODELOS DE DATOS

### 4.1 Principios de Inmutabilidad

**Estructura de Transaction:**
```dart
class Transaction {
  final String id;           // Inmutable
  final double amount;       // Inmutable  
  final String description;  // Inmutable
  final bool isIncome;       // Inmutable
  final DateTime date;       // Inmutable
  
  Transaction({required this.id, ...}); // Constructor con required
}
```

**Patrón CopyWith para Actualizaciones:**
```dart
Transaction copyWith({
  String? id,
  double? amount,
  // ... otros campos opcionales
}) {
  return Transaction(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    // ... mantiene valores existentes si no se especifican nuevos
  );
}
```

**Explicación Crítica:**
- La inmutabilidad previene modificaciones accidentales
- `copyWith()` permite "editar" creando una nueva instancia
- Facilita el debugging y previene efectos secundarios

### 4.2 Serialización para Persistencia

**Conversión a/desde JSON:**
```dart
// Para guardar en storage local o enviar a API
Map<String, dynamic> toJson() => {
  'id': id,
  'amount': amount,
  'date': date.toIso8601String(), // Formato estándar
};

// Para cargar desde storage o recibir de API  
factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'],
  amount: json['amount'].toDouble(),
  date: DateTime.parse(json['date']),
);
```

**Explicación Crítica:**
- Preparado para integración con APIs REST o GraphQL
- Manejo consistente de tipos de datos (double, DateTime)
- Facilita la implementación de persistencia local

---

## 5. VISTAS Y WIDGETS

### 5.1 Patrón de Escucha Reactiva

**Estructura Base de Vistas:**
```dart
class TransactionsView extends StatelessWidget {
  final TransactionController transactionController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: transactionController, // Escucha automática
      builder: (context, child) {
        // Se ejecuta cada vez que el controlador cambia
        if (transactionController.isLoading) {
          return CircularProgressIndicator();
        }
        
        return ListView.builder(
          itemCount: transactionController.transactions.length,
          // UI construida con datos siempre actualizados
        );
      },
    );
  }
}
```

**Explicación Crítica:**
- `AnimatedBuilder` es más eficiente que `Consumer` o `Provider`
- La vista es stateless pero reactiva a cambios del controlador
- No hay `setState()` manual, todo es automático

### 5.2 Gestión de Estados de UI

**Manejo de Estados de Carga y Error:**
```dart
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      // Estados centralizados desde el controlador
      if (controller.isLoading) return LoadingWidget();
      if (controller.errorMessage != null) return ErrorWidget(controller.errorMessage);
      
      // Estado normal con datos
      return DataWidget(controller.data);
    },
  );
}
```

**Explicación Crítica:**
- Los estados de UI (loading, error, success) viven en el controlador
- Consistencia en el manejo de estados a través de toda la app
- Facilita testing y debugging de estados específicos

---

## 6. UTILIDADES Y FORMATEO

### 6.1 CurrencyFormatter - Formateo de Moneda

**Funcionalidad Principal:**
```dart
class CurrencyFormatter {
  static String format(double amount) {
    int intAmount = amount.round();
    // Algoritmo de separadores de miles
    String amountStr = intAmount.toString();
    // ... lógica de formateo
    return 'COP \$${formattedAmount}';
  }
  
  static String formatWithSign(double amount, bool isIncome) {
    String formatted = format(amount);
    return isIncome ? '+$formatted' : '-$formatted';
  }
}
```

**Explicación Crítica:**
- Centraliza toda la lógica de formateo de moneda
- Consistencia en el formato COP a través de toda la app
- Separación entre display (con signo) y valor puro

**Integración en la UI:**
```dart
// Uso consistente en todas las vistas
Text(CurrencyFormatter.format(transaction.amount))
Text(CurrencyFormatter.formatWithSign(amount, isIncome))
```

---

## 7. PUNTOS CRÍTICOS PARA ACTUALIZACIONES

### 7.1 Integración con Persistencia Real

**Ubicaciones a Modificar:**
```dart
// EN TODOS LOS CONTROLADORES: Reemplazar datos simulados
Future<void> loadInitialData() async {
  // ACTUAL
  _transactions = [/* datos hardcodeados */];
  
  // FUTURO
  _transactions = await DatabaseService.getTransactions();
  _categories = await DatabaseService.getCategories();
}
```

**Consideraciones:**
- Mantener la estructura de métodos públicos existente
- Agregar manejo de errores de red/database
- Implementar cache local para offline-first

### 7.2 Validaciones de Negocio Mejoradas

**Lugares para Agregar Validaciones:**
```dart
// En métodos add/update de controladores
Future<void> addTransaction(Transaction transaction) async {
  // AGREGAR: Validaciones antes de persistir
  if (transaction.amount <= 0) throw ValidationException('Monto debe ser positivo');
  if (transaction.description.trim().isEmpty) throw ValidationException('Descripción requerida');
  
  // Lógica existente...
}
```

### 7.3 Sistema de Notificaciones

**Punto de Integración en BudgetController:**
```dart
bool isBudgetExceeded(String categoryId, double spentAmount) {
  final exceeded = spentAmount > budget.amount;
  
  // AGREGAR: Sistema de notificaciones
  if (exceeded) {
    NotificationService.showBudgetAlert(categoryId);
  }
  
  return exceeded;
}
```

### 7.4 Exportación de Datos

**Nuevos Métodos a Agregar:**
```dart
// En cada controlador
Future<String> exportToCsv() async { /* implementación */ }
Future<Uint8List> exportToPdf() async { /* implementación */ }
```

---

## 8. GUÍA DE MANTENIMIENTO

### 8.1 Agregar Nueva Funcionalidad

**Proceso Estándar:**
1. **Crear modelo** (si es necesario) con inmutabilidad
2. **Crear controlador** extendiendo ChangeNotifier
3. **Implementar métodos CRUD** con notifyListeners()
4. **Crear vista** usando AnimatedBuilder
5. **Integrar en main.dart** con inicialización adecuada

### 8.2 Modificar Controlador Existente

**Reglas de Compatibilidad:**
- **NUNCA** cambiar signatures de métodos públicos existentes
- **SIEMPRE** agregar métodos nuevos en lugar de modificar existentes
- **MANTENER** la estructura de getters computados
- **PRESERVAR** el patrón de notificación con `notifyListeners()`

### 8.3 Testing de Controladores

**Estructura de Tests:**
```dart
void main() {
  group('TransactionController', () {
    late TransactionController controller;
    
    setUp(() => controller = TransactionController());
    
    test('should calculate balance correctly', () {
      // Test de lógica pura sin UI
      expect(controller.totalBalance, equals(expectedValue));
    });
  });
}
```

**Ventajas del Patrón:**
- Lógica de negocio separada = fácil de testear
- Sin dependencias de UI = tests rápidos
- Estados predecibles = tests determinísticos

---

### 8.4 Conclusiones Arquitectónicas

#### Ventajas del Diseño Actual:
- **Separación clara** de responsabilidades (MVC)
- **Estado reactivo** sin complejidad adicional
- **Escalabilidad** para nuevas funcionalidades
- **Testabilidad** de lógica de negocio independiente

#### Limitaciones a Considerar:
- **Persistencia temporal** (solo en memoria)
- **Sincronización de datos** entre dispositivos
- **Optimización** para grandes volúmenes de datos
- **Validaciones robustas** de entrada de usuario

#### Evolución Recomendada:
1. **Capa de persistencia** (SQLite/Hive)
2. **Sincronización cloud** (Firebase/API REST)
3. **Validaciones centralizadas** (validation package)
4. **Sistema de logging** para debugging
5. **Performance monitoring** para optimización

---

**Este manual proporciona la guía esencial para entender, mantener y extender la aplicación financiera, enfocándose en los conceptos clave y puntos críticos para el desarrollo profesional.**

---

**Desarrollado por: Laura Marcela Cardona Rojas**  
**Fecha: Octubre 2025**  
**Repositorio: https://github.com/Lauracar812/app-financiera**