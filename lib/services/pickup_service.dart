import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delipan/models/pickup_point.dart';

class PickupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colección de puntos de recogida en Firestore
  CollectionReference get _pickupPointsCollection => _firestore.collection('pickup_points');
  // Obtener todos los puntos de recogida activos
  Stream<List<PickupPoint>> getPickupPoints() {
    return _pickupPointsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          List<PickupPoint> points = snapshot.docs
              .map((doc) => PickupPoint.fromFirestore(doc))
              .toList();
          
          // Ordenar por distancia en el cliente para evitar índice compuesto
          points.sort((a, b) => a.distancia.compareTo(b.distancia));
          return points;
        });
  }

  // Obtener punto de recogida por ID
  Future<PickupPoint?> getPickupPointById(String id) async {
    try {
      DocumentSnapshot doc = await _pickupPointsCollection.doc(id).get();
      if (doc.exists) {
        return PickupPoint.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo punto de recogida: $e');
      return null;
    }
  }

  // Agregar nuevo punto de recogida
  Future<String?> addPickupPoint(PickupPoint pickupPoint) async {
    try {
      DocumentReference docRef = await _pickupPointsCollection.add(pickupPoint.toMap());
      return docRef.id;
    } catch (e) {
      print('Error agregando punto de recogida: $e');
      return null;
    }
  }

  // Actualizar punto de recogida
  Future<bool> updatePickupPoint(String id, PickupPoint pickupPoint) async {
    try {
      await _pickupPointsCollection.doc(id).update(pickupPoint.toMap());
      return true;
    } catch (e) {
      print('Error actualizando punto de recogida: $e');
      return false;
    }
  }

  // Eliminar punto de recogida (soft delete)
  Future<bool> deletePickupPoint(String id) async {
    try {
      await _pickupPointsCollection.doc(id).update({'isActive': false});
      return true;
    } catch (e) {
      print('Error eliminando punto de recogida: $e');
      return false;
    }
  }

  // Obtener todos los puntos de recogida para administración
  Stream<List<PickupPoint>> getAllPickupPointsForAdmin() {
    return _pickupPointsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PickupPoint.fromFirestore(doc))
            .toList());
  }
}
