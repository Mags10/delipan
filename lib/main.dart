import 'package:delipan/features/home/principal.dart';
import 'package:delipan/features/auth/registro.dart';
import 'package:delipan/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delipan/features/home/splash-screen.dart';
import 'package:delipan/features/auth/login.dart';
import 'package:delipan/config/styles.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  } catch (e) {
    print('Error inicializando Firebase: $e');
  }

  // Configurar UI del sistema a color negro
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
