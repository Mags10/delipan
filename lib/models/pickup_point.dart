import 'package:cloud_firestore/cloud_firestore.dart';

class PickupPoint {
  final String? id;
  final String nombre;
  final String direccion;
  final String horario;
  final double distancia;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PickupPoint({
    this.id,
    required this.nombre,
    required this.direccion,
    required this.horario,
    required this.distancia,
    this.latitude,
    this.longitude,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Crear desde Firestore
  factory PickupPoint.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PickupPoint.fromMap(data, doc.id);
  }

  // Crear desde Map
  factory PickupPoint.fromMap(Map<String, dynamic> map, String id) {
    return PickupPoint(
      id: id,
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      horario: map['horario'] ?? '',
      distancia: (map['distancia'] as num?)?.toDouble() ?? 0.0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'horario': horario,
      'distancia': distancia,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Crear copia con cambios
  PickupPoint copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? horario,
    double? distancia,
    double? latitude,
    double? longitude,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PickupPoint(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      horario: horario ?? this.horario,
      distancia: distancia ?? this.distancia,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Obtener distancia formateada
  String get distanciaString => '${distancia.toStringAsFixed(1)} km';

  // Verificar si tiene coordenadas
  bool get hasCoordinates => latitude != null && longitude != null;

  @override
  String toString() {
    return 'PickupPoint{id: $id, nombre: $nombre, direccion: $direccion, distancia: $distancia}';
  }
}
