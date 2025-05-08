import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:delipan/models/product.dart';
import 'package:delipan/widgets/featured_product_card.dart';
import 'package:delipan/widgets/product_card.dart';
import 'package:delipan/data/dummy_data.dart';
import 'package:delipan/features/product/product_detail.dart';
import 'package:page_transition/page_transition.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  // Obtener los productos de prueba
  final List<Product> featuredProducts = DummyData.getFeaturedProducts();
  final List<Product> moreProducts = DummyData.getMoreProducts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshProducts,
                    color: AppStyles.primaryBrown,
                    child: SingleChildScrollView(
                      // Padding superior ajustado para dejar espacio para la barra de búsqueda flotante
                      padding: EdgeInsets.only(
                        top: 70.0, // Espacio para la barra de búsqueda
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10), // Espacio adicional después de la barra
                          _buildFeaturedProductsSection(),
                          SizedBox(height: 20),
                          _buildMoreProductsSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Barra de búsqueda flotante
            Positioned(
              top: 70, // Posición debajo del header
              left: 16,
              right: 16,
              child: _buildFloatingSearchBar(),
            ),
          ],
        ),
      ),
    );
  }

  // Función para actualizar los productos
  Future<void> _refreshProducts() async {
    // Simula un tiempo de carga
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      // Actualiza los datos con nuevos productos
      // En un caso real aquí se haría una llamada a la API o base de datos
      featuredProducts.clear();
      moreProducts.clear();
      featuredProducts.addAll(DummyData.getFeaturedProducts());
      moreProducts.addAll(DummyData.getMoreProducts());
    });
  }

  Widget _buildHeader() {
    return Container(
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
          // Logo
          CircleAvatar(
            backgroundColor: AppStyles.primaryBrown,
            radius: 24,
            child: Padding(
              padding: EdgeInsets.all(6.0),
              child: Image.asset(
                'assets/Logo_delipan.png',
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12),
          // Título
          Text(
            'Delipan',
            style: AppStyles.appTitle,
          ),
          Spacer(),
          // Iconos de acción con menús desplegables
          PopupMenuButton<String>(
            icon: Icon(Icons.person_outline, color: AppStyles.primaryBrown),
            offset: Offset(0, 50),
            onSelected: (value) {
              switch (value) {
                case 'mi_cuenta':
                  // Navegar a la página de Mi Cuenta
                  print('Navegando a Mi Cuenta');
                  break;
                case 'cerrar_sesion':
                  // Lógica para cerrar sesión
                  print('Cerrando sesión');
                  Navigator.pushReplacementNamed(context, '/login');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'mi_cuenta',
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: AppStyles.primaryBrown),
                    SizedBox(width: 10),
                    Text('Mi Cuenta'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'cerrar_sesion',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppStyles.primaryBrown),
                    SizedBox(width: 10),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.notifications_none, color: AppStyles.primaryBrown),
            offset: Offset(0, 50),
            onSelected: (value) {
              switch (value) {
                case 'todas_notificaciones':
                  // Navegar a todas las notificaciones
                  print('Ver todas las notificaciones');
                  break;
                case 'configurar_notificaciones':
                  // Configurar notificaciones
                  print('Configurar notificaciones');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'todas_notificaciones',
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: AppStyles.primaryBrown),
                    SizedBox(width: 10),
                    Text('Todas las notificaciones'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'configurar_notificaciones',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: AppStyles.primaryBrown),
                    SizedBox(width: 10),
                    Text('Configurar notificaciones'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: AppStyles.primaryBrown),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // Función para navegar a la página de detalles del producto con animación
  void _navigateToProductDetail(BuildContext context, Product product, String heroTag) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: Duration(milliseconds: 300),
        child: ProductDetailPage(product: product),
      ),
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRODUCTOS DESTACADOS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: featuredProducts.length,
          itemBuilder: (context, index) {
            final heroTag = 'product-${featuredProducts[index].id}';
            return FeaturedProductCard(
              product: featuredProducts[index],
              heroTag: heroTag,
              onTap: () {
                _navigateToProductDetail(context, featuredProducts[index], heroTag);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoreProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MÁS PRODUCTOS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: moreProducts.length,
          itemBuilder: (context, index) {
            final heroTag = 'product-${moreProducts[index].id}';
            return ProductCard(
              product: moreProducts[index],
              heroTag: heroTag,
              onTap: () {
                _navigateToProductDetail(context, moreProducts[index], heroTag);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFloatingSearchBar() {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          onChanged: (value) {
            // Lógica para filtrar productos según la búsqueda
            print('Buscando: $value');
          },
          decoration: InputDecoration(
            hintText: 'Buscar en el catálogo',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppStyles.primaryBrown),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
