import 'package:flutter/material.dart';
import '../widgets/custom_text_fields.dart';
import '../widgets/custom_widgets.dart';
import '../controllers/category_controller.dart';
import '../controllers/budget_controller.dart';
import '../controllers/transaction_controller.dart';

/// Vista de configuración que demuestra el uso de entradas de texto personalizadas
/// y widgets personalizados para mejorar la experiencia del usuario
class SettingsView extends StatefulWidget {
  final CategoryController categoryController;
  final BudgetController budgetController;
  final TransactionController transactionController;

  const SettingsView({
    super.key,
    required this.categoryController,
    required this.budgetController,
    required this.transactionController,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controladores para los campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _budgetLimitController = TextEditingController();
  final _savingsGoalController = TextEditingController();
  final _searchController = TextEditingController();
  
  // Variables de estado
  List<String> _financialGoals = ['Ahorrar para vacaciones', 'Fondo de emergencia'];
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  int _selectedCurrency = 0;
  int _selectedTabIndex = 0;

  final List<String> _currencies = ['COP (Peso Colombiano)', 'USD (Dólar)', 'EUR (Euro)'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    
    // Inicializar con datos de ejemplo
    _nameController.text = 'Usuario Demo';
    _emailController.text = 'usuario@demo.com';
    _phoneController.text = '+57 300 123 4567';
    _budgetLimitController.text = '2000000';
    _savingsGoalController.text = '5000000';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _budgetLimitController.dispose();
    _savingsGoalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            color: const Color(0xFF6366F1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTabBar(
                tabs: const [
                  CustomTab(text: 'Personal', icon: Icons.person),
                  CustomTab(text: 'Financiero', icon: Icons.account_balance_wallet),
                  CustomTab(text: 'Preferencias', icon: Icons.settings),
                ],
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  _tabController.animateTo(index);
                },
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF8FAFC),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPersonalTab(),
            _buildFinancialTab(),
            _buildPreferencesTab(),
          ],
        ),
      ),
    );
  }

  /// Pestaña de información personal
  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con avatar
          _buildProfileHeader(),
          const SizedBox(height: 24),
          
          // Información personal
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Campo de nombre
                CustomTextField(
                  label: 'Nombre Completo',
                  hint: 'Ingresa tu nombre completo',
                  prefixIcon: Icons.person,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo de email
                CustomTextField(
                  label: 'Correo Electrónico',
                  hint: 'usuario@ejemplo.com',
                  prefixIcon: Icons.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El email es requerido';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo de teléfono
                CustomTextField(
                  label: 'Teléfono',
                  hint: '+57 300 123 4567',
                  prefixIcon: Icons.phone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El teléfono es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Botón de actualizar
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Actualizar Información',
                    icon: Icons.save,
                    gradientColors: const [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                    onPressed: () {
                      _showSuccessMessage('Información actualizada correctamente');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pestaña de configuración financiera
  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Estadísticas rápidas
          _buildQuickStats(),
          const SizedBox(height: 20),
          
          // Configuración de límites
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.savings,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Límites y Metas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Límite de presupuesto mensual
                CurrencyTextField(
                  label: 'Límite de Presupuesto Mensual',
                  hint: 'Ingresa tu límite mensual',
                  controller: _budgetLimitController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El límite es requerido';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Meta de ahorro
                CurrencyTextField(
                  label: 'Meta de Ahorro',
                  hint: 'Ingresa tu meta de ahorro',
                  controller: _savingsGoalController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La meta es requerida';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Progreso de la meta
                _buildSavingsProgress(),
                const SizedBox(height: 20),
                
                // Campo de metas financieras con etiquetas
                TagTextField(
                  label: 'Metas Financieras',
                  hint: 'Agregar nueva meta...',
                  tags: _financialGoals,
                  onTagsChanged: (newTags) {
                    setState(() {
                      _financialGoals = newTags;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Guardar Límites',
                        icon: Icons.save,
                        onPressed: () {
                          _showSuccessMessage('Límites guardados correctamente');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Resetear',
                        icon: Icons.refresh,
                        isOutlined: true,
                        onPressed: () {
                          _resetFinancialSettings();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pestaña de preferencias de la aplicación
  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Búsqueda
          SearchTextField(
            hint: 'Buscar configuración...',
            controller: _searchController,
            onChanged: (value) {
              // Implementar lógica de búsqueda
              print('Buscando: $value');
            },
            onClear: () {
              print('Búsqueda limpiada');
            },
          ),
          const SizedBox(height: 20),
          
          // Configuraciones generales
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferencias Generales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Selector de moneda
                _buildCurrencySelector(),
                const SizedBox(height: 16),
                
                // Switch de notificaciones
                _buildSettingSwitch(
                  'Notificaciones Push',
                  'Recibir alertas de gastos y presupuestos',
                  Icons.notifications,
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Switch de modo oscuro
                _buildSettingSwitch(
                  'Modo Oscuro',
                  'Activar tema oscuro para la aplicación',
                  Icons.dark_mode,
                  _darkModeEnabled,
                  (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Acciones rápidas
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// Header del perfil con avatar
  Widget _buildProfileHeader() {
    return CustomCard(
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF6366F1),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text
                      : 'Usuario Demo',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailController.text.isNotEmpty
                      ? _emailController.text
                      : 'usuario@demo.com',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Premium User',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Estadísticas rápidas
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: AnimatedStatCard(
            title: 'Gastado Este Mes',
            value: '\$1,250,000',
            icon: Icons.trending_down,
            color: const Color(0xFFEF4444),
            subtitle: '+15% vs mes anterior',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedStatCard(
            title: 'Ahorrado',
            value: '\$850,000',
            icon: Icons.savings,
            color: const Color(0xFF10B981),
            subtitle: 'Meta: \$5,000,000',
          ),
        ),
      ],
    );
  }

  /// Progreso de ahorro
  Widget _buildSavingsProgress() {
    final savingsGoal = double.tryParse(_savingsGoalController.text) ?? 5000000;
    final currentSavings = 850000.0; // Ejemplo
    final progress = currentSavings / savingsGoal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de Ahorro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CustomProgressIndicator(
                value: progress,
                color: const Color(0xFF10B981),
                size: 60,
                strokeWidth: 6,
                centerText: '${(progress * 100).toInt()}%',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahorrado: \$850,000',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Meta: \$${savingsGoal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Selector de moneda
  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Moneda Principal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButton<int>(
            value: _selectedCurrency,
            isExpanded: true,
            underline: Container(),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: _currencies.asMap().entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value ?? 0;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Switch de configuración
  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  /// Acciones rápidas
  Widget _buildQuickActions() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Exportar Datos',
                  icon: Icons.download,
                  isOutlined: true,
                  backgroundColor: const Color(0xFF10B981),
                  onPressed: () {
                    _showSuccessMessage('Datos exportados correctamente');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Respaldar',
                  icon: Icons.backup,
                  isOutlined: true,
                  backgroundColor: const Color(0xFFF59E0B),
                  onPressed: () {
                    _showSuccessMessage('Respaldo creado correctamente');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Resetear configuraciones financieras
  void _resetFinancialSettings() {
    setState(() {
      _budgetLimitController.clear();
      _savingsGoalController.clear();
      _financialGoals.clear();
    });
    _showSuccessMessage('Configuraciones reseteadas');
  }

  /// Mostrar mensaje de éxito
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}