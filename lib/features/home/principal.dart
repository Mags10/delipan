import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bienvenido a Delipan',
                      style: AppStyles.heading,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Contenido principal aquí',
                      style: AppStyles.bodyText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppStyles.lightBrown,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          CircleAvatar(
            backgroundColor: AppStyles.primaryBrown,
            radius: 24,
            child: Padding(
              padding: EdgeInsets.all(6.0),
              child: Image.asset(
                'assets/Logo_delipan.png',
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12),
          // Título
          Text(
            'Delipan',
            style: AppStyles.appTitle,
          ),
          Spacer(),
          // Iconos de acción
          IconButton(
            icon: Icon(Icons.person_outline, color: AppStyles.primaryBrown),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: AppStyles.primaryBrown),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: AppStyles.primaryBrown),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
