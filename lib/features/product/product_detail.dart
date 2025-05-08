import 'package:flutter/material.dart';
import 'package:delipan/models/product.dart';
import 'package:delipan/config/styles.dart';
import 'package:provider/provider.dart';
import 'package:delipan/models/cart.dart';
import 'package:page_transition/page_transition.dart';
import 'package:delipan/features/cart/cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final heroTag = 'product-${product.id}';
    
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeInAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductImage(product, heroTag),
                        SizedBox(height: 20),
                        _buildProductInfo(product),
                        SizedBox(height: 20),
                        _buildQuantitySelector(),
                        SizedBox(height: 20),
                        _buildAddToCartButton(product),
                      ],
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

  Widget _buildHeader() {
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
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppStyles.primaryBrown),
            onPressed: () {},
          ),
          // Icono del carrito con notificador
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppStyles.primaryBrown),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: CartPage(),
                    ),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product, String heroTag) {
    return Hero(
      tag: heroTag,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppStyles.mediumBrown,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppStyles.mediumBrown,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppStyles.primaryBrown,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: AppStyles.heading,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppStyles.primaryBrown,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'Categoría: ${product.category}',
          style: TextStyle(
            color: AppStyles.darkGrey,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppStyles.darkGrey,
          ),
        ),
        SizedBox(height: 8),
        Text(
          product.description,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppStyles.darkGrey,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: AppStyles.primaryBrown),
            SizedBox(width: 8),
            Text(
              'Disponible para entrega',
              style: TextStyle(color: AppStyles.darkGrey),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            SizedBox(width: 8),
            Text(
              'En stock',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          'Cantidad:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppStyles.darkGrey,
          ),
        ),
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppStyles.primaryBrown),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 18),
                onPressed: _decrementQuantity,
                color: AppStyles.primaryBrown,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 18),
                onPressed: _incrementQuantity,
                color: AppStyles.primaryBrown,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(Product product) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.shopping_cart),
        label: Text('Añadir al carrito'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.secondaryBrown,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // Agregar el producto al carrito la cantidad de veces especificada
          final cart = Provider.of<Cart>(context, listen: false);
          
          // Primero verificamos si el producto ya está en el carrito
          bool isAlreadyInCart = cart.isInCart(product.id);
          
          // Añadimos el producto al carrito el número de veces especificado
          for (int i = 0; i < quantity; i++) {
            cart.addItem(product);
          }
          
          // Mostramos diferentes mensajes dependiendo de si es un nuevo producto o uno existente
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isAlreadyInCart 
                        ? 'Se actualizó la cantidad de ${product.name}'
                        : '${product.name} añadido al carrito',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: CartPage(),
                        ),
                      );
                    },
                    child: Text(
                      'VER CARRITO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              backgroundColor: AppStyles.primaryBrown,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}