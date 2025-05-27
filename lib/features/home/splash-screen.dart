import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delipan/config/styles.dart' as con;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }
  void _checkAuthState() async {
    // Esperamos un poco para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    // Navegamos al AuthWrapper que manejará el estado de autenticación
    Navigator.of(context).pushReplacementNamed('/auth');
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: con.AppStyles.secondaryBrown,
      body: Center(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.41,
              ),
              Image.asset(
                'assets/Logo_delipan.png',
                width: 100,
                height: 100,
              ),
              Text(
                'Delipan',
                style: GoogleFonts.kaushanScript(
                  color: Colors.white,
                  fontSize: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
