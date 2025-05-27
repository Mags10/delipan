import 'package:delipan/features/cart/registroCard.dart';
import 'package:delipan/features/cart/seleccion_punto_recogida.dart';
import 'package:delipan/services/card_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';

class MetodoPago extends StatefulWidget {
  const MetodoPago({super.key});

  @override
  State<MetodoPago> createState() => _MetodoPagoState();
}

class _MetodoPagoState extends State<MetodoPago> {
  String? _seleccionMetodoPago;
  List<Map<String, dynamic>> _tarjetas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTarjetas();
  }

  Future<void> _cargarTarjetas() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cards = await CardService.getUserCards(user.uid);
      setState(() {
        _tarjetas = cards;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
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
                    'Método de Pago',
                    style: AppStyles.appTitle.copyWith(fontSize: 28),
                  ),
                  Spacer(),
                  Icon(Icons.payment, color: AppStyles.primaryBrown),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryBrown),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecciona tu método de pago',
                            style: AppStyles.heading.copyWith(
                              fontSize: 20,
                              color: AppStyles.primaryBrown,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Elige cómo prefieres pagar tu pedido',
                            style: AppStyles.bodyText.copyWith(
                              color: AppStyles.darkGrey.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Opción de pago en efectivo
                          _buildPaymentOption(
                            title: 'Pago en efectivo',
                            subtitle: 'Paga al recoger tu pedido',
                            icon: Icons.attach_money,
                            isSelected: _seleccionMetodoPago == 'efectivo',
                            onTap: () {
                              setState(() {
                                _seleccionMetodoPago = 'efectivo';
                              });
                            },
                          ),

                          SizedBox(height: 16),

                          // Opción de pago con tarjeta
                          _buildPaymentOption(
                            title: 'Pago con tarjeta',
                            subtitle: _tarjetas.isEmpty 
                                ? 'Agregar nueva tarjeta'
                                : '${_tarjetas.length} tarjeta(s) registrada(s)',
                            icon: Icons.credit_card,
                            isSelected: _seleccionMetodoPago == 'tarjeta',
                            onTap: () {
                              setState(() {
                                _seleccionMetodoPago = 'tarjeta';
                              });
                            },
                          ),

                          // Lista de tarjetas guardadas si el método de tarjeta está seleccionado
                          if (_seleccionMetodoPago == 'tarjeta') ...[
                            SizedBox(height: 16),
                            if (_tarjetas.isNotEmpty) ...[
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppStyles.primaryBrown.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tarjetas guardadas:',
                                      style: AppStyles.cardTitle.copyWith(
                                        color: AppStyles.primaryBrown,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    ..._buildSavedCards(),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                            
                            // Botón para agregar nueva tarjeta
                            Container(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _navigateToAddCard,
                                icon: Icon(Icons.add, color: AppStyles.primaryBrown),
                                label: Text(
                                  'Agregar nueva tarjeta',
                                  style: AppStyles.bodyText.copyWith(
                                    color: AppStyles.primaryBrown,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppStyles.primaryBrown),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          Spacer(),
                        ],
                      ),
                    ),
            ),

            // Botón de continuar
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
                  onPressed: _seleccionMetodoPago != null ? _confirmarPago : null,
                  style: AppStyles.primaryButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: Text(
                    'CONTINUAR',
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
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppStyles.primaryBrown : AppStyles.mediumBrown,
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
                icon,
                color: isSelected ? AppStyles.primaryBrown : AppStyles.darkGrey,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.cardTitle.copyWith(
                      color: isSelected ? AppStyles.primaryBrown : AppStyles.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppStyles.cardText.copyWith(
                      color: AppStyles.darkGrey.withOpacity(0.7),
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
    );
  }

  List<Widget> _buildSavedCards() {
    return _tarjetas.map((tarjeta) {
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppStyles.lightBrown,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppStyles.mediumBrown,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.credit_card, 
              color: AppStyles.primaryBrown,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "**** **** **** ${tarjeta['last4']}",
                    style: AppStyles.cardText.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${tarjeta['type']} • ${tarjeta['cardHolderName']}",
                    style: AppStyles.cardText.copyWith(
                      fontSize: 12,
                      color: AppStyles.darkGrey.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _eliminarTarjeta(tarjeta['id']),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _navigateToAddCard() async {
    final newCard = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Pago()),
    );

    if (newCard != null && newCard is Map<String, dynamic>) {
      await _cargarTarjetas(); // Recargar tarjetas
    }
  }

  Future<void> _eliminarTarjeta(String cardId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final success = await CardService.deleteCard(user.uid, cardId);
      if (success) {
        await _cargarTarjetas(); // Recargar tarjetas
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarjeta eliminada'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _confirmarPago() {
    if (_seleccionMetodoPago == 'efectivo') {
      _navegarAPuntoRecogida('efectivo');
    } else if (_seleccionMetodoPago == 'tarjeta') {
      if (_tarjetas.isNotEmpty) {
        _navegarAPuntoRecogida('tarjeta');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agrega una tarjeta para continuar'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona un método de pago'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navegarAPuntoRecogida(String metodoPago) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeleccionPuntoRecogida(),
      ),
    );
  }
}