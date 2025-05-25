
import 'package:delipan/utils/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _ocultaTexto = true;
  bool _isLoading = false;
  String? _usernameError;
  String? _passwordError;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _usernameError = null;
      _passwordError = null;
    });

    try {
      final user = await _authService.loginWithUsernameAndPassword(
          username: _usernameController.text,
          password: _passwordController.text,
      );

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/pago');
        //Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _handleAuthError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _usernameError = 'Error del sistema';
        _passwordError = 'Intentalo nuevamente';
      });
      debugPrint('Error general: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    setState(() {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
        case 'invalid-document':
          _usernameError = 'Usuario no encontrado';
          _passwordError = null;
          break;
        case 'wrong-password':
          _usernameError = null;
          _passwordError = 'Contraseña incorrecta';
          break;
        case 'too-many-requests':
          _usernameError = 'Demasiados intentos';
          _passwordError = 'Cuenta temporalmente bloqueada';
          break;
        case 'user-disabled':
          _usernameError = 'Cuenta deshabilitada';
          _passwordError = 'Contacta con un administrador';
          break;
        case 'firestore-error':
        case 'timeour':
          _usernameError = 'Error de conexión';
          _passwordError = 'Verifique su conexión';
        default:
          _usernameError = 'Error de autenticación';
          _passwordError = 'Verifique sus datos';
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    controller: _usernameController,
                    decoration: AppStyles.inputDecoration('Escriba su usuario').copyWith(
                        errorText: _usernameError,
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
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su usuario';
                      }
                      if (value.length < 3) {
                        return 'Mínimo 3 carácteres';
                      }
                      return null;
                    },
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
                    controller: _passwordController,
                    obscureText: _ocultaTexto,
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
                            _ocultaTexto = !_ocultaTexto;
                          });
                        },
                        icon: Icon(
                          _ocultaTexto ? Icons.visibility_off : Icons.visibility,
                          color: AppStyles.primaryBrown,
                        ),
                      ),
                      errorText: _passwordError,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su contraseña';
                      }
                      if (value.length < 3) {
                        return 'Minimo 3 carácteres';
                      }
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
                          onPressed: _isLoading ? null : _login,
                          style: AppStyles.primaryButtonStyle,
                          child: _isLoading ? CircularProgressIndicator(
                            color: AppStyles.white) : Text(
                            'INGRESAR',
                            style: AppStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
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
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
