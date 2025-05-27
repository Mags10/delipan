import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:delipan/config/styles.dart';
import 'package:delipan/models/pickup_point.dart';
import 'package:delipan/models/firebase_cart.dart';
import 'package:delipan/models/firebase_cart_item.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delipan/services/notification_service.dart';
import 'dart:io';
import 'dart:typed_data';

class OrderConfirmationScreen extends StatefulWidget {
  final PickupPoint pickupPoint;
  final String orderId;
  final double totalAmount;
  final List<FirebaseCartItem> orderItems;

  const OrderConfirmationScreen({
    super.key,
    required this.pickupPoint,
    required this.orderId,
    required this.totalAmount,
    required this.orderItems,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  
  final ScreenshotController _screenshotController = ScreenshotController();
  final NotificationService _notificationService = NotificationService();
  
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    
    _confettiController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
      _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Iniciar animaciones
    _confettiController.forward();
    _slideController.forward();
    
    // Crear notificación del pedido
    _createOrderNotification();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  Future<void> _createOrderNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _notificationService.createOrderConfirmationNotification(
        userId: user.uid,
        orderId: widget.orderId,
        pickupPointName: widget.pickupPoint.nombre,
        pickupPointAddress: widget.pickupPoint.direccion,
      );
      
      // Limpiar el carrito después de confirmar el pedido
      final cart = Provider.of<FirebaseCart>(context, listen: false);
      await cart.clearCart();
    }
  }

  Future<void> _shareConfirmation() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final Uint8List? imageBytes = await _screenshotController.capture();
      
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final String fileName = 'pedido_confirmado_${widget.orderId}.png';
        final File file = File('${directory.path}/$fileName');
        
        await file.writeAsBytes(imageBytes);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '¡Mi pedido ha sido confirmado en Delipan! 🍞\n'
                'Pedido #${widget.orderId}\n'
                'Punto de recogida: ${widget.pickupPoint.nombre}\n'
                'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
          subject: 'Confirmación de Pedido - Delipan',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navegar a la pantalla principal
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/principal',
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppStyles.lightBrown,
        body: Screenshot(
          controller: _screenshotController,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppStyles.lightBrown,
                  AppStyles.secondaryBrown.withOpacity(0.1),
                ],
              ),
            ),
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _slideAnimation,                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _slideAnimation.value) * 50),
                    child: Opacity(
                      opacity: _slideAnimation.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    // Header con confetti
                    Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Icono de éxito con animación
                          AnimatedBuilder(
                            animation: _confettiController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_confettiController.value * 0.2),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 24),
                          Text(
                            '¡Pedido Confirmado!',
                            style: AppStyles.heading.copyWith(
                              fontSize: 28,
                              color: AppStyles.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tu pedido ha sido registrado exitosamente',
                            style: AppStyles.bodyText.copyWith(
                              fontSize: 16,
                              color: AppStyles.darkGrey.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    // Contenido principal
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información del pedido
                            _buildOrderInfoCard(),
                            SizedBox(height: 20),
                            
                            // Punto de recogida
                            _buildPickupPointCard(),
                            SizedBox(height: 20),
                            
                            // Resumen de productos
                            _buildOrderSummaryCard(),
                            SizedBox(height: 20),
                            
                            // Información adicional
                            _buildAdditionalInfoCard(),
                          ],
                        ),
                      ),
                    ),
                    
                    // Botones de acción
                    Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Botón de compartir
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSharing ? null : _shareConfirmation,
                              style: AppStyles.primaryButtonStyle.copyWith(
                                backgroundColor: MaterialStateProperty.all(Colors.green),
                                padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                              icon: _isSharing
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Icon(Icons.share, color: Colors.white),
                              label: Text(
                                _isSharing ? 'Compartiendo...' : 'Compartir Confirmación',
                                style: AppStyles.buttonText,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Botón de continuar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/principal',
                                  (route) => false,
                                );
                              },
                              style: AppStyles.primaryButtonStyle.copyWith(
                                padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                              icon: Icon(Icons.home, color: Colors.white),
                              label: Text(
                                'Volver al Inicio',
                                style: AppStyles.buttonText,
                              ),
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
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
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
                  color: AppStyles.primaryBrown.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long,
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
                      'Información del Pedido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.primaryBrown,
                      ),
                    ),
                    Text(
                      'Detalles de tu compra',
                      style: AppStyles.bodyText.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          SizedBox(height: 16),
          _buildInfoRow('Número de Pedido:', '#${widget.orderId}'),
          _buildInfoRow('Fecha:', _formatDate(DateTime.now())),
          _buildInfoRow('Total:', '\$${widget.totalAmount.toStringAsFixed(2)}'),
          _buildInfoRow('Productos:', '${widget.orderItems.length} items'),
        ],
      ),
    );
  }

  Widget _buildPickupPointCard() {
    return Container(
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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punto de Recogida',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.primaryBrown,
                      ),
                    ),
                    Text(
                      'Donde recoger tu pedido',
                      style: AppStyles.bodyText.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppStyles.lightBrown,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pickupPoint.nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.primaryBrown,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.pickupPoint.direccion,
                        style: AppStyles.bodyText.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      'Horario: ${widget.pickupPoint.horario}',
                      style: AppStyles.bodyText.copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
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
                  Icons.shopping_bag,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del Pedido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.primaryBrown,
                      ),
                    ),
                    Text(
                      '${widget.orderItems.length} productos',
                      style: AppStyles.bodyText.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...widget.orderItems.take(3).map((item) => _buildOrderItem(item)),
          if (widget.orderItems.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '... y ${widget.orderItems.length - 3} productos más',
                style: AppStyles.bodyText.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(FirebaseCartItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppStyles.lightBrown,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImageUrl.isNotEmpty
                  ? Image.network(
                      item.productImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.bakery_dining,
                          color: AppStyles.primaryBrown,
                        );
                      },
                    )
                  : Icon(
                      Icons.bakery_dining,
                      color: AppStyles.primaryBrown,
                    ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Cantidad: ${item.quantity}',
                  style: AppStyles.bodyText.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.totalPrice.toStringAsFixed(2)}',
            style: AppStyles.bodyText.copyWith(
              fontWeight: FontWeight.bold,
              color: AppStyles.primaryBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Información Importante',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.primaryBrown,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• Recibirás una notificación cuando tu pedido esté listo para recoger\n'
            '• Presenta tu número de pedido al momento de recoger\n'
            '• El tiempo estimado de preparación es de 30-45 minutos\n'
            '• Puedes consultar el estado de tu pedido en la sección de notificaciones',
            style: AppStyles.bodyText.copyWith(
              fontSize: 14,
              color: AppStyles.darkGrey.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.bodyText.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: AppStyles.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
