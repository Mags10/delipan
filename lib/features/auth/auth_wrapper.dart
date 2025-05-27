import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delipan/features/auth/login.dart';
import 'package:delipan/features/home/principal.dart';
import 'package:delipan/config/styles.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras se está cargando el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppStyles.lightBrown,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: AppStyles.primaryBrown,
                    radius: 50,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/Logo_delipan.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryBrown),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Verificando sesión...',
                    style: AppStyles.bodyText.copyWith(
                      color: AppStyles.primaryBrown,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Si hay un usuario autenticado
        if (snapshot.hasData && snapshot.data != null) {
          return const Principal();
        }
        
        // Si no hay usuario autenticado
        return const Login();
      },
    );
  }
}
