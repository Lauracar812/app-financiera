import 'package:flutter/material.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/budget_controller.dart';
import '../controllers/travel_controller.dart';
import 'transactions_view.dart';
import 'budgets_view.dart';
import 'reports_view.dart';
import 'travels_view.dart';
import '../widgets/add_transaction_dialog.dart';
import '../utils/currency_formatter.dart';

/// Vista principal que demuestra cómo los controladores mantienen el estado
/// a través de múltiples pantallas y navegación
class HomeView extends StatefulWidget {
  final TransactionController transactionController;
  final CategoryController categoryController;
  final BudgetController budgetController;
  final TravelController travelController;

  const HomeView({
    super.key,
    required this.transactionController,
    required this.categoryController,
    required this.budgetController,
    required this.travelController,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _selectedIndex == 0
              ? AppBar(
                title: const Text('Dashboard Financiero'),
                backgroundColor: const Color(0xFF6366F1),
                elevation: 0,
                foregroundColor: Colors.white,
                centerTitle: true,
              )
              : null,
      body: AnimatedBuilder(
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
              BudgetsView(
                budgetController: widget.budgetController,
                categoryController: widget.categoryController,
              ),
              TravelsView(travelController: widget.travelController),
              ReportsView(
                transactionController: widget.transactionController,
                categoryController: widget.categoryController,
                budgetController: widget.budgetController,
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Mostrar el diálogo para agregar transacción
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
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add),
          label: const Text(
            'Agregar',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Transacciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              activeIcon: Icon(Icons.savings),
              label: 'Presupuestos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight_takeoff_outlined),
              activeIcon: Icon(Icons.flight_takeoff),
              label: 'Viajes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Reportes',
            ),
          ],
        ),
      ),
    );
  }

  /// Dashboard principal con resumen financiero usando todos los controladores
  Widget _buildDashboard() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildBudgetAlertsCard(),
            const SizedBox(height: 20),
            _buildRecentTransactionsCard(),
          ],
        ),
      ),
    );
  }

  /// Widget de bienvenida
  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Buenos días';
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestiona tus finanzas de manera inteligente',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  /// Card que muestra el balance total usando el TransactionController
  Widget _buildBalanceCard() {
    final totalBalance = widget.transactionController.totalBalance;
    final totalIncome = widget.transactionController.totalIncome;
    final totalExpenses = widget.transactionController.totalExpenses;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Balance Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            CurrencyFormatter.format(totalBalance),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color:
                  totalBalance >= 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  'Ingresos',
                  totalIncome,
                  const Color(0xFF10B981),
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBalanceItem(
                  'Gastos',
                  totalExpenses,
                  const Color(0xFFEF4444),
                  Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget helper para mostrar items del balance (ingresos/gastos)
  Widget _buildBalanceItem(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper para mostrar alertas de presupuesto
  Widget _buildBudgetAlert(
    String title,
    String message,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card que muestra alertas de presupuesto usando el BudgetController
  Widget _buildBudgetAlertsCard() {
    final alerts = widget.budgetController.budgetAlerts;
    final exceededCount = alerts['exceeded'] ?? 0;
    final nearLimitCount = alerts['nearLimit'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estado de Presupuestos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (exceededCount > 0)
            _buildBudgetAlert(
              'Presupuesto Excedido',
              '$exceededCount presupuesto(s) excedido(s)',
              'Revisa tus gastos',
              Icons.warning,
              const Color(0xFFEF4444),
            ),
          if (nearLimitCount > 0)
            _buildBudgetAlert(
              'Cerca del Límite',
              '$nearLimitCount presupuesto(s) cerca del límite',
              'Ten cuidado con los gastos',
              Icons.info,
              const Color(0xFFF59E0B),
            ),
          if (exceededCount == 0 && nearLimitCount == 0)
            _buildBudgetAlert(
              'Todo en Orden',
              'Todos los presupuestos están bajo control',
              'Excelente gestión financiera',
              Icons.check_circle,
              const Color(0xFF10B981),
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso Total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '${widget.budgetController.totalSpentPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            widget.budgetController.totalSpentPercentage > 90
                                ? const Color(0xFFEF4444)
                                : widget.budgetController.totalSpentPercentage >
                                    70
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: widget.budgetController.totalSpentPercentage / 100,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.budgetController.totalSpentPercentage > 90
                          ? const Color(0xFFEF4444)
                          : widget.budgetController.totalSpentPercentage > 70
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card que muestra las transacciones más recientes
  Widget _buildRecentTransactionsCard() {
    final recentTransactions =
        widget.transactionController.transactions.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Transacciones Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // Ir a la pestaña de transacciones
                  });
                },
                icon: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
                label: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentTransactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 48,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No hay transacciones recientes',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final transaction in recentTransactions)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: widget.categoryController
                          .getCategoryColor(transaction.category),
                      child: Icon(
                        transaction.isIncome
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.categoryController.getCategoryName(transaction.category)} • ${_formatDate(transaction.date)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatWithSign(
                        transaction.amount,
                        transaction.isIncome,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color:
                            transaction.isIncome
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
