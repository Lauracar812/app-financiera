import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../controllers/travel_controller.dart';
import '../models/travel.dart';
import '../widgets/add_travel_dialog.dart';
import '../services/image_service.dart';

class TravelsView extends StatefulWidget {
  final TravelController travelController;

  const TravelsView({super.key, required this.travelController});

  @override
  State<TravelsView> createState() => _TravelsViewState();
}

class _TravelsViewState extends State<TravelsView> {
  late TravelController _travelController;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Inicializar locale para DateFormat
    initializeDateFormatting('es_ES', null);
    _travelController = widget.travelController;
    _travelController.loadInitialData();
    _travelController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _travelController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _showAddTravelDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddTravelDialog(travelController: _travelController),
    );
  }

  void _showTravelDetail(Travel travel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => _TravelDetailModal(
            travel: travel,
            travelController: _travelController,
            onDelete: () => Navigator.pop(context),
          ),
    );
  }

  void _editTravel(Travel travel) {
    showDialog(
      context: context,
      builder:
          (context) => AddTravelDialog(
            travelController: _travelController,
            travel: travel,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Viajes'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_3x3),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'Vista de lista' : 'Vista de cuadrícula',
          ),
        ],
      ),
      body:
          _travelController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildTravelsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTravelDialog,
        tooltip: 'Agregar viaje',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTravelsList() {
    final travels = _travelController.travelsByDate;

    if (travels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight_takeoff, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay viajes registrados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primer viaje para comenzar',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: _isGridView ? _buildGridView(travels) : _buildListView(travels),
    );
  }

  Widget _buildGridView(List<Travel> travels) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: travels.length,
      itemBuilder: (context, index) {
        final travel = travels[index];
        return _buildTravelCard(travel);
      },
    );
  }

  Widget _buildListView(List<Travel> travels) {
    return ListView.builder(
      itemCount: travels.length,
      itemBuilder: (context, index) {
        final travel = travels[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildTravelListItem(travel),
        );
      },
    );
  }

  Widget _buildTravelCard(Travel travel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTravelDetail(travel),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de portada
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey[200],
                ),
                child:
                    travel.localImagePaths.isNotEmpty
                        ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image(
                            image: ImageService.getImageProvider(
                              travel.localImagePaths.first,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildPlaceholder(),
                          ),
                        )
                        : _buildPlaceholder(),
              ),
            ),
            // Información del viaje
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          travel.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          travel.destination,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '\$${travel.amount.toStringAsFixed(0)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        PopupMenuButton(
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  onTap: () => _editTravel(travel),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: () => _deleteTravel(travel.id),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelListItem(Travel travel) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es_ES');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showTravelDetail(travel),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Miniatura de imagen
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child:
                    travel.localImagePaths.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image(
                            image: ImageService.getImageProvider(
                              travel.localImagePaths.first,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildPlaceholder(),
                          ),
                        )
                        : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travel.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      travel.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dateFormat.format(travel.startDate)} a ${dateFormat.format(travel.endDate)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Monto y menú
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${travel.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            onTap: () => _editTravel(travel),
                            child: const Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () => _deleteTravel(travel.id),
                            child: const Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.flight_takeoff, size: 32, color: Colors.grey[400]),
      ),
    );
  }

  void _deleteTravel(String travelId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar viaje'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este viaje?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  _travelController.deleteTravel(travelId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viaje eliminado')),
                  );
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

// ================================================
// MODAL DE DETALLE DEL VIAJE
// ================================================

class _TravelDetailModal extends StatefulWidget {
  final Travel travel;
  final TravelController travelController;
  final VoidCallback onDelete;

  const _TravelDetailModal({
    required this.travel,
    required this.travelController,
    required this.onDelete,
  });

  @override
  State<_TravelDetailModal> createState() => _TravelDetailModalState();
}

class _TravelDetailModalState extends State<_TravelDetailModal> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es_ES');
    final startDate = dateFormat.format(widget.travel.startDate);
    final endDate = dateFormat.format(widget.travel.endDate);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.travel.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.travel.destination,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Galería de imágenes
                  if (widget.travel.localImagePaths.isNotEmpty)
                    _buildImageGallery(),
                  const SizedBox(height: 16),

                  // Información principal
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Fechas',
                    value: '$startDate a $endDate',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: 'Destino',
                    value: widget.travel.destination,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.monetization_on,
                    title: 'Gasto Total',
                    value: '\$${widget.travel.amount.toStringAsFixed(0)}',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.hotel,
                    title: 'Días de viaje',
                    value: '${widget.travel.travelDays} días',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Gasto diario promedio',
                    value: '\$${widget.travel.dailyExpense.toStringAsFixed(0)}',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  if (widget.travel.description.isNotEmpty) ...[
                    Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.travel.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Aquí irá la lógica de edición
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.travelController.deleteTravel(
                              widget.travel.id,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Viaje eliminado')),
                            );
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.travel.localImagePaths.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  image: ImageService.getImageProvider(
                    widget.travel.localImagePaths[index],
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.travel.localImagePaths.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentImageIndex == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color:
                    _currentImageIndex == index
                        ? Colors.blue
                        : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
