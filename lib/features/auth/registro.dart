import 'package:delipan/utils/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();
  final user = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirmPass = TextEditingController();

  bool ocultaPass = true;
  bool ocultaConfirmPass = true;
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    user.dispose();
    email.dispose();
    pass.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (pass.text != confirmPass.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.registerUser(
        username: this.user.text.trim(),
        email: email.text.trim(),
        password: pass.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar. Intenta nuevamente.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 carácteres)';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      default:
        return 'Error al registrar: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Implementamos el mismo contenedor con degradado que en login
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
          child: SingleChildScrollView(
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
              child: Form(
                key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Para que la columna se ajuste al contenido
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
                                  color: AppStyles.primaryBrown
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'REGISTRO',
                                style: AppStyles.bodyText.copyWith(
                                    color: AppStyles.darkGrey,
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
                                color: AppStyles.primaryBrown,
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
                        style: AppStyles.bodyText.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      TextFormField(
                        controller: user,
                        decoration: AppStyles.inputDecoration('Escriba un nombre de usuario').copyWith(
                          errorText: _errorMessage != null && _errorMessage!.contains('usuario') ? _errorMessage : null,
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese un usuario';
                          if (value.length < 3) return 'Mínimo 3 carácteres';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Correo:',
                        textAlign: TextAlign.start,
                        style: AppStyles.bodyText.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      TextFormField(
                        controller: email,
                        decoration: AppStyles.inputDecoration('Escriba un correo electrónico').copyWith(
                          errorText: _errorMessage != null && _errorMessage!.contains('correo') ? _errorMessage : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: Align(
                            widthFactor: 1.0,
                            heightFactor: 1.0,
                            child: Icon(
                              Icons.mail,
                              color: AppStyles.primaryBrown,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese un emal';
                          if (!value.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Contraseña:',
                        textAlign: TextAlign.start,
                        style: AppStyles.bodyText.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      TextFormField(
                        controller: pass,
                        obscureText: ocultaPass,
                        decoration: AppStyles.inputDecoration('Escriba una contraseña').copyWith(
                          errorText: _errorMessage != null && _errorMessage!.contains('contraseña') ? _errorMessage : null,
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese una contraseña';
                          if (value.length < 6) return 'Mínimo 6 carácteres';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Confirmar Contraseña:',
                        textAlign: TextAlign.start,
                        style: AppStyles.bodyText.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      TextFormField(
                        controller: confirmPass,
                        obscureText: ocultaConfirmPass,
                        decoration: AppStyles.inputDecoration('Confirme su contraseña').copyWith(
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
                                ocultaConfirmPass = !ocultaConfirmPass;
                              });
                            },
                            icon: Icon(
                              ocultaConfirmPass ? Icons.visibility : Icons.visibility_off,
                              color: AppStyles.primaryBrown,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != pass.text) return 'La contraseña no coinciden';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Center(
                        child: SizedBox(
                          width: size.width * 0.55,
                          child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: AppStyles.primaryButtonStyle,
                              child: _isLoading ? CircularProgressIndicator(color: AppStyles.white)
                                  : Center(
                                child: Text(
                                  'REGISTRARSE',
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
                    ],
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }
}