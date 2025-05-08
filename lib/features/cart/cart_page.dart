import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delipan/models/cart.dart';
import 'package:delipan/config/styles.dart';
import 'package:delipan/models/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            
            // Título del carrito con icono
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: AppStyles.primaryBrown,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'CARRO DE COMPRA',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de productos en el carrito
            Expanded(
              child: cart.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartItems(cart),
            ),
            
            // Botón de comprar
            if (!cart.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Implementar la acción de comprar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Procesando compra...'))
                    );
                    // Aquí iría la lógica para finalizar la compra
                    cart.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryBrown,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'COMPRAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Acceder al carrito para mostrar la cantidad de productos
    final cart = Provider.of<Cart>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppStyles.lightBrown,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppStyles.primaryBrown),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppStyles.primaryBrown,
            radius: 16,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/Logo_delipan.png',
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Delipan',
            style: AppStyles.appTitle.copyWith(fontSize: 22),
          ),
          const Spacer(),
          // En la página de carrito no es necesario mostrar el icono del carrito nuevamente
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega productos al carrito para realizar tu compra',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(Cart cart) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.all(12),
        itemCount: cart.items.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
        itemBuilder: (context, index) {
          final cartItem = cart.items[index];
          return _buildCartItemCard(context, cartItem);
        },
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem cartItem) {
    final product = cartItem.product;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Texto e información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Precio: \$${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          
          // Controles de cantidad
          Row(
            children: [
              _buildQuantityButton(
                context: context,
                icon: Icons.remove,
                onPressed: () {
                  Provider.of<Cart>(context, listen: false)
                      .decrementItem(product.id);
                },
              ),
              SizedBox(width: 8),
              Text(
                cartItem.quantity.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              _buildQuantityButton(
                context: context,
                icon: Icons.add,
                onPressed: () {
                  Provider.of<Cart>(context, listen: false)
                      .addItem(product);
                },
              ),
              SizedBox(width: 8),
              // Botón eliminar
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                onPressed: () {
                  Provider.of<Cart>(context, listen: false)
                      .removeItem(product.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      customBorder: CircleBorder(),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppStyles.primaryBrown.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppStyles.primaryBrown,
        ),
      ),
    );
  }
}