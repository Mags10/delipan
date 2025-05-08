import 'package:flutter/material.dart';
import 'package:delipan/constantes.dart' as con;
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final user = TextEditingController();
  final pass = TextEditingController();
  bool checkUser = false;
  bool checkPass = false;
  bool ocultaPass = true;

  void _validaLogin() {
    setState(() {
      checkUser = user.text != 'admin' || user.text.isEmpty;
      checkPass = pass.text != '123' || pass.text.isEmpty;
      
      if (!checkUser && !checkPass){
        Navigator.of(context).pushReplacementNamed('/principal');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;


    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: con.fondo4,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(size.width * 0.08),
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
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: con.fondo2,
                    borderRadius: BorderRadius.circular(180),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/Logo_delipan.png',
                      width: 60,
                      height: 75,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Center(
                child: Text(
                  'Delipan',
                  style: GoogleFonts.kaushanScript(
                    color: con.text4,
                    fontSize: 32,
                  ),
                ),
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
                controller: user,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: con.fondo4,
                  hintText: 'Escriba su usuario',
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
                  errorText: checkUser ? 'Usuario incorrecta' : null,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Contraseña:',
                style: TextStyle(
                  fontSize: 16,
                  color: con.text2,
                ),
              ),
              TextFormField(
                controller: pass,
                obscureText: ocultaPass,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: con.fondo4,
                  hintText: 'Escriba su contraseña',
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
                  suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          ocultaPass = !ocultaPass;
                        });
                      },
                      icon: Icon(
                          ocultaPass ? Icons.visibility : Icons.visibility_off,
                        color: con.fondo2,
                      ),
                  ),
                  errorText: checkPass ? 'Contraseña incorrecta' : null,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: SizedBox(
                  width: size.width * 0.55,
                  child: ElevatedButton(
                      onPressed: _validaLogin,
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
                          'INGRESAR',
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
              SizedBox(
                height: 50,
              ),
              Center(
                child: Text(
                  '¿No tienes una cuenta?',
                  style: TextStyle(
                    color: con.text2,
                    fontSize: 15
                  ),
                ),
              ),
              Center(
                child: TextButton(
                    onPressed: (){
                      setState(() {
                        Navigator.of(context).pushReplacementNamed('/registro');
                      });
                    },
                    child: Text(
                      'REGISTRARSE',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: con.text2,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
