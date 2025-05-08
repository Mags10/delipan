import 'package:delipan/features/home/principal.dart';
import 'package:delipan/features/auth/registro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delipan/features/home/splash-screen.dart';
import 'package:delipan/features/auth/login.dart';
import 'package:delipan/config/styles.dart';
import 'package:provider/provider.dart';
import 'package:delipan/models/cart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Configurar UI del sistema para que los iconos sean visibles en fondos claros
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Cambiado a dark para iconos visibles en fondo claro
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => Cart(),
      child: MaterialApp(
        title: 'Delipan',
        debugShowCheckedModeBanner: false, // Quitar etiqueta de debug
        theme: AppStyles.appTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const Login(),
          '/home': (context) => const MyHomePage(title: 'Delipan'),
          '/registro': (context) => const Registro(),
          '/principal': (context) => const Principal()
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Pantalla principal de Delipan'),
      ),
    );
  }
}
