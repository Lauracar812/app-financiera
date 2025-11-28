class Travel {
  final String id;
  final String title;
  final String destination;
  final double amount;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> imageUrls; // URLs de Firebase Storage
  final List<String> localImagePaths; // Rutas locales de imágenes
  final DateTime createdAt;

  Travel({
    required this.id,
    required this.title,
    required this.destination,
    required this.amount,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.imageUrls = const [],
    this.localImagePaths = const [],
    required this.createdAt,
  });

  /// Copiar con modificaciones
  Travel copyWith({
    String? id,
    String? title,
    String? destination,
    double? amount,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? imageUrls,
    List<String>? localImagePaths,
    DateTime? createdAt,
  }) {
    return Travel(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrls: imageUrls ?? this.imageUrls,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obtener número de días del viaje
  int get travelDays => endDate.difference(startDate).inDays + 1;

  /// Obtener gasto diario
  double get dailyExpense => amount / travelDays;

  /// Serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'amount': amount,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Deserializar desde JSON
  factory Travel.fromJson(Map<String, dynamic> json) {
    return Travel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      destination: json['destination'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      startDate: DateTime.parse(
        json['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  String toString() {
    return 'Travel{id: $id, title: $title, destination: $destination, amount: $amount, days: $travelDays}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Travel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
