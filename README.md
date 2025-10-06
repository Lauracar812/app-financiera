# Aplicación Financiera - Flutter con Controladores

Una aplicación financiera desarrollada en Flutter que demuestra el uso de **controladores para la administración del estado**. Esta aplicación sirve como ejemplo educativo para comprender cómo los controladores pueden ayudar a mantener y gestionar el estado de una aplicación de forma eficiente y organizada.

## 🎯 Objetivo Educativo

Esta aplicación fue desarrollada como proyecto educativo para demostrar:

- **Administración del estado** en Flutter usando controladores
- **Separación de responsabilidades** entre lógica de negocio y UI
- **Comunicación entre controladores** para operaciones complejas
- **Notificación de cambios** usando `ChangeNotifier`
- **Arquitectura limpia** con controladores, modelos, vistas y servicios

## 🏗️ Arquitectura del Proyecto

```
lib/
├── controllers/          # Controladores para gestión del estado
│   ├── transaction_controller.dart
│   ├── category_controller.dart
│   └── budget_controller.dart
├── models/              # Modelos de datos
│   ├── transaction.dart
│   ├── category.dart
│   └── budget.dart
├── views/               # Interfaces de usuario
│   ├── home_view.dart
│   ├── transactions_view.dart
│   ├── budgets_view.dart
│   └── reports_view.dart
├── widgets/             # Widgets reutilizables
│   └── add_transaction_dialog.dart
├── services/            # Servicios de lógica de negocio
└── main.dart           # Punto de entrada de la aplicación
```

## 🔧 Características Implementadas

### 📊 Gestión de Transacciones
- ✅ Agregar ingresos y gastos
- ✅ Categorización automática
- ✅ Edición y eliminación de transacciones
- ✅ Validación de datos
- ✅ Estados de carga y error

### 💰 Control de Presupuestos
- ✅ Creación de presupuestos por categoría
- ✅ Seguimiento de gastos vs presupuesto
- ✅ Alertas de límites excedidos
- ✅ Cálculos automáticos de porcentajes

### 📈 Reportes y Análisis
- ✅ Dashboard con resumen financiero
- ✅ Gráficos de gastos por categoría
- ✅ Análisis de tendencias
- ✅ Filtros por período

### 🎨 Interfaz de Usuario
- ✅ Diseño Material Design 3
- ✅ Navegación por pestañas
- ✅ Estados de carga interactivos
- ✅ Manejo de errores visual

## 🧩 Controladores Implementados

### 📝 TransactionController
```dart
class TransactionController extends ChangeNotifier {
  // Mantiene la lista de transacciones
  // Proporciona métodos para CRUD
  // Calcula balances automáticamente
  // Notifica cambios a los widgets
}
```

### 📂 CategoryController
```dart
class CategoryController extends ChangeNotifier {
  // Gestiona las categorías de ingresos y gastos
  // Proporciona información de colores e iconos
  // Filtra categorías por tipo
}
```

### 💵 BudgetController
```dart
class BudgetController extends ChangeNotifier {
  // Controla los presupuestos por categoría
  // Calcula gastos vs presupuestado
  // Genera alertas automáticas
  // Coordina con TransactionController
}
```

## 🚀 Cómo Ejecutar el Proyecto

### Prerrequisitos
- Flutter SDK (versión 3.0 o superior)
- Dart SDK
- VS Code con extensiones de Flutter y Dart
- Un dispositivo/emulador para pruebas

### Instalación

1. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

2. **Verificar la instalación**
   ```bash
   flutter doctor
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

### Opciones de Ejecución

- **Modo Debug** (por defecto): `flutter run`
- **Modo Release**: `flutter run --release`
- **En Chrome**: `flutter run -d chrome`

## 📚 Conceptos de Controladores Demostrados

### 1. **Estado Centralizado**
Los controladores mantienen el estado de la aplicación en un lugar central, evitando la duplicación de datos y facilitando la sincronización.

### 2. **Notificación de Cambios**
Usando `ChangeNotifier`, los controladores notifican automáticamente a los widgets cuando el estado cambia.

### 3. **Separación de Responsabilidades**
- **Controladores**: Lógica de negocio y estado
- **Vistas**: Presentación de datos
- **Modelos**: Estructura de datos
- **Widgets**: Componentes reutilizables

### 4. **Coordinación entre Controladores**
Los controladores pueden trabajar juntos:
```dart
// Al agregar un gasto, actualiza tanto transacciones como presupuestos
await transactionController.addTransaction(transaction);
await budgetController.addExpenseToBudget(categoryId, amount);
```

## 🔄 Flujo de Datos

```
1. Usuario interactúa con la UI
         ↓
2. Widget llama método del controlador
         ↓
3. Controlador procesa la lógica de negocio
         ↓
4. Controlador actualiza el estado interno
         ↓
5. notifyListeners() se ejecuta
         ↓
6. Widgets que escuchan se rebuildan automáticamente
         ↓
7. UI se actualiza con los nuevos datos
```

## 🧪 Testing

Para ejecutar las pruebas:

```bash
flutter test
```

## 🎓 Valor Educativo

Esta aplicación demuestra:

1. **Por qué usar controladores**: Comparado con setState local
2. **Cómo estructurar el código**: Arquitectura escalable
3. **Gestión de estado compleja**: Múltiples fuentes de datos
4. **Buenas prácticas**: Naming, organización, documentación
5. **Patrones reales**: Casos de uso financieros comunes

---

**Desarrollado con ❤️ usando Flutter y el patrón de Controladores para demostrar la administración efectiva del estado en aplicaciones móviles.**
