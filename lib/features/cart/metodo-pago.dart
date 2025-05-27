import 'package:delipan/features/cart/registroCard.dart';
import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:google_fonts/google_fonts.dart';

class MetodoPago extends StatefulWidget {
  const MetodoPago({super.key});

  @override
  State<MetodoPago> createState() => _MetodoPagoState();
}

class _MetodoPagoState extends State<MetodoPago> {
  String? _seleccionMetodoPago;
  final List<Map<String, dynamic>> _tarjetas = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(

      appBar: AppBar(
        backgroundColor: AppStyles.secondaryBrown,
        title: Text(
          'Método de pago',
          style: GoogleFonts.inter(
            fontSize: AppStyles.headingFontSize,
            color: AppStyles.lightBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: TextButton(
          onPressed: (){
            ///Cambiar la dirección de la vista!!!
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Text(
            String.fromCharCode(Icons.arrow_back.codePoint),
            style: TextStyle(
                inherit: false,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: Icons.arrow_back.fontFamily,
                color: AppStyles.lightBrown
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.05),
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppStyles.lightBrown,
                AppStyles.lightBrown,
                AppStyles.lightBrown,
                AppStyles.secondaryBrown.withOpacity(0.3),
              ],
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.05),
            width: size.width * 0.85,
            constraints: BoxConstraints(maxWidth: 450), // Limitamos el ancho máximo
            decoration: BoxDecoration(
              color: AppStyles.mediumBrown,
              borderRadius: BorderRadius.circular(30),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppStyles.black.withOpacity(0.4),
                  blurRadius: 15.0,
                  spreadRadius: 1.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildPaymentOption(
                  title: 'Pago en efectivo',
                  subtitle: 'Paga al recoger tu pedido',
                  icon: Icons.attach_money,
                  isSelected: _seleccionMetodoPago == 'efectivo',
                  onTap: () {
                    setState(() {
                      _seleccionMetodoPago = 'efectivo';
                    });
                  }
                ),
                SizedBox(height: 20),
                _buildPaymentOption(
                    title: 'Pago con tarjeta',
                    subtitle: _tarjetas.isEmpty ? 'Agregar nueva tarjeta'
                        : '${_tarjetas.length} tarjeta(s) registrada(s)',
                    icon: Icons.credit_card,
                    isSelected: _seleccionMetodoPago == 'tarjeta',
                    onTap: () {
                      setState(() {
                        _seleccionMetodoPago = 'tarjeta';
                      });
                      if (_tarjetas.isEmpty) {
                        _navigateToAddCard();
                      }
                    },
                ),
                if (_seleccionMetodoPago == 'tarjeta')
                  TextButton(
                      onPressed: _navigateToAddCard,
                      child: Text(
                        '+ Agregar nueva tarjeta',
                        style: TextStyle(
                          color: AppStyles.primaryBrown,
                          fontSize: 16,
                        ),
                      ),
                  ),
                Spacer(),
                SizedBox(
                  width: size.width * 0.9,
                  child: ElevatedButton(
                      onPressed: _seleccionMetodoPago != null ? _confirmPayment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        'Confirmar método de pago',
                        style: TextStyle(
                          color: AppStyles.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ),
              ],
            ),
          ),
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
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? AppStyles.secondaryBrown.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppStyles.primaryBrown : AppStyles.darkGrey,
            width: 2
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: AppStyles.primaryBrown,
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.heading
                  ),
                  Text(
                    subtitle,
                    style: AppStyles.subtitle
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppStyles.primaryBrown),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSavedCards() {
    return _tarjetas.map((tarjeta) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(Icons.credit_card, color: AppStyles.primaryBrown),
          title: Text(
            "XXXX XXXX XXXX XXXX ${tarjeta['last4']}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(tarjeta['type']),
          trailing: IconButton(
              onPressed: (){
                setState(() {
                  _tarjetas.remove(tarjeta);
                  if (_tarjetas.isEmpty) {
                    _seleccionMetodoPago = null;
                  }
                });
              },
              icon: Icon(Icons.delete, color: Colors.red),
          ),
          tileColor: AppStyles.darkGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }).toList();
  }

  void _navigateToAddCard() async {
    final newCard = await Navigator.push(context, MaterialPageRoute(builder: (context) => Pago()),);

    if (newCard != null && newCard is Map<String, dynamic>) {
      setState(() {
        _tarjetas.add(newCard);
        _seleccionMetodoPago = 'tarjeta';
      });
    }
  }

  void _confirmPayment() {
    if (_seleccionMetodoPago == 'efectivo') {
      Navigator.pop(context, '');
    } else if (_seleccionMetodoPago == 'tarjeta' && _tarjetas.isNotEmpty) {
      Navigator.pop(context, _tarjetas.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona o agrega una tarjeta')),
      );
    }
  }
}
