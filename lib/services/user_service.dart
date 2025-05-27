import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal() :
        _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  /// Obtiene el rol del usuario actual
  Future<String?> getCurrentUserRole() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore
          .collection('usuarios')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return null;

      final data = userDoc.data();
      return data?['rol'] as String? ?? 'user'; // Por defecto es 'user'
    } catch (e) {
      debugPrint('Error al obtener rol del usuario: $e');
      return null;
    }
  }

  /// Verifica si el usuario actual es administrador
  Future<bool> isCurrentUserAdmin() async {
    final role = await getCurrentUserRole();
    return role == 'admin';
  }

  /// Obtiene la información completa del usuario actual
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore
          .collection('usuarios')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return userDoc.data();
    } catch (e) {
      debugPrint('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  /// Actualiza el rol de un usuario (solo para administradores)
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      // Verificar que el usuario actual es admin
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        debugPrint('Solo los administradores pueden cambiar roles');
        return false;
      }

      await _firestore
          .collection('usuarios')
          .doc(userId)
          .update({'rol': newRole});

      debugPrint('Rol actualizado exitosamente para el usuario $userId');
      return true;
    } catch (e) {
      debugPrint('Error al actualizar rol del usuario: $e');
      return false;
    }
  }

  /// Obtiene todos los usuarios (solo para administradores)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        debugPrint('Solo los administradores pueden ver todos los usuarios');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('usuarios')
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      debugPrint('Error al obtener usuarios: $e');
      return [];
    }
  }

  /// Stream para escuchar cambios en el rol del usuario actual
  Stream<String?> getCurrentUserRoleStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('usuarios')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data();
      return data?['rol'] as String? ?? 'user';
    });
  }
}
