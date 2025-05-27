import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:delipan/models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Obtener el usuario current
  User? get currentUser => _auth.currentUser;

  // Colección de notificaciones del usuario current
  CollectionReference? get _userNotificationsCollection {
    final user = currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('notifications');
  }

  // Crear una nueva notificación
  Future<bool> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        isRead: false,
        userId: userId,
        data: data,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add(notification.toFirestore());

      return true;
    } catch (e) {
      debugPrint('Error creando notificación: $e');
      return false;
    }
  }

  // Obtener todas las notificaciones del usuario current
  Stream<List<NotificationModel>> getUserNotifications() {
    final notificationsCollection = _userNotificationsCollection;
    if (notificationsCollection == null) {
      return Stream.value([]);
    }

    return notificationsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Marcar notificación como leída
  Future<bool> markAsRead(String notificationId) async {
    try {
      final notificationsCollection = _userNotificationsCollection;
      if (notificationsCollection == null) return false;

      await notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });

      return true;
    } catch (e) {
      debugPrint('Error marcando notificación como leída: $e');
      return false;
    }
  }

  // Marcar todas las notificaciones como leídas
  Future<bool> markAllAsRead() async {
    try {
      final notificationsCollection = _userNotificationsCollection;
      if (notificationsCollection == null) return false;

      final unreadNotifications = await notificationsCollection
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error marcando todas las notificaciones como leídas: $e');
      return false;
    }
  }

  // Eliminar una notificación
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final notificationsCollection = _userNotificationsCollection;
      if (notificationsCollection == null) return false;

      await notificationsCollection.doc(notificationId).delete();
      return true;
    } catch (e) {
      debugPrint('Error eliminando notificación: $e');
      return false;
    }
  }

  // Obtener cantidad de notificaciones no leídas
  Stream<int> getUnreadNotificationsCount() {
    final notificationsCollection = _userNotificationsCollection;
    if (notificationsCollection == null) {
      return Stream.value(0);
    }

    return notificationsCollection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Obtener cantidad de notificaciones no leídas como Future
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error obteniendo conteo de notificaciones no leídas: $e');
      return 0;
    }
  }

  // Crear notificación de pedido confirmado
  Future<bool> createOrderConfirmationNotification({
    required String userId,
    required String orderId,
    required String pickupPointName,
    required String pickupPointAddress,
  }) async {
    return await createNotification(
      userId: userId,
      title: '¡Pedido Confirmado!',
      message: 'Tu pedido ha sido confirmado. Puedes recogerlo en $pickupPointName.',
      type: 'order_confirmation',
      data: {
        'orderId': orderId,
        'pickupPointName': pickupPointName,
        'pickupPointAddress': pickupPointAddress,
        'status': 'confirmed',
      },
    );
  }

  // Crear notificación de pedido listo para recoger
  Future<bool> createOrderReadyNotification({
    required String userId,
    required String orderId,
    required String pickupPointName,
  }) async {
    return await createNotification(
      userId: userId,
      title: '¡Pedido Listo!',
      message: 'Tu pedido está listo para recoger en $pickupPointName.',
      type: 'order_ready',
      data: {
        'orderId': orderId,
        'pickupPointName': pickupPointName,
        'status': 'ready',
      },
    );
  }
}
