import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para manejar imágenes en múltiples plataformas
class ImageService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Seleccionar múltiples imágenes de la galería
  /// Retorna lista de URLs de datos en base64
  static Future<List<String>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultipleMedia();
      final List<String> imageDataUrls = [];

      for (final image in images) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUrl = 'data:image/jpeg;base64,$base64String';
        imageDataUrls.add(dataUrl);
      }

      return imageDataUrls;
    } catch (e) {
      debugPrint('Error al seleccionar imágenes: $e');
      return [];
    }
  }

  /// Seleccionar una imagen de la cámara
  /// Retorna URL de datos en base64
  static Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      }
      return null;
    } catch (e) {
      debugPrint('Error al capturar imagen: $e');
      return null;
    }
  }

  /// Obtener imagen del archivo (para compatibilidad con mobile)
  static ImageProvider getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      // Es una URL de datos en base64
      final base64String = imageUrl.split(',')[1];
      final decodedBytes = base64Decode(base64String);
      return MemoryImage(decodedBytes);
    } else if (imageUrl.startsWith('http')) {
      // Es una URL de red
      return NetworkImage(imageUrl);
    } else {
      // Es una ruta local (para mobile)
      return AssetImage(imageUrl);
    }
  }

  /// Decodificar base64 a Uint8List
  static Uint8List decodeBase64Image(String base64String) {
    final cleanedString = base64String.split(',').last;
    return base64Decode(cleanedString);
  }

  /// Convertir archivo a base64
  static Future<String> fileToBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
}
