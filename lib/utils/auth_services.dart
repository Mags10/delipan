import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() :
        _auth = FirebaseAuth.instance,
        _firestore= FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> loginWithUsernameAndPassword({
    required String username,
    required String password,
  }) async {
    try {
      /// Se busca el usuario en la db
      final userQuery = await _firestore
          .collection('usuarios')
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userQuery.docs.isEmpty) {
        debugPrint('Usuario no encontrado en Firestore');
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuario no encontrado',
        );
      }

      final userDoc = userQuery.docs.first;
      debugPrint('Documento usuario no encontrado: ${userDoc.id}');

      if (!userDoc.exists || !userDoc.data().containsKey('email')) {
        debugPrint('Estructura de documento inválida');
        throw FirebaseAuthException(
            code: 'invalid-document',
          message: 'Datos de usuario incpmpletos',
        );
      }

      final email = userDoc['email'] as String?;
      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
            code: 'invalid-email',
          message: 'El usuario no tiene un email válido registrado',
        );
      }
      
      debugPrint('Intentado autenticar con email: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password.trim(),
      )
      .timeout(const Duration(seconds: 10));

      debugPrint('Autenticación exitosa: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error de autentificación: ${e.code} - ${e.message}');
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('Error de Firestore: ${e.code} - ${e.message}');
      throw FirebaseAuthException(
          code: 'firestore-error',
          message: 'Error al acceder a los datos',
      );
    } on TimeoutException catch (e) {
      debugPrint('Timeout: $e');
      throw FirebaseAuthException(
          code: 'timeout',
          message: 'Tiempo de espera agotado',
      );
    } catch (e, stack) {
      debugPrint('Error inesperado: $e');
      debugPrint('Stack trace: $stack');
      throw FirebaseAuthException(
        code: 'login-failed',
        message: 'Error al iniciar sesión. Intenta nuevamente',
      );
    }
  }

  Future<User?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error de registro: ${e.code} - ${e.message}');
      throw e;
    } cath (e) {
      debugPrint('Error inesperado al registrar $e');
      throw FirebaseAuthException(
        code: 'registration-failed',
        message: 'Error al registrar usuario',
      );
    }
  }
}