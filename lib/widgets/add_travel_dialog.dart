import 'package:flutter/material.dart';
import '../controllers/travel_controller.dart';
import '../models/travel.dart';
import '../services/image_service.dart';

class AddTravelDialog extends StatefulWidget {
  final TravelController travelController;
  final Travel? travel;

  const AddTravelDialog({
    super.key,
    required this.travelController,
    this.travel,
  });

  @override
  State<AddTravelDialog> createState() => _AddTravelDialogState();
}

class _AddTravelDialogState extends State<AddTravelDialog> {
  late TextEditingController _titleController;
  late TextEditingController _destinationController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  List<String> _selectedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.travel?.title ?? '');
    _destinationController = TextEditingController(
      text: widget.travel?.destination ?? '',
    );
    _amountController = TextEditingController(
      text: widget.travel?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.travel?.description ?? '',
    );
    _startDate = widget.travel?.startDate ?? DateTime.now();
    _endDate =
        widget.travel?.endDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedImages = List.from(widget.travel?.localImagePaths ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final imageUrls = await ImageService.pickMultipleImages();
      if (imageUrls.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(imageUrls);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imágenes: $e')),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final imageUrl = await ImageService.pickImageFromCamera();
      if (imageUrl != null) {
        setState(() {
          _selectedImages.add(imageUrl);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al capturar imagen: $e')),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveTravel() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el título del viaje')),
      );
      return;
    }

    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el destino')),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el monto del viaje')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      if (widget.travel != null) {
        // Actualizar viaje existente
        final updatedTravel = widget.travel!.copyWith(
          title: _titleController.text,
          destination: _destinationController.text,
          amount: amount,
          description: _descriptionController.text,
          startDate: _startDate,
          endDate: _endDate,
          localImagePaths: _selectedImages,
        );

        await widget.travelController.updateTravel(updatedTravel);
      } else {
        // Crear nuevo viaje
        final newTravel = Travel(
          id: DateTime.now().toString(),
          title: _titleController.text,
          destination: _destinationController.text,
          amount: amount,
          description: _descriptionController.text,
          startDate: _startDate,
          endDate: _endDate,
          imageUrls: [],
          localImagePaths: _selectedImages,
          createdAt: DateTime.now(),
        );

        await widget.travelController.addTravel(newTravel);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.travel != null
                  ? 'Viaje actualizado exitosamente'
                  : 'Viaje agregado exitosamente',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.travel != null ? 'Editar Viaje' : 'Nuevo Viaje',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Título
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título del viaje',
                  hintText: 'Ej: Viaje a Cartagena',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.flight_takeoff),
                ),
              ),
              const SizedBox(height: 16),

              // Destino
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Destino',
                  hintText: 'Ej: Cartagena, Colombia',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Monto
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Monto del viaje',
                  hintText: 'Ej: 500000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.monetization_on),
                  suffix: const Text('COP'),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Detalles del viaje...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Fechas
              Text(
                'Fechas del viaje',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectStartDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectEndDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sección de imágenes
              Text(
                'Galería de imágenes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text('Galería'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Vistaprevia de imágenes
              if (_selectedImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Imágenes seleccionadas (${_selectedImages.length})',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image(
                                      image: ImageService.getImageProvider(
                                        _selectedImages[index],
                                      ),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -8,
                                  right: -8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTravel,
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                widget.travel != null
                                    ? 'Actualizar'
                                    : 'Guardar',
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
}
