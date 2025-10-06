import 'package:flutter/material.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/budget_controller.dart';
import '../models/transaction.dart';
import '../widgets/add_transaction_dialog.dart';
import '../utils/currency_formatter.dart';

/// Vista de transacciones que demuestra cómo usar el TransactionController
/// para mostrar, agregar, editar y eliminar transacciones.
class TransactionsView extends StatefulWidget {
  final TransactionController transactionController;
  final CategoryController categoryController;
  final BudgetController budgetController;

  const TransactionsView({
    super.key,
    required this.transactionController,
    required this.categoryController,
    required this.budgetController,
  });

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  String _selectedFilter = 'all'; // all, income, expense

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AddTransactionDialog(
                      transactionController: widget.transactionController,
                      categoryController: widget.categoryController,
                      budgetController: widget.budgetController,
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: AnimatedBuilder(
              animation: widget.transactionController,
              builder: (context, child) {
                if (widget.transactionController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (widget.transactionController.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.transactionController.errorMessage!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            widget.transactionController.clearError();
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredTransactions = _getFilteredTransactions();

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay transacciones ${_getFilterText()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Toca el botón + para agregar una transacción',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Simular actualización
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return _buildTransactionTile(transaction);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        tooltip: 'Agregar transacción',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Construye los chips de filtro para las transacciones
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildFilterChip('all', 'Todas'),
          const SizedBox(width: 8),
          _buildFilterChip('income', 'Ingresos'),
          const SizedBox(width: 8),
          _buildFilterChip('expense', 'Gastos'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  /// Construye un tile para mostrar una transacción individual
  Widget _buildTransactionTile(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: widget.categoryController.getCategoryColor(
            transaction.category,
          ),
          child: Icon(
            transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryController.getCategoryName(transaction.category),
            ),
            Text(
              _formatDate(transaction.date),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (transaction.description != null &&
                transaction.description!.isNotEmpty)
              Text(
                transaction.description!,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.formatWithSign(
                transaction.amount,
                transaction.isIncome,
              ),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: transaction.isIncome ? Colors.green : Colors.red,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditTransactionDialog(transaction);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(transaction);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
              child: const Icon(Icons.more_vert, size: 16),
            ),
          ],
        ),
        isThreeLine:
            transaction.description != null &&
            transaction.description!.isNotEmpty,
      ),
    );
  }

  /// Obtiene las transacciones filtradas según el filtro seleccionado
  List<Transaction> _getFilteredTransactions() {
    final allTransactions = widget.transactionController.transactions;

    switch (_selectedFilter) {
      case 'income':
        return allTransactions.where((t) => t.isIncome).toList();
      case 'expense':
        return allTransactions.where((t) => !t.isIncome).toList();
      default:
        return allTransactions;
    }
  }

  String _getFilterText() {
    switch (_selectedFilter) {
      case 'income':
        return 'de ingresos';
      case 'expense':
        return 'de gastos';
      default:
        return '';
    }
  }

  /// Muestra el diálogo para agregar una nueva transacción
  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddTransactionDialog(
            transactionController: widget.transactionController,
            categoryController: widget.categoryController,
            budgetController: widget.budgetController,
          ),
    );
  }

  /// Muestra el diálogo para editar una transacción existente
  void _showEditTransactionDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder:
          (context) => AddTransactionDialog(
            transactionController: widget.transactionController,
            categoryController: widget.categoryController,
            budgetController: widget.budgetController,
            existingTransaction: transaction,
          ),
    );
  }

  /// Muestra la confirmación para eliminar una transacción
  void _showDeleteConfirmation(Transaction transaction) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Transacción'),
            content: Text(
              '¿Estás seguro de que quieres eliminar "${transaction.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Actualizar presupuesto si es un gasto
                  if (!transaction.isIncome) {
                    await widget.budgetController.removeExpenseFromBudget(
                      transaction.category,
                      transaction.amount,
                    );
                  }

                  await widget.transactionController.removeTransaction(
                    transaction.id,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transacción eliminada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
