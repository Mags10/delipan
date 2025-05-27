import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delipan/models/firebase_cart.dart';
import 'package:delipan/config/styles.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            // Header personalizado consistente con el resto de la app
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
                    'Carrito',
                    style: AppStyles.appTitle.copyWith(fontSize: 28),
                  ),
                  Spacer(),
                  Icon(Icons.shopping_cart, color: AppStyles.primaryBrown),
                ],
              ),
            ),
            // Contenido del carrito
            Expanded(
              child: Consumer<FirebaseCart>(
                builder: (context, cart, child) {
                  // Mostrar loading mientras se cargan los datos
                  if (cart.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryBrown),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando carrito...',
                            style: AppStyles.bodyText,
                          ),
                        ],
                      ),
                    );
                  }

                  // Verificar si el usuario está autenticado
                  if (!cart.isAuthenticated) {
                    return Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppStyles.primaryBrown.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 80,
                                color: AppStyles.primaryBrown,
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Inicia sesión para ver tu carrito',
                              style: AppStyles.heading.copyWith(
                                fontSize: 24,
                                color: AppStyles.darkGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Guarda tus productos favoritos y mantén tu carrito sincronizado',
                              style: AppStyles.bodyText.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                icon: Icon(Icons.login),
                                label: Text('Iniciar Sesión'),
                                style: AppStyles.primaryButtonStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }          // Mostrar carrito vacío
                  if (cart.items.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppStyles.primaryBrown.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: AppStyles.primaryBrown,
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Tu carrito está vacío',
                              style: AppStyles.heading.copyWith(
                                fontSize: 24,
                                color: AppStyles.darkGrey,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Descubre nuestros deliciosos productos y añade algunos a tu carrito',
                              style: AppStyles.bodyText.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.search),
                                label: Text('Explorar Productos'),
                                style: AppStyles.primaryButtonStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }          return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: ListView.builder(
                            itemCount: cart.items.length,
                            itemBuilder: (context, index) {
                              final item = cart.items[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Imagen del producto
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          item.productImageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: AppStyles.primaryBrown.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.fastfood,
                                                color: AppStyles.primaryBrown.withOpacity(0.5),
                                                size: 40,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // Información del producto
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: AppStyles.cardTitle.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              '\$${item.productPrice.toStringAsFixed(0)}',
                                              style: AppStyles.bodyText.copyWith(
                                                color: AppStyles.primaryBrown,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Controles de cantidad
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppStyles.primaryBrown.withOpacity(0.3)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove, size: 20),
                                              onPressed: () async {
                                                try {
                                                  if (item.quantity > 1) {
                                                    await cart.updateQuantity(
                                                      item.id, 
                                                      item.quantity - 1
                                                    );
                                                  } else {
                                                    await cart.removeCartItem(item.id);
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Error al actualizar el carrito'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              color: AppStyles.primaryBrown,
                                              constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                '${item.quantity}',
                                                style: AppStyles.bodyText.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add, size: 20),
                                              onPressed: () async {
                                                try {
                                                  await cart.updateQuantity(
                                                    item.id, 
                                                    item.quantity + 1
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Error al actualizar el carrito'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              color: AppStyles.primaryBrown,
                                              constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Barra inferior con total y checkout
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
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total (${cart.totalItems} productos):',
                                  style: AppStyles.bodyText.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '\$${cart.totalAmount.toStringAsFixed(0)}',
                                  style: AppStyles.heading.copyWith(
                                    color: AppStyles.primaryBrown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      bool? confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          title: Text(
                                            'Vaciar Carrito',
                                            style: AppStyles.cardTitle,
                                          ),
                                          content: Text(
                                            '¿Estás seguro de que quieres eliminar todos los productos del carrito?',
                                            style: AppStyles.bodyText,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: Text(
                                                'Cancelar',
                                                style: AppStyles.bodyText.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: Text(
                                                'Vaciar',
                                                style: AppStyles.bodyText.copyWith(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirmed == true) {
                                        try {
                                          await cart.clearCart();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Carrito vaciado'),
                                              backgroundColor: AppStyles.primaryBrown,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error al vaciar el carrito'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: Icon(Icons.delete_outline),
                                    label: Text('Vaciar'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: cart.items.isNotEmpty ? () {
                                      // Lógica para proceder al checkout
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Funcionalidad de checkout próximamente'),
                                          backgroundColor: AppStyles.primaryBrown,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } : null,
                                    icon: Icon(Icons.payment),
                                    label: Text('Proceder al Pago'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppStyles.primaryBrown,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: AppStyles.buttonText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}