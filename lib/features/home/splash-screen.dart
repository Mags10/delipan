import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delipan/utils/styles.dart' as con;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
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
