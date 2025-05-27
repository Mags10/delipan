import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:delipan/services/user_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final isAdmin = await _userService.isCurrentUserAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isLoading = false;
      });

      // Si no es admin, regresar a la página anterior
      if (!isAdmin) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Acceso denegado. Solo los administradores pueden acceder a esta página.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppStyles.lightBrown,
        body: SafeArea(
          child: Column(
            children: [
              // Header personalizado consistente con el resto de la app
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppStyles.lightBrown,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: AppStyles.primaryBrown),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppStyles.primaryBrown,
                      radius: 16,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/Logo_delipan.png',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Administración',
                      style: AppStyles.appTitle.copyWith(fontSize: 28),
                    ),
                    Spacer(),
                    Icon(Icons.admin_panel_settings, color: AppStyles.primaryBrown),
                  ],
                ),
              ),
              // Contenido de loading
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryBrown),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Verificando permisos...',
                        style: AppStyles.bodyText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: AppStyles.lightBrown,
        body: SafeArea(
          child: Column(
            children: [
              // Header personalizado consistente con el resto de la app
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppStyles.lightBrown,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: AppStyles.primaryBrown),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppStyles.primaryBrown,
                      radius: 16,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/Logo_delipan.png',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Acceso Denegado',
                      style: AppStyles.appTitle.copyWith(fontSize: 28),
                    ),
                    Spacer(),
                    Icon(Icons.error_outline, color: Colors.red),
                  ],
                ),
              ),
              // Contenido de acceso denegado
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Acceso Restringido',
                                style: TextStyle(
                                  fontSize: AppStyles.headingFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Solo los administradores pueden acceder al panel de administración.',
                                style: AppStyles.bodyText.copyWith(
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppStyles.primaryBrown,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Volver',
                                  style: TextStyle(fontSize: AppStyles.buttonFontSize),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            // Header personalizado consistente con el resto de la app
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: AppStyles.lightBrown,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: AppStyles.primaryBrown),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppStyles.primaryBrown,
                    radius: 16,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Image.asset(
                        'assets/Logo_delipan.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Panel de Administración',
                    style: AppStyles.appTitle.copyWith(fontSize: 28),
                  ),
                  Spacer(),
                  Icon(Icons.admin_panel_settings, color: AppStyles.primaryBrown),
                ],
              ),
            ),
            // Contenido del panel de administración
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16),
                    // Tarjeta de bienvenida
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppStyles.primaryBrown.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.admin_panel_settings,
                                  color: AppStyles.primaryBrown,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¡Bienvenido, Administrador!',
                                      style: TextStyle(
                                        fontSize: AppStyles.cardTitleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: AppStyles.primaryBrown,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Gestiona tu aplicación Delipan desde aquí',
                                      style: AppStyles.bodyText.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Tarjeta de gestión de base de datos
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.storage,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Gestión de Base de Datos',
                                style: TextStyle(
                                  fontSize: AppStyles.cardTitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppStyles.primaryBrown,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Popula la base de datos de Firebase con productos y categorías de muestra para comenzar a usar la aplicación.',
                            style: AppStyles.bodyText.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implementar funcionalidad
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Funcionalidad en desarrollo'),
                                    backgroundColor: AppStyles.primaryBrown,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Inicializar Base de Datos',
                                style: TextStyle(fontSize: AppStyles.buttonFontSize),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Tarjeta de información del sistema
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Estado del Sistema',
                                style: TextStyle(
                                  fontSize: AppStyles.cardTitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppStyles.primaryBrown,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildSystemStatusItem(
                            icon: Icons.cloud,
                            title: 'Firebase',
                            subtitle: 'Conectado y listo',
                            isOnline: true,
                          ),
                          _buildSystemStatusItem(
                            icon: Icons.shopping_bag,
                            title: 'Productos',
                            subtitle: 'Gestión con Firestore',
                            isOnline: true,
                          ),
                          _buildSystemStatusItem(
                            icon: Icons.shopping_cart,
                            title: 'Carrito',
                            subtitle: 'Sincronización en tiempo real',
                            isOnline: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isOnline,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppStyles.primaryBrown.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppStyles.primaryBrown,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppStyles.textFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppStyles.primaryBrown,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppStyles.bodyText.copyWith(
                    color: Colors.grey[600],
                    fontSize: AppStyles.cardTextFontSize,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.check : Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
