import 'package:flutter/material.dart';
import '../controllers/budget_controller.dart';
import '../controllers/category_controller.dart';
import '../models/budget.dart';
import '../utils/currency_formatter.dart';

/// Vista de presupuestos que demuestra el uso del BudgetController
/// para mostrar y gestionar presupuestos
class BudgetsView extends StatefulWidget {
  final BudgetController budgetController;
  final CategoryController categoryController;

  const BudgetsView({
    super.key,
    required this.budgetController,
    required this.categoryController,
  });

  @override
  State<BudgetsView> createState() => _BudgetsViewState();
}

class _BudgetsViewState extends State<BudgetsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.budgetController,
        builder: (context, child) {
          if (widget.budgetController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildSummaryCard(),
              Expanded(child: _buildBudgetsList()),
            ],
          );
        },
      ),
    );
  }

  /// Card resumen con estadísticas generales
  Widget _buildSummaryCard() {
    final totalBudgeted = widget.budgetController.totalBudgeted;
    final totalSpent = widget.budgetController.totalSpent;
    final spentPercentage = widget.budgetController.totalSpentPercentage;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Total Presupuestado',
                  CurrencyFormatter.format(totalBudgeted),
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'Total Gastado',
                  CurrencyFormatter.format(totalSpent),
                  totalSpent > totalBudgeted ? Colors.red : Colors.green,
                ),
                _buildSummaryItem(
                  'Restante',
                  CurrencyFormatter.format(totalBudgeted - totalSpent),
                  totalBudgeted - totalSpent >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: spentPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                spentPercentage > 90
                    ? Colors.red
                    : spentPercentage > 70
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${spentPercentage.toStringAsFixed(1)}% del total presupuestado utilizado',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Lista de presupuestos individuales
  Widget _buildBudgetsList() {
    final budgets = widget.budgetController.budgets;

    if (budgets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay presupuestos creados',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Toca el botón + para crear tu primer presupuesto',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        return _buildBudgetCard(budget);
      },
    );
  }

  /// Card individual para cada presupuesto
  Widget _buildBudgetCard(Budget budget) {
    final categoryName = widget.categoryController.getCategoryName(
      budget.categoryId,
    );
    final categoryColor = widget.categoryController.getCategoryColor(
      budget.categoryId,
    );
    final percentage = budget.spentPercentage;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditBudgetDialog(budget);
                    } else if (value == 'delete') {
                      _showDeleteBudgetConfirmation(budget);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar'),
                        ),
                      ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Gastado: ${CurrencyFormatter.format(budget.spentAmount)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Presupuesto: ${CurrencyFormatter.format(budget.budgetAmount)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 90
                    ? Colors.red
                    : percentage > 70
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}% utilizado',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Restante: ${CurrencyFormatter.format(budget.remainingAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        budget.remainingAmount >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Diálogo para agregar nuevo presupuesto
  void _showAddBudgetDialog() {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    String? selectedCategoryId;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nuevo Presupuesto'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items:
                        widget.categoryController.categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => selectedCategoryId = value,
                    validator:
                        (value) =>
                            value == null ? 'Selecciona una categoría' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto del Presupuesto',
                      prefixText: 'COP \$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un monto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingresa un monto válido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final amount = double.parse(amountController.text);
                    final newBudget = Budget(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      categoryId: selectedCategoryId!,
                      categoryName: widget.categoryController.getCategoryName(
                        selectedCategoryId!,
                      ),
                      budgetAmount: amount,
                      spentAmount: 0.0,
                      startDate: DateTime.now(),
                      endDate: DateTime(
                        DateTime.now().year,
                        DateTime.now().month + 1,
                        0,
                      ),
                    );
                    widget.budgetController.addBudget(newBudget);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Presupuesto creado exitosamente'),
                      ),
                    );
                  }
                },
                child: const Text('Crear'),
              ),
            ],
          ),
    );
  }

  /// Diálogo para editar presupuesto existente
  void _showEditBudgetDialog(Budget budget) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: budget.budgetAmount.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Editar Presupuesto - ${widget.categoryController.getCategoryName(budget.categoryId)}',
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo Monto del Presupuesto',
                      prefixText: 'COP \$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un monto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingresa un monto válido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final newAmount = double.parse(amountController.text);
                    final updatedBudget = budget.copyWith(
                      budgetAmount: newAmount,
                    );
                    widget.budgetController.updateBudget(updatedBudget);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Presupuesto actualizado exitosamente'),
                      ),
                    );
                  }
                },
                child: const Text('Actualizar'),
              ),
            ],
          ),
    );
  }

  /// Confirmación para eliminar presupuesto
  void _showDeleteBudgetConfirmation(Budget budget) {
    final categoryName = widget.categoryController.getCategoryName(
      budget.categoryId,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Presupuesto'),
            content: Text(
              '¿Estás seguro de que quieres eliminar el presupuesto para "$categoryName"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.budgetController.removeBudget(budget.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Presupuesto eliminado exitosamente'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
