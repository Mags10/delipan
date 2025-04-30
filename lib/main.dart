import 'package:delipan/principal.dart';
import 'package:delipan/registro.dart';
import 'package:flutter/material.dart';
import 'package:delipan/splash-screen.dart';
import 'package:delipan/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delipan',
      debugShowCheckedModeBanner: false, // Quitar etiqueta de debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
