import 'package:delipan/config/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: AppStyles.darkGrey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.secondaryBrown,
        title: Text(
            'Agrega una tarjeta',
            style: GoogleFonts.inter(
            fontSize: AppStyles.headingFontSize,
            color: AppStyles.lightBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: TextButton(
          onPressed: (){
            Navigator.of(context).pushReplacementNamed('/pago');
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
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.07),
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
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.001, vertical: size.height * 0.03),
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
            child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation,
                        glassmorphismConfig: _getGlassmorphismConfig(),
                        cardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        bankName: 'DeliBank',
                        frontCardBorder: useGlassMorphis ? null : Border.all(color: AppStyles.lightBlue),
                        backCardBorder: useGlassMorphis ? null : Border.all(color: AppStyles.lightBlue),
                        showBackView: isCvvFocused,
                        obscureCardNumber: true,
                        obscureCardCvv: true,
                        isHolderNameVisible: true,
                        cardBgColor: AppStyles.lightBlue,
                        isSwipeGestureEnabled: true,
                        onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              CreditCardForm(
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
                                inputConfiguration: InputConfiguration(
                                  cardNumberDecoration: AppStyles.inputDecoration('').copyWith(
                                    labelText: 'Número de la tarjeta',
                                    hintText: 'XXXX XXXX XXXX XXXX',
                                  ),
                                  expiryDateDecoration: AppStyles.inputDecoration('').copyWith(
                                    labelText: 'Vencimiento',
                                    hintText: 'MM/AA',
                                  ),
                                  cvvCodeDecoration: AppStyles.inputDecoration('').copyWith(
                                    labelText: 'CVV',
                                    hintText: 'CVV',
                                  ),
                                  cardHolderDecoration: AppStyles.inputDecoration('').copyWith(
                                    labelText: 'Nombre del titular',
                                    hintText: 'Nombre de la tarjeta',
                                  ),
                                ), onCreditCardModelChange: onCreditCardModelChange,
                              ),
                            ],
                          ),
                        )
                    ),
                    Center(
                      child: TextButton(
                        onPressed: (){},
                        style: AppStyles.primaryButtonStyle,
                        child: Text(
                          'AGREGAR TARJETA',
                          style: AppStyles.buttonText.copyWith(
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }
  void _onValidate() {
    if (formKey.currentState?.validate() ?? false) {
      print('valid!');
    } else {
      print('invalid!');
    }
  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphis) {
      return null;
    }

    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[AppStyles.darkGrey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
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
}
