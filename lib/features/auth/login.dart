
import 'package:delipan/utils/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:delipan/features/auth/registro.dart';
import 'package:delipan/features/home/principal.dart';

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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      checkUser = user.text != 'admin' || user.text.isEmpty;
      checkPass = pass.text != '123' || pass.text.isEmpty;
      
      if (!checkUser && !checkPass){
        Navigator.of(context).pushReplacementNamed('/principal');
      }
    });
    debugPrint('Error de autenticación: ${e.code} - ${e.message}');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Cambiamos el backgroundColor por un degradado en el contenedor principal
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppStyles.lightBrown,
              AppStyles.lightBrown,
              AppStyles.lightBrown,
              AppStyles.secondaryBrown.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.width * 0.05),
            // Eliminamos height fijo y dejamos que se ajuste al contenido
            width: size.width * 0.85,
            constraints: BoxConstraints(maxWidth: 450), // Limitamos el ancho máximo
            decoration: BoxDecoration(
              color: AppStyles.mediumBrown,
              borderRadius: BorderRadius.circular(30),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppStyles.black.withOpacity(0.4),
                  blurRadius: 15.0,
                  spreadRadius: 1.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Para que la columna se ajuste al contenido
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppStyles.primaryBrown,
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
                  height: 3,
                ),
                Center(
                  child: Text(
                    'Delipan',
                    style: AppStyles.appTitle.copyWith(
                      fontSize: 32,
                      color: AppStyles.primaryBrown,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  'Usuario:',
                  textAlign: TextAlign.start,
                  style: AppStyles.bodyText.copyWith(
                    fontSize: 16,
                  ),
                ),
                TextFormField(
                  controller: user,
                  decoration: AppStyles.inputDecoration('Escriba su usuario').copyWith(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Icon(
                        Icons.person,
                        color: AppStyles.primaryBrown,
                      ),
                    ),
                    errorText: checkUser ? 'Usuario incorrecta' : null,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Contraseña:',
                  style: AppStyles.bodyText.copyWith(
                    fontSize: 16,
                  ),
                ),
                TextFormField(
                  controller: pass,
                  obscureText: ocultaPass,
                  decoration: AppStyles.inputDecoration('Escriba su contraseña').copyWith(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Icon(
                        Icons.key,
                        color: AppStyles.primaryBrown,
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
                          color: AppStyles.primaryBrown,
                        ),
                    ),
                    errorText: checkPass ? 'Contraseña incorrecta' : null,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Center(
                  child: SizedBox(
                    width: size.width * 0.55,
                    child: ElevatedButton(
                        onPressed: _validaLogin,
                        style: AppStyles.primaryButtonStyle,
                        child: Center(
                          child: Text(
                            'INGRESAR',
                            style: AppStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        )
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    '¿No tienes una cuenta?',
                    style: AppStyles.bodyText.copyWith(
                      fontSize: 15
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                      onPressed: (){
                        setState(() {
                          // Código para registrarse
                          Navigator.of(context).pushReplacementNamed('/registro');
                        });
                      },
                      child: Text(
                        'REGISTRARSE',
                        style: AppStyles.bodyText.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppStyles.darkGrey,
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
