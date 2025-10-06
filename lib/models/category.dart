// Modelo para representar una categoría de gastos/ingresos
class Category {
  final String id;
  final String name;
  final String icon; // nombre del icono
  final int color; // código de color
  final bool
  isIncomeCategory; // true para categorías de ingresos, false para gastos

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isIncomeCategory,
  });

  // Constructor para crear una categoría desde un Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'category',
      color: map['color'] ?? 0xFF2196F3,
      isIncomeCategory: map['isIncomeCategory'] ?? false,
    );
  }

  // Convertir la categoría a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isIncomeCategory': isIncomeCategory,
    };
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, icon: $icon, isIncomeCategory: $isIncomeCategory}';
  }
}
