import 'package:flutter/material.dart';
import 'package:delipan/services/user_service.dart';

/// Widget que muestra contenido solo si el usuario es administrador
class AdminOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return StreamBuilder<String?>(
      stream: userService.getCurrentUserRoleStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Mientras carga, no muestra nada
        }

        final role = snapshot.data;
        final isAdmin = role == 'admin';

        if (isAdmin) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}

/// Widget que oculta contenido solo si el usuario es administrador
class NonAdminOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const NonAdminOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return StreamBuilder<String?>(
      stream: userService.getCurrentUserRoleStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return child; // Mientras carga, muestra el contenido por defecto
        }

        final role = snapshot.data;
        final isAdmin = role == 'admin';

        if (!isAdmin) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}

/// FutureBuilder para verificar si el usuario es admin
class AdminCheckWidget extends StatelessWidget {
  final Widget Function(bool isAdmin) builder;

  const AdminCheckWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return FutureBuilder<bool>(
      future: userService.isCurrentUserAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final isAdmin = snapshot.data ?? false;
        return builder(isAdmin);
      },
    );
  }
}
