import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  // Obtener coordenadas de una dirección
  static Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      final String encodedAddress = Uri.encodeComponent(address);
      final String url = '$_baseUrl/search?q=$encodedAddress&format=json&limit=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'DelipanApp/1.0.0', // Requerido por Nominatim
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          final Map<String, dynamic> result = data.first;
          final double lat = double.parse(result['lat']);
          final double lon = double.parse(result['lon']);
          
          return {
            'latitude': lat,
            'longitude': lon,
          };
        }
      }
      
      return null;
    } catch (e) {
      print('Error en geocodificación: $e');
      return null;
    }
  }

  // Obtener dirección de coordenadas (geocodificación inversa)
  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final String url = '$_baseUrl/reverse?lat=$latitude&lon=$longitude&format=json';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'DelipanApp/1.0.0',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['display_name'];
      }
      
      return null;
    } catch (e) {
      print('Error en geocodificación inversa: $e');
      return null;
    }
  }
  // Calcular distancia aproximada entre dos puntos en km
  static double calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    const double earthRadius = 6371; // Radio de la Tierra en km
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = 
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        (math.sin(dLon / 2) * math.sin(dLon / 2));
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
