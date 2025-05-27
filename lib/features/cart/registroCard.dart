import 'package:delipan/config/styles.dart';
import 'package:delipan/services/card_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class Pago extends StatefulWidget {
  const Pago({super.key});

  @override
  State<Pago> createState() => _PagoState();
}

class _PagoState extends State<Pago> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphis = false;
  bool useFloatingAnimation = true;
  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
                    'Agregar Tarjeta',
                    style: AppStyles.appTitle.copyWith(fontSize: 28),
                  ),
                  Spacer(),
                  Icon(Icons.credit_card, color: AppStyles.primaryBrown),
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Widget de la tarjeta de crédito
                    CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation,
                      glassmorphismConfig: _getGlassmorphismConfig(),
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      bankName: 'DeliBank',
                      frontCardBorder: useGlassMorphis ? null : Border.all(color: AppStyles.primaryBrown, width: 2),
                      backCardBorder: useGlassMorphis ? null : Border.all(color: AppStyles.primaryBrown, width: 2),
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,                      isHolderNameVisible: true,
                      cardBgColor: AppStyles.primaryBrown,
                      isSwipeGestureEnabled: true,
                      onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                      customCardTypeIcons: <CustomCardTypeIcon>[],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Formulario de la tarjeta
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: CreditCardForm(
                            formKey: formKey,
                            obscureCvv: true,
                            obscureNumber: true,
                            cardNumber: cardNumber,
                            cvvCode: cvvCode,
                            isHolderNameVisible: true,
                            isCardNumberVisible: true,
                            isExpiryDateVisible: true,
                            cardHolderName: cardHolderName,
                            expiryDate: expiryDate,
                            onCreditCardModelChange: onCreditCardModelChange,
                            inputConfiguration: InputConfiguration(
                              cardNumberDecoration: AppStyles.inputDecoration('Número de tarjeta').copyWith(
                                hintText: 'XXXX XXXX XXXX XXXX',
                                prefixIcon: Icon(Icons.credit_card, color: AppStyles.primaryBrown),
                              ),
                              expiryDateDecoration: AppStyles.inputDecoration('Fecha de vencimiento').copyWith(
                                hintText: 'MM/AA',
                                prefixIcon: Icon(Icons.calendar_today, color: AppStyles.primaryBrown),
                              ),
                              cvvCodeDecoration: AppStyles.inputDecoration('CVV').copyWith(
                                hintText: 'XXX',
                                prefixIcon: Icon(Icons.lock, color: AppStyles.primaryBrown),
                              ),
                              cardHolderDecoration: AppStyles.inputDecoration('Nombre del titular').copyWith(
                                hintText: 'Como aparece en la tarjeta',
                                prefixIcon: Icon(Icons.person, color: AppStyles.primaryBrown),
                              ),
                              cardNumberTextStyle: AppStyles.bodyText,
                              expiryDateTextStyle: AppStyles.bodyText,
                              cvvCodeTextStyle: AppStyles.bodyText,
                              cardHolderTextStyle: AppStyles.bodyText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botón de agregar tarjeta
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
                  onPressed: isLoading ? null : _agregarTarjeta,
                  style: AppStyles.primaryButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'AGREGAR TARJETA',
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

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphis) {
      return null;
    }

    return Glassmorphism(
      blurX: 8.0,
      blurY: 16.0,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          AppStyles.darkGrey.withAlpha(50), 
          Colors.grey.withAlpha(50)
        ],
        stops: const <double>[0.3, 0],
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Future<void> _agregarTarjeta() async {
    if (!_validarFormulario()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _mostrarError('Usuario no autenticado');
        return;
      }

      final cardData = {
        'cardNumber': cardNumber,
        'cardHolderName': cardHolderName,
        'expiryDate': expiryDate,
        'cvvCode': cvvCode,
      };

      final success = await CardService.saveCard(user.uid, cardData);

      if (success) {
        // Retornar los datos de la tarjeta agregada
        Navigator.pop(context, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'cardNumber': cardNumber,
          'cardHolderName': cardHolderName,
          'expiryDate': expiryDate,
          'last4': cardNumber.replaceAll(' ', '').substring(cardNumber.replaceAll(' ', '').length - 4),
          'type': _getCardType(cardNumber),
        });
      } else {
        _mostrarError('Error al guardar la tarjeta');
      }
    } catch (e) {
      _mostrarError('Error inesperado: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _validarFormulario() {
    if (cardNumber.isEmpty || cardNumber.length < 13) {
      _mostrarError('Ingresa un número de tarjeta válido');
      return false;
    }

    if (cardHolderName.isEmpty || cardHolderName.length < 2) {
      _mostrarError('Ingresa el nombre del titular');
      return false;
    }

    if (!CardService.isValidExpiryDate(expiryDate)) {
      _mostrarError('Ingresa una fecha de vencimiento válida');
      return false;
    }

    if (cvvCode.isEmpty || cvvCode.length < 3) {
      _mostrarError('Ingresa un CVV válido');
      return false;
    }

    return true;
  }

  String _getCardType(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');
    
    if (number.startsWith('4')) {
      return 'Visa';
    } else if (number.startsWith('5') || number.startsWith('2')) {
      return 'Mastercard';
    } else if (number.startsWith('3')) {
      return 'American Express';
    } else {
      return 'Tarjeta';
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}