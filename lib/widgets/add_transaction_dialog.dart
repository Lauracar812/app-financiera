import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/budget_controller.dart';
import '../models/transaction.dart';
import 'custom_text_fields.dart';
import 'custom_widgets.dart';

/// Diálogo para agregar o editar transacciones.
/// Demuestra cómo los widgets pueden interactuar con múltiples controladores
/// y coordinar operaciones entre ellos.
class AddTransactionDialog extends StatefulWidget {
  final TransactionController transactionController;
  final CategoryController categoryController;
  final BudgetController budgetController;
  final Transaction? existingTransaction;

  const AddTransactionDialog({
    super.key,
    required this.transactionController,
    required this.categoryController,
    required this.budgetController,
    this.existingTransaction,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isIncome = false;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();

    // Si estamos editando, llenar los campos con los datos existentes
    if (_isEditing) {
      final transaction = widget.existingTransaction!;
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description ?? '';
      _isIncome = transaction.isIncome;
      _selectedDate = transaction.date;

      // Validar que la categoría corresponde al tipo de transacción
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categories =
            _isIncome
                ? widget.categoryController.incomeCategories
                : widget.categoryController.expenseCategories;

        if (categories.any((cat) => cat.id == transaction.category)) {
          setState(() {
            _selectedCategoryId = transaction.category;
          });
        } else {
          // Si la categoría no corresponde al tipo, resetear
          setState(() {
            _selectedCategoryId = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar Transacción' : 'Nueva Transacción'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de tipo (Ingreso/Gasto)
                _buildTypeSelector(),
                const SizedBox(height: 16),

                // Campo de título con widget personalizado
                CustomTextField(
                  label: 'Título',
                  hint: 'Ej: Supermercado, Salario, etc.',
                  prefixIcon: Icons.title,
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de cantidad con widget personalizado
                CurrencyTextField(
                  label: 'Cantidad',
                  hint: '0.00',
                  controller: _amountController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La cantidad es requerida';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Ingresa una cantidad válida mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Selector de categoría
                _buildCategorySelector(),
                const SizedBox(height: 16),

                // Selector de fecha
                _buildDateSelector(),
                const SizedBox(height: 16),

                // Campo de descripción (opcional) con widget personalizado
                CustomTextField(
                  label: 'Descripción (Opcional)',
                  hint: 'Detalles adicionales...',
                  prefixIcon: Icons.note,
                  controller: _descriptionController,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        CustomButton(
          text: 'Cancelar',
          isOutlined: true,
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        CustomButton(
          text: _isEditing ? 'Actualizar' : 'Guardar',
          icon: _isEditing ? Icons.update : Icons.save,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _saveTransaction,
          gradientColors: const [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
      ],
    );
  }

  /// Construye el selector de tipo de transacción (Ingreso/Gasto)
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Transacción',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('Gasto'),
              icon: Icon(Icons.arrow_downward, color: Colors.red),
            ),
            ButtonSegment(
              value: true,
              label: Text('Ingreso'),
              icon: Icon(Icons.arrow_upward, color: Colors.green),
            ),
          ],
          selected: {_isIncome},
          onSelectionChanged: (selection) {
            setState(() {
              _isIncome = selection.first;
              _selectedCategoryId = null; // Resetear categoría al cambiar tipo
            });
          },
        ),
      ],
    );
  }

  /// Construye el selector de categoría
  Widget _buildCategorySelector() {
    return AnimatedBuilder(
      animation: widget.categoryController,
      builder: (context, child) {
        final categories =
            _isIncome
                ? widget.categoryController.incomeCategories
                : widget.categoryController.expenseCategories;

        // Validar que la categoría seleccionada esté en la lista filtrada
        final validCategoryId =
            _selectedCategoryId != null &&
                    categories.any((cat) => cat.id == _selectedCategoryId)
                ? _selectedCategoryId
                : null;

        return DropdownButtonFormField<String>(
          value: validCategoryId,
          decoration: const InputDecoration(
            labelText: 'Categoría',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          hint: const Text('Selecciona una categoría'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona una categoría';
            }
            return null;
          },
          items:
              categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(category.color),
                        child: Icon(
                          _getIconData(category.icon),
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
        );
      },
    );
  }

  /// Construye el selector de fecha
  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _formatDate(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// Muestra el selector de fecha
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Guarda o actualiza la transacción
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      final transaction = Transaction(
        id:
            _isEditing
                ? widget.existingTransaction!.id
                : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategoryId!,
        date: _selectedDate,
        isIncome: _isIncome,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
      );

      if (_isEditing) {
        // Si estamos editando, primero actualizar los presupuestos
        final oldTransaction = widget.existingTransaction!;

        // Revertir el impacto del gasto anterior en el presupuesto
        if (!oldTransaction.isIncome) {
          await widget.budgetController.removeExpenseFromBudget(
            oldTransaction.category,
            oldTransaction.amount,
          );
        }

        // Aplicar el nuevo gasto al presupuesto
        if (!transaction.isIncome) {
          await widget.budgetController.addExpenseToBudget(
            transaction.category,
            transaction.amount,
          );
        }

        await widget.transactionController.updateTransaction(transaction);
      } else {
        // Si es una nueva transacción
        await widget.transactionController.addTransaction(transaction);

        // Actualizar presupuesto si es un gasto
        if (!transaction.isIncome) {
          await widget.budgetController.addExpenseToBudget(
            transaction.category,
            transaction.amount,
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Transacción actualizada exitosamente'
                  : 'Transacción agregada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Obtiene el IconData basado en el nombre del icono
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'build':
        return Icons.build;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'work':
        return Icons.work;
      case 'computer':
        return Icons.computer;
      case 'trending_up':
        return Icons.trending_up;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
