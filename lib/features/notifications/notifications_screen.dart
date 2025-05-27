import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:delipan/models/notification.dart';
import 'package:delipan/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isMarkingAllAsRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Contenido de notificaciones
            Expanded(
              child: StreamBuilder<List<NotificationModel>>(
                stream: _notificationService.getUserNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppStyles.primaryBrown,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error al cargar notificaciones',
                            style: AppStyles.heading.copyWith(
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Por favor, intenta nuevamente',
                            style: AppStyles.bodyText.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final notifications = snapshot.data ?? [];

                  if (notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildNotificationsList(notifications);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notificaciones',
              style: AppStyles.appTitle.copyWith(fontSize: 24),
            ),
          ),
          // Botón para marcar todas como leídas
          StreamBuilder<List<NotificationModel>>(
            stream: _notificationService.getUserNotifications(),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? [];
              final hasUnread = notifications.any((n) => !n.isRead);
              
              if (!hasUnread) return SizedBox.shrink();
              
              return IconButton(
                onPressed: _isMarkingAllAsRead ? null : _markAllAsRead,
                icon: _isMarkingAllAsRead
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppStyles.primaryBrown,
                        ),
                      )
                    : Icon(
                        Icons.done_all,
                        color: AppStyles.primaryBrown,
                      ),
                tooltip: 'Marcar todas como leídas',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppStyles.primaryBrown.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 80,
                color: AppStyles.primaryBrown.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No tienes notificaciones',
              style: AppStyles.heading.copyWith(
                fontSize: 24,
                color: AppStyles.primaryBrown,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Aquí aparecerán las actualizaciones sobre tus pedidos y otras novedades importantes.',
              style: AppStyles.bodyText.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: AppStyles.primaryButtonStyle,
              icon: Icon(Icons.shopping_bag, color: Colors.white),
              label: Text(
                'Explorar Productos',
                style: AppStyles.buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      color: AppStyles.primaryBrown,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead 
              ? Colors.grey.withOpacity(0.2)
              : Colors.blue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de notificación
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getNotificationIconColor(notification.type).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationIconColor(notification.type),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  
                  // Contenido de la notificación
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppStyles.bodyText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppStyles.primaryBrown,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: AppStyles.bodyText.copyWith(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 8),
                        
                        // Información adicional si existe
                        if (notification.data != null && notification.data!.isNotEmpty)
                          _buildNotificationData(notification),
                        
                        // Timestamp
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: AppStyles.bodyText.copyWith(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón de eliminar
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteNotification(notification);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: AppStyles.bodyText.copyWith(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationData(NotificationModel notification) {
    if (notification.type == 'order_confirmation' || notification.type == 'order_ready') {
      final data = notification.data!;
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppStyles.lightBrown,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['orderId'] != null)
              Text(
                'Pedido: #${data['orderId']}',
                style: AppStyles.bodyText.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (data['pickupPointName'] != null)
              Text(
                'Punto de recogida: ${data['pickupPointName']}',
                style: AppStyles.bodyText.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order_confirmation':
        return Icons.check_circle_outline;
      case 'order_ready':
        return Icons.shopping_bag_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationIconColor(String type) {
    switch (type) {
      case 'order_confirmation':
        return Colors.green;
      case 'order_ready':
        return Colors.orange;
      case 'promotion':
        return Colors.purple;
      case 'system':
        return Colors.blue;
      default:
        return AppStyles.primaryBrown;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isMarkingAllAsRead = true;
    });

    try {
      final success = await _notificationService.markAllAsRead();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar notificaciones como leídas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar notificaciones como leídas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAllAsRead = false;
        });
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      await _notificationService.markAsRead(notification.id);
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar notificación'),
        content: Text('¿Estás seguro de que deseas eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _notificationService.deleteNotification(notification.id);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la notificación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
