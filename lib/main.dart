import 'package:flutter/material.dart';
import 'package:delipan/utils/styles.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  // Preservar el splash screen hasta que la app esté lista
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Inicializar la app
  runApp(const MyApp());
  
  // Quitar el splash screen cuando la app esté lista
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delipan',
      debugShowCheckedModeBanner: false, // Quitar etiqueta de debug
      theme: AppStyles.appTheme,
      home: const MyHomePage(title: 'Delipan'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'delipan',
              style: AppStyles.appTitle,
            ),
            const SizedBox(height: 20),
            Text(
              'Aplicación para panadería local',
              style: AppStyles.subtitle,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Explorar productos'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
