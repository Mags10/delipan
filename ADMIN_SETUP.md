# Configuración del Sistema de Admin - Delipan

## Descripción
Este documento explica cómo configurar el sistema de administración basado en roles para la aplicación Delipan usando Firebase Firestore.

## Funcionalidad Implementada

### 1. Control de Acceso Basado en Roles
- **Servicio UserService**: Maneja la verificación de roles de usuario
- **Protección del AdminPage**: Solo usuarios con rol 'admin' pueden acceder
- **Menú Dinámico**: La opción "Administración" solo aparece para administradores

### 2. Archivos Modificados
- `lib/services/user_service.dart` - Nuevo servicio para gestión de usuarios
- `lib/features/home/principal.dart` - Menú con control de acceso
- `lib/features/admin/admin_page.dart` - Página protegida con verificación
- `lib/utils/auth_services.dart` - Registro de usuarios con rol por defecto

## Configuración en Firebase Console

### Paso 1: Acceder a Firebase Console
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto Delipan
3. En el menú lateral, haz clic en "Firestore Database"

### Paso 2: Estructura de Datos de Usuario
Cada documento de usuario en la colección `usuarios` debe tener la siguiente estructura:

```json
{
  "email": "usuario@ejemplo.com",
  "nombre": "Nombre del Usuario",
  "telefono": "+1234567890",
  "direccion": "Dirección del usuario",
  "rol": "user"  // o "admin" para administradores
}
```

### Paso 3: Crear un Usuario Administrador

#### Opción A: Desde Firebase Console (Recomendado)
1. En Firestore Database, navega a la colección `usuarios`
2. Busca el documento del usuario que quieres hacer administrador
3. Haz clic en el documento para editarlo
4. Busca el campo `rol` y cambia su valor de `"user"` a `"admin"`
5. Guarda los cambios

#### Opción B: Registro Directo
1. Registra un nuevo usuario normalmente en la app
2. Ve inmediatamente a Firebase Console
3. Busca el nuevo documento creado en `usuarios`
4. Edita el campo `rol` de `"user"` a `"admin"`

### Paso 4: Verificar la Configuración
1. Inicia sesión en la app con el usuario administrador
2. Verifica que aparezca la opción "Administración" en el menú de usuario
3. Intenta acceder a la página de administración
4. Confirma que otros usuarios no ven la opción de administración

## Reglas de Seguridad Recomendadas

Para mayor seguridad, actualiza las reglas de Firestore para proteger el campo `rol`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir a los usuarios leer y escribir sus propios datos
    // pero NO permitir que modifiquen su propio rol
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId
        && (!("rol" in request.writeFields) || resource.data.rol == request.writeFields.rol);
    }
    
    // Solo los administradores pueden leer todos los usuarios
    match /usuarios/{document=**} {
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == "admin";
    }
    
    // Otras reglas para productos, etc.
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Roles Disponibles

### `user` (Por Defecto)
- Acceso completo a funcionalidades de usuario normal
- Puede ver productos, agregar al carrito, realizar pedidos
- **NO** puede acceder a funciones administrativas

### `admin` (Administrador)
- Todas las funcionalidades del rol `user`
- Acceso al panel de administración
- Puede gestionar productos y categorías
- Ve la opción "Administración" en el menú

## Troubleshooting

### Problema: La opción de admin no aparece
**Solución**: 
1. Verificar que el campo `rol` en Firestore esté establecido como `"admin"` (no `"Admin"` ni `"ADMIN"`)
2. Cerrar y volver a abrir la app para refrescar el estado
3. Verificar que no haya errores en la consola de Flutter

### Problema: Error de acceso denegado
**Solución**:
1. Confirmar que el usuario está autenticado
2. Verificar la conectividad a Firebase
3. Revisar las reglas de seguridad de Firestore

### Problema: Los cambios no se reflejan inmediatamente
**Solución**:
1. Los cambios en Firestore pueden tardar unos segundos en propagarse
2. Reiniciar la app puede acelerar la sincronización
3. Verificar la configuración de red

## Extensiones Futuras

### Roles Adicionales
Se pueden agregar más roles fácilmente:
- `moderator`: Acceso limitado al panel de admin
- `employee`: Funcionalidades específicas para empleados
- `superadmin`: Acceso completo al sistema

### Permisos Granulares
Implementar un sistema de permisos más detallado:
```json
{
  "rol": "admin",
  "permisos": {
    "productos": ["crear", "editar", "eliminar"],
    "usuarios": ["ver", "editar"],
    "reportes": ["ver", "exportar"]
  }
}
```

## Seguridad Adicional

### Recomendaciones
1. **Nunca** hardcodear roles en el código del cliente
2. Siempre verificar permisos en el servidor (Cloud Functions)
3. Implementar logging de acciones administrativas
4. Considerar autenticación de dos factores para admins
5. Revisar periódicamente los usuarios con rol admin

### Auditoría
Mantén un registro de:
- Quién tiene acceso de administrador
- Cuándo se asignaron/removieron permisos admin
- Acciones realizadas por administradores

---

**Nota**: Este sistema está diseñado para ser simple pero efectivo. Para aplicaciones de producción, considera implementar sistemas de autenticación y autorización más robustos.
