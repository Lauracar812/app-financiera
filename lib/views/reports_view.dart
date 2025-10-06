import 'package:flutter/material.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/budget_controller.dart';
import '../utils/currency_formatter.dart';

/// Vista de reportes que demuestra cómo los controladores pueden
/// proporcionar datos agregados y calculados para reportes
class ReportsView extends StatefulWidget {
  final TransactionController transactionController;
  final CategoryController categoryController;
  final BudgetController budgetController;

  const ReportsView({
    super.key,
    required this.transactionController,
    required this.categoryController,
    required this.budgetController,
  });

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String _selectedPeriod = 'month'; // month, year, all

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          widget.transactionController,
          widget.categoryController,
          widget.budgetController,
        ]),
        builder: (context, child) {
          if (widget.transactionController.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generando reportes...'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                widget.transactionController.loadInitialTransactions(),
                widget.budgetController.loadInitialBudgets(),
              ]);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 16),
                  _buildFinancialSummaryCard(),
                  const SizedBox(height: 16),
                  _buildCategoryBreakdownCard(),
                  const SizedBox(height: 16),
                  _buildBudgetPerformanceCard(),
                  const SizedBox(height: 16),
                  _buildMonthlyTrendsCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Selector de período para los reportes
  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Período del Reporte',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'month',
                  label: Text('Este Mes'),
                  icon: Icon(Icons.calendar_month),
                ),
                ButtonSegment(
                  value: 'year',
                  label: Text('Este Año'),
                  icon: Icon(Icons.calendar_today),
                ),
                ButtonSegment(
                  value: 'all',
                  label: Text('Todo'),
                  icon: Icon(Icons.all_inclusive),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedPeriod = selection.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Resumen financiero general
  Widget _buildFinancialSummaryCard() {
    final transactions = _getFilteredTransactions();
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netIncome = totalIncome - totalExpenses;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen Financiero - ${_getPeriodText()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Ingresos',
                  totalIncome,
                  Colors.green,
                  Icons.arrow_upward,
                ),
                _buildSummaryItem(
                  'Gastos',
                  totalExpenses,
                  Colors.red,
                  Icons.arrow_downward,
                ),
                _buildSummaryItem(
                  'Balance',
                  netIncome,
                  netIncome >= 0 ? Colors.green : Colors.red,
                  netIncome >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (totalIncome > 0) ...[
              Text(
                'Tasa de Ahorro: ${((netIncome / totalIncome) * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: netIncome >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (netIncome / totalIncome).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  netIncome >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Desglose por categorías
  Widget _buildCategoryBreakdownCard() {
    final transactions = _getFilteredTransactions();
    final expensesByCategory = <String, double>{};

    for (var transaction in transactions.where((t) => !t.isIncome)) {
      expensesByCategory[transaction.category] =
          (expensesByCategory[transaction.category] ?? 0) + transaction.amount;
    }

    final sortedCategories =
        expensesByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gastos por Categoría',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (sortedCategories.isEmpty)
              const Center(child: Text('No hay gastos en este período'))
            else
              ...sortedCategories.take(5).map((entry) {
                final percentage =
                    sortedCategories.isNotEmpty
                        ? (entry.value / sortedCategories.first.value * 100)
                        : 0.0;
                final categoryName = widget.categoryController.getCategoryName(
                  entry.key,
                );
                final categoryColor = widget.categoryController
                    .getCategoryColor(entry.key);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: categoryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            CurrencyFormatter.format(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          categoryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${percentage.toStringAsFixed(1)}% del total',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// Rendimiento de presupuestos
  Widget _buildBudgetPerformanceCard() {
    final budgets = widget.budgetController.budgets;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rendimiento de Presupuestos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (budgets.isEmpty)
              const Center(child: Text('No hay presupuestos configurados'))
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBudgetStatusItem(
                    'En Control',
                    widget.budgetController.budgetAlerts['healthy'] ?? 0,
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildBudgetStatusItem(
                    'Cerca del Límite',
                    widget.budgetController.budgetAlerts['nearLimit'] ?? 0,
                    Colors.orange,
                    Icons.warning,
                  ),
                  _buildBudgetStatusItem(
                    'Excedidos',
                    widget.budgetController.budgetAlerts['exceeded'] ?? 0,
                    Colors.red,
                    Icons.error,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Utilización Total: ${widget.budgetController.totalSpentPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: widget.budgetController.totalSpentPercentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.budgetController.totalSpentPercentage > 90
                      ? Colors.red
                      : widget.budgetController.totalSpentPercentage > 70
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tendencias mensuales (simulado)
  Widget _buildMonthlyTrendsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tendencias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text('Ahorro mensual promedio'),
              trailing: const Text(
                '\$150.00',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.receipt, color: Colors.blue),
              title: const Text('Transacciones este mes'),
              trailing: Text(
                '${_getFilteredTransactions().length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.purple),
              title: const Text('Categoría más gastada'),
              trailing: const Text(
                'Alimentación',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetStatusItem(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<dynamic> _getFilteredTransactions() {
    final allTransactions = widget.transactionController.transactions;
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'month':
        return allTransactions.where((t) {
          return t.date.year == now.year && t.date.month == now.month;
        }).toList();
      case 'year':
        return allTransactions.where((t) {
          return t.date.year == now.year;
        }).toList();
      default:
        return allTransactions;
    }
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case 'month':
        return 'Este Mes';
      case 'year':
        return 'Este Año';
      default:
        return 'Todo el Período';
    }
  }
}
