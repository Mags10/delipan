import 'package:delipan/config/styles.dart';
import 'package:delipan/models/pickup_point.dart';
import 'package:delipan/services/pickup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:delipan/features/cart/order_confirmation_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:delipan/models/firebase_cart.dart';

class SeleccionPuntoRecogida extends StatefulWidget {
  const SeleccionPuntoRecogida({super.key});

  @override
  State<SeleccionPuntoRecogida> createState() => _SeleccionPuntoRecogidaState();
}

class _SeleccionPuntoRecogidaState extends State<SeleccionPuntoRecogida> {
  final PickupService _pickupService = PickupService();
  String? _puntoSeleccionado;
  bool _showMap = false;
  List<PickupPoint> _puntosRecogida = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            // Header consistente con CartPage
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
                    'Punto de Recogida',
                    style: AppStyles.appTitle.copyWith(fontSize: 28),
                  ),
                  Spacer(),
                  Icon(Icons.location_on, color: AppStyles.primaryBrown),
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona dónde recoger tu pedido',
                      style: AppStyles.heading.copyWith(
                        fontSize: 20,
                        color: AppStyles.primaryBrown,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Elige el punto de recogida más conveniente para ti',
                      style: AppStyles.bodyText.copyWith(
                        color: AppStyles.darkGrey.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 24),
                      // Botón para alternar vista de mapa
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showMap = !_showMap;
                          });
                        },
                        icon: Icon(_showMap ? Icons.list : Icons.map),
                        label: Text(_showMap ? 'Ver Lista' : 'Ver Mapa'),
                        style: AppStyles.primaryButtonStyle.copyWith(
                          backgroundColor: MaterialStateProperty.all(AppStyles.secondaryBrown),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: _showMap ? _buildMapView() : _buildListView(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botón de confirmación
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _puntoSeleccionado != null ? _confirmarPedido : null,
                  style: AppStyles.primaryButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: Text(
                    'CONFIRMAR PEDIDO',
                    style: AppStyles.buttonText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }  void _confirmarPedido() {
    if (_puntoSeleccionado == null) return;
    
    final puntoSeleccionado = _puntosRecogida.firstWhere(
      (punto) => punto.id == _puntoSeleccionado,
    );
    
    final cart = Provider.of<FirebaseCart>(context, listen: false);
    final orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
    
    // Navegar a la pantalla de confirmación de pedido
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: OrderConfirmationScreen(
          pickupPoint: puntoSeleccionado,
          orderId: orderId,
          totalAmount: cart.totalAmount,
          orderItems: cart.items,
        ),
      ),
    ).then((_) {
      // Volver al inicio después de la confirmación
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  Widget _buildListView() {
    return StreamBuilder<List<PickupPoint>>(
      stream: _pickupService.getPickupPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryBrown),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error al cargar los puntos de recogida',
                  style: AppStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Trigger rebuild to retry
                  },
                  style: AppStyles.primaryButtonStyle,
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final puntos = snapshot.data ?? [];
        _puntosRecogida = puntos;

        if (puntos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 64, color: AppStyles.darkGrey),
                SizedBox(height: 16),
                Text(
                  'No hay puntos de recogida disponibles',
                  style: AppStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: puntos.length,
          itemBuilder: (context, index) {
            final punto = puntos[index];
            final isSelected = _puntoSeleccionado == punto.id;
            
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _puntoSeleccionado = punto.id;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                        ? AppStyles.primaryBrown 
                        : AppStyles.mediumBrown,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? AppStyles.primaryBrown.withOpacity(0.1)
                            : AppStyles.mediumBrown.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.store,
                          color: isSelected 
                            ? AppStyles.primaryBrown 
                            : AppStyles.darkGrey,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    punto.nombre,
                                    style: AppStyles.cardTitle.copyWith(
                                      color: isSelected 
                                        ? AppStyles.primaryBrown 
                                        : AppStyles.darkGrey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8, 
                                    vertical: 4
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppStyles.secondaryBrown.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    punto.distanciaString,
                                    style: AppStyles.cardText.copyWith(
                                      color: AppStyles.primaryBrown,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              punto.direccion,
                              style: AppStyles.cardText.copyWith(
                                color: AppStyles.darkGrey.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              punto.horario,
                              style: AppStyles.cardText.copyWith(
                                color: AppStyles.darkGrey.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppStyles.primaryBrown,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMapView() {
    return StreamBuilder<List<PickupPoint>>(
      stream: _pickupService.getPickupPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryBrown),
            ),
          );
        }

        final puntos = snapshot.data ?? [];
        final puntosConCoordenadas = puntos.where((p) => p.hasCoordinates).toList();

        if (puntosConCoordenadas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 64, color: AppStyles.darkGrey),
                SizedBox(height: 16),
                Text(
                  'No hay ubicaciones disponibles para mostrar en el mapa',
                  style: AppStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showMap = false;
                    });
                  },
                  style: AppStyles.primaryButtonStyle,
                  child: Text('Ver Lista'),
                ),
              ],
            ),
          );
        }

        // Calcular el centro del mapa
        double centerLat = puntosConCoordenadas.map((p) => p.latitude!).reduce((a, b) => a + b) / puntosConCoordenadas.length;
        double centerLon = puntosConCoordenadas.map((p) => p.longitude!).reduce((a, b) => a + b) / puntosConCoordenadas.length;        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(centerLat, centerLon),
            initialZoom: 13.0,
            onTap: (tapPosition, point) {
              // Opcional: hacer algo cuando se toque el mapa
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.delipan.app',
            ),
            MarkerLayer(
              markers: puntosConCoordenadas.map((punto) {
                final isSelected = _puntoSeleccionado == punto.id;
                  return Marker(
                  point: LatLng(punto.latitude!, punto.longitude!),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _puntoSeleccionado = punto.id;
                      });
                      
                      // Mostrar información del punto
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.store, color: AppStyles.primaryBrown),
                                  SizedBox(width: 8),
                                  Text(
                                    punto.nombre,
                                    style: AppStyles.cardTitle.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppStyles.secondaryBrown.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      punto.distanciaString,
                                      style: AppStyles.cardText.copyWith(
                                        color: AppStyles.primaryBrown,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                punto.direccion,
                                style: AppStyles.cardText,
                              ),
                              SizedBox(height: 4),
                              Text(
                                punto.horario,
                                style: AppStyles.cardText.copyWith(
                                  fontSize: 12,
                                  color: AppStyles.darkGrey.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppStyles.primaryBrown : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppStyles.primaryBrown,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.store,
                        color: isSelected ? Colors.white : AppStyles.primaryBrown,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
