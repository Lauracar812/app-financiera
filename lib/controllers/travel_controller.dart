import 'package:flutter/foundation.dart';
import '../models/travel.dart';

class TravelController extends ChangeNotifier {
  // ==========================================
  // ESTADO PRIVADO
  // ==========================================

  List<Travel> _travels = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ==========================================
  // GETTERS PÚBLICOS
  // ==========================================

  List<Travel> get travels => List.unmodifiable(_travels);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Calcula el gasto total en viajes
  double get totalTravelExpense {
    return _travels.fold(0.0, (sum, travel) => sum + travel.amount);
  }

  /// Obtiene viajes ordenados por fecha más reciente
  List<Travel> get travelsByDate {
    final sorted = List<Travel>.from(_travels);
    sorted.sort((a, b) => b.startDate.compareTo(a.startDate));
    return sorted;
  }

  /// Obtiene un viaje por ID
  Travel? getTravelById(String travelId) {
    try {
      return _travels.firstWhere((t) => t.id == travelId);
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // MÉTODOS PRIVADOS
  // ==========================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _sortTravelsByDate() {
    _travels.sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  // ==========================================
  // OPERACIONES CRUD - VIAJES
  // ==========================================

  /// Agregar nuevo viaje
  /// CRÍTICO: Descuenta del balance total
  Future<void> addTravel(Travel travel) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simular delay de operación
      await Future.delayed(const Duration(milliseconds: 500));

      // Validar que no sea viaje duplicado
      bool exists = _travels.any(
        (t) => t.title.toLowerCase() == travel.title.toLowerCase(),
      );
      if (exists) {
        throw Exception('Ya existe un viaje con este nombre');
      }

      _travels.add(travel);
      _sortTravelsByDate();

      notifyListeners();
    } catch (e) {
      _setError('Error al agregar viaje: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar viaje existente
  Future<void> updateTravel(Travel updatedTravel) async {
    _setLoading(true);
    _setError(null);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _travels.indexWhere((t) => t.id == updatedTravel.id);
      if (index != -1) {
        _travels[index] = updatedTravel;
        _sortTravelsByDate();
        notifyListeners();
      } else {
        throw Exception('Viaje no encontrado');
      }
    } catch (e) {
      _setError('Error al actualizar viaje: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar viaje
  /// CRÍTICO: Recupera el gasto del balance
  Future<void> deleteTravel(String travelId) async {
    _setLoading(true);
    _setError(null);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _travels.removeWhere((t) => t.id == travelId);
      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar viaje: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar imagen local a un viaje
  Future<void> addLocalImageToTravel(String travelId, String imagePath) async {
    try {
      final travel = getTravelById(travelId);
      if (travel != null) {
        final newLocalPaths = List<String>.from(travel.localImagePaths);
        if (!newLocalPaths.contains(imagePath)) {
          newLocalPaths.add(imagePath);
          await updateTravel(travel.copyWith(localImagePaths: newLocalPaths));
        }
      }
    } catch (e) {
      _setError('Error al agregar imagen: $e');
    }
  }

  /// Eliminar imagen local de un viaje
  Future<void> removeLocalImageFromTravel(
    String travelId,
    String imagePath,
  ) async {
    try {
      final travel = getTravelById(travelId);
      if (travel != null) {
        final newLocalPaths = List<String>.from(travel.localImagePaths);
        newLocalPaths.removeWhere((p) => p == imagePath);
        await updateTravel(travel.copyWith(localImagePaths: newLocalPaths));
      }
    } catch (e) {
      _setError('Error al eliminar imagen: $e');
    }
  }

  /// Obtener viajes por rango de fechas
  List<Travel> getTravelsByDateRange(DateTime start, DateTime end) {
    return _travels
        .where(
          (t) =>
              t.startDate.isAfter(start.subtract(const Duration(days: 1))) &&
              t.startDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Obtener viaje más próximo
  Travel? getUpcomingTravel() {
    final now = DateTime.now();
    final upcoming = _travels.where((t) => t.startDate.isAfter(now)).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.first;
  }

  // ==========================================
  // DATOS INICIALES
  // ==========================================

  Future<void> loadInitialData() async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      _travels = [
        Travel(
          id: '1',
          title: 'Viaje a Cartagena',
          destination: 'Cartagena, Colombia',
          amount: 500000.0,
          description: 'Vacaciones familiares en la costa caribeña',
          startDate: DateTime.now().subtract(const Duration(days: 10)),
          endDate: DateTime.now().subtract(const Duration(days: 5)),
          imageUrls: [],
          localImagePaths: [],
          createdAt: DateTime.now(),
        ),
        Travel(
          id: '2',
          title: 'Viaje a Santa Marta',
          destination: 'Santa Marta, Colombia',
          amount: 350000.0,
          description: 'Visita a la Ciudad Perdida',
          startDate: DateTime.now().add(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 18)),
          imageUrls: [],
          localImagePaths: [],
          createdAt: DateTime.now(),
        ),
      ];

      _sortTravelsByDate();
    } catch (e) {
      _setError('Error al cargar viajes: $e');
    } finally {
      _setLoading(false);
    }
  }
}
