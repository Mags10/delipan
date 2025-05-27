import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class UnsplashService {
  static const String _accessKey = 'Ua1xnAE1kNl8NUDzXOdZvoZBSpZbjB5HA3KM2AhNMM4'; // Reemplazar con tu clave de Unsplash
  static const String _baseUrl = 'https://api.unsplash.com';

  /// Buscar imágenes relacionadas con un producto
  static Future<List<String>> searchProductImages(String productName, {int perPage = 10}) async {
    try {
      // Construir la consulta de búsqueda
      String query = _buildSearchQuery(productName);
      
      final response = await http.get(
        Uri.parse('$_baseUrl/search/photos?query=$query&per_page=$perPage&orientation=landscape'),
        headers: {
          'Authorization': 'Client-ID $_accessKey',
        },
      );      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        return results
            .map((photo) => photo['urls']['regular'] as String)
            .toList();
      } else {
        debugPrint('Error en Unsplash API: ${response.statusCode}');
        throw Exception('Error ${response.statusCode} al buscar imágenes en Unsplash');
      }
    } catch (e) {
      debugPrint('Error buscando imágenes en Unsplash: $e');
      throw Exception('Error de conexión con la API de Unsplash: $e');
    }
  }

  /// Construir consulta de búsqueda optimizada para productos de panadería
  static String _buildSearchQuery(String productName) {
    String baseName = productName.toLowerCase();
    
    // Mapeo de términos para mejorar los resultados de búsqueda
    Map<String, String> termMapping = {
      'pan': 'bread bakery',
      'torta': 'cake pastry',
      'pastel': 'cake dessert',
      'galleta': 'cookie biscuit',
      'empanada': 'empanada pastry',
      'croissant': 'croissant pastry',
      'baguette': 'baguette bread',
      'muffin': 'muffin cupcake',
      'donut': 'donut doughnut',
      'churro': 'churro pastry',
      'bagel': 'bagel bread',
      'pretzel': 'pretzel bread',
      'scone': 'scone pastry',
      'brownie': 'brownie chocolate',
      'pizza': 'pizza dough',
      'sandwich': 'sandwich bread',
    };

    // Buscar coincidencias en el mapeo
    for (String key in termMapping.keys) {
      if (baseName.contains(key)) {
        return termMapping[key]!;
      }
    }

    // Si no se encuentra coincidencia, usar el nombre del producto con términos generales
    return '$baseName bakery food';  }/// Obtener una imagen aleatoria para un producto específico
  static Future<String> getRandomProductImage(String productName) async {
    // Crear una semilla aleatoria única para cada búsqueda
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    
    // Buscar más imágenes para tener variedad con múltiples consultas
    final images = <String>[];
    
    // Primera búsqueda con el término principal (25-30 resultados)
    final primaryImages = await searchProductImages(productName, perPage: 30);
    images.addAll(primaryImages);
    
    // Segunda búsqueda con términos alternativos para mayor variedad
    final alternativeQueries = _getAlternativeQueries(productName);
    if (alternativeQueries.isNotEmpty) {
      final randomQuery = alternativeQueries[random.nextInt(alternativeQueries.length)];
      final alternativeImages = await searchProductImages(randomQuery, perPage: 20);
      images.addAll(alternativeImages);
    }
    
    // Tercera búsqueda con términos más generales si hay pocos resultados
    if (images.length < 15) {
      final generalTerms = [
        'bakery products', 'artisan bread', 'fresh pastries', 
        'homemade desserts', 'gourmet food', 'bakery display',
        'pastry shop', 'delicious treats', 'baked goods'
      ];
      final randomTerm = generalTerms[random.nextInt(generalTerms.length)];
      final generalImages = await searchProductImages(randomTerm, perPage: 25);
      images.addAll(generalImages);
    }
      if (images.isNotEmpty) {
      // Eliminar duplicados y usar Random con semilla para mejor aleatoriedad
      final uniqueImages = images.toSet().toList();
      final index = random.nextInt(uniqueImages.length);
      return uniqueImages[index];
    } else {
      // Si no hay imágenes de la API, lanzar error
      throw Exception('No se encontraron imágenes para el producto "$productName"');
    }
  }

  /// Obtener consultas alternativas para un producto
  static List<String> _getAlternativeQueries(String productName) {
    String baseName = productName.toLowerCase();
    
    // Términos alternativos por tipo de producto
    Map<String, List<String>> alternatives = {
      'pan': ['sourdough bread', 'artisan loaf', 'fresh bread', 'homemade bread'],
      'torta': ['layer cake', 'birthday cake', 'chocolate cake', 'vanilla cake'],
      'pastel': ['cupcake', 'mini cake', 'decorated cake', 'sweet pastry'],
      'galleta': ['chocolate chip cookie', 'sugar cookie', 'oatmeal cookie', 'biscuit'],
      'empanada': ['stuffed pastry', 'hand pie', 'savory turnover', 'filled dough'],
      'croissant': ['buttery croissant', 'french pastry', 'flaky pastry', 'morning pastry'],
      'muffin': ['blueberry muffin', 'chocolate muffin', 'banana muffin', 'breakfast muffin'],
      'donut': ['glazed donut', 'chocolate donut', 'fresh donut', 'fried pastry'],
      'churro': ['spanish churro', 'cinnamon pastry', 'fried dough', 'sweet stick'],
    };

    List<String> result = [];
    
    // Buscar coincidencias y agregar alternativas
    for (String key in alternatives.keys) {
      if (baseName.contains(key)) {
        result.addAll(alternatives[key]!);
        break;
      }
    }
    
    // Si no se encontraron alternativas específicas, usar genéricas
    if (result.isEmpty) {
      result = [
        'artisan bakery', 'fresh baked goods', 'gourmet pastry',
        'homemade treats', 'bakery specialties', 'delicious food'
      ];
    }
    
    return result;
  }
}
