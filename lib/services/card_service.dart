import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CardService {
  static const String _cardsKey = 'user_cards_';
  
  // Obtener tarjetas del usuario
  static Future<List<Map<String, dynamic>>> getUserCards(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsJson = prefs.getString('$_cardsKey$userId');
      
      if (cardsJson == null) return [];
      
      final cardsList = json.decode(cardsJson) as List;
      return cardsList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error al obtener tarjetas: $e');
      return [];
    }
  }
  
  // Guardar nueva tarjeta
  static Future<bool> saveCard(String userId, Map<String, dynamic> cardData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCards = await getUserCards(userId);
      
      // Crear tarjeta con ID único
      final newCard = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'cardNumber': cardData['cardNumber'],
        'cardHolderName': cardData['cardHolderName'],
        'expiryDate': cardData['expiryDate'],
        'last4': cardData['cardNumber'].replaceAll(' ', '').substring(cardData['cardNumber'].replaceAll(' ', '').length - 4),
        'type': _getCardType(cardData['cardNumber']),
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      currentCards.add(newCard);
      
      final cardsJson = json.encode(currentCards);
      await prefs.setString('$_cardsKey$userId', cardsJson);
      
      return true;
    } catch (e) {
      print('Error al guardar tarjeta: $e');
      return false;
    }
  }
  
  // Eliminar tarjeta
  static Future<bool> deleteCard(String userId, String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCards = await getUserCards(userId);
      
      currentCards.removeWhere((card) => card['id'] == cardId);
      
      final cardsJson = json.encode(currentCards);
      await prefs.setString('$_cardsKey$userId', cardsJson);
      
      return true;
    } catch (e) {
      print('Error al eliminar tarjeta: $e');
      return false;
    }
  }
  
  // Determinar tipo de tarjeta basado en el número
  static String _getCardType(String cardNumber) {
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
  
  // Validar número de tarjeta (algoritmo de Luhn simplificado)
  static bool isValidCardNumber(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');
    return number.length >= 13 && number.length <= 19;
  }
  
  // Validar fecha de expiración
  static bool isValidExpiryDate(String expiryDate) {
    if (expiryDate.length != 5 || !expiryDate.contains('/')) return false;
    
    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    
    final currentYear = DateTime.now().year % 100;
    final currentMonth = DateTime.now().month;
    
    if (year < currentYear) return false;
    if (year == currentYear && month < currentMonth) return false;
    
    return true;
  }
}
