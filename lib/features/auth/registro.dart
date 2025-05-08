import 'package:flutter/material.dart';
import 'package:delipan/constantes.dart' as con;
import 'package:google_fonts/google_fonts.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return  Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: con.fondo4,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(size.width * 0.04),
          height: size.height * 0.9,
          width: size.width * 0.87,
          decoration: BoxDecoration(
            color: con.fondo3,
            borderRadius: BorderRadius.circular(30),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: con.fondo7.withOpacity(0.4),
                blurRadius: 15.0,
                spreadRadius: 1.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: (){
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text(
                        String.fromCharCode(Icons.arrow_back.codePoint),
                        style: TextStyle(
                          inherit: false,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          fontFamily: Icons.arrow_back.fontFamily,
                          color: con.fondo2
                        ),
                      ),
                  ),
                  Expanded(
                      child: Center(
                        child: Text(
                          'REGISTRO',
                          style: TextStyle(
                              color: con.text4,
                              fontWeight: FontWeight.w700,
                              fontSize: 23
                          ),
                        ),
                      ),
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: con.fondo2,
                        borderRadius: BorderRadius.circular(180),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/Logo_delipan.png',
                          width: 30,
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 35,
              ),
              Text(
                'Usuario:',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  color: con.text2,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: con.fondo4,
                  hintText: 'Escriba un nombre usuario',
                  hintStyle: TextStyle(
                    color: con.text2.withOpacity(0.4),
                  ),
                  prefixIcon: Align(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Icon(
                      Icons.person,
                      color: con.fondo2,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Correo:',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  color: con.text2,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: con.fondo4,
                  hintText: 'Escriba un correo electrónico',
                  hintStyle: TextStyle(
                    color: con.text2.withOpacity(0.4),
                  ),
                  prefixIcon: Align(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Icon(
                      Icons.mail,
                      color: con.fondo2,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Contraseña:',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  color: con.text2,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: con.fondo4,
                  hintText: 'Escriba una contraseña',
                  hintStyle: TextStyle(
                    color: con.text2.withOpacity(0.4),
                  ),
                  prefixIcon: Align(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Icon(
                      Icons.key,
                      color: con.fondo2,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Confirmar Contraseña:',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  color: con.text2,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: con.fondo4,
                  hintText: 'Confirme su contraseña',
                  hintStyle: TextStyle(
                    color: con.text2.withOpacity(0.4),
                  ),
                  prefixIcon: Align(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Icon(
                      Icons.key,
                      color: con.fondo2,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 65,
              ),
              Center(
                child: SizedBox(
                  width: size.width * 0.55,
                  child: ElevatedButton(
                      onPressed: (){},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: con.fondo1,
                        foregroundColor: con.fondo4,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                              (states) {
                            if (states.contains(MaterialState.pressed)) {
                              return con.fondo2.withOpacity(0.2);
                            }
                            return con.fondo1;
                          },
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'REGISTRARSE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: con.text3,
                          ),
                        ),
                      )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
