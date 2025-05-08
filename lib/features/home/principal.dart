import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:delipan/models/product.dart';
import 'package:delipan/widgets/featured_product_card.dart';
import 'package:delipan/widgets/product_card.dart';
import 'package:delipan/data/dummy_data.dart';
import 'package:delipan/features/product/product_detail.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:delipan/models/cart.dart';
import 'package:delipan/features/cart/cart_page.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  // Obtener los productos de prueba
  final List<Product> featuredProducts = DummyData.getFeaturedProducts();
  final List<Product> moreProducts = DummyData.getMoreProducts();

  // Variables para manejar la búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Agregar listener al controlador de texto para actualizar la búsqueda
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Limpiar el controlador cuando se destruya el widget
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Método para manejar cambios en el campo de búsqueda
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
      if (_isSearching) {
        _searchProducts();
      }
    });
  }

  // Método para buscar productos basados en la consulta
  void _searchProducts() {
    final query = _searchQuery.toLowerCase();
    // Buscar en todos los productos (destacados y no destacados)
    final allProducts = [...featuredProducts, ...moreProducts];
    _searchResults = allProducts.where((product) {
      return product.name.toLowerCase().contains(query) || 
             product.description.toLowerCase().contains(query) ||
             product.category.toLowerCase().contains(query);
    }).toList();
  }

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
                      child: _isSearching 
                          ? _buildSearchResultsSection()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
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
    final cart = Provider.of<Cart>(context);
    
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
          // Icono del carrito con contador
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: AppStyles.primaryBrown),
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
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar en el catálogo',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppStyles.primaryBrown),
            suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                    });
                  },
                )
              : null,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          style: TextStyle(fontSize: 16),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _searchQuery = value;
                _isSearching = true;
                _searchProducts();
              });
            }
          },
        ),
      ),
    );
  }

  // Widget para mostrar los resultados de búsqueda
  Widget _buildSearchResultsSection() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Icon(
              Icons.search_off,
              size: 80,
              color: AppStyles.primaryBrown.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Intenta con otra palabra clave',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            'RESULTADOS DE BÚSQUEDA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          'Se encontraron ${_searchResults.length} productos para "$_searchQuery"',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final product = _searchResults[index];
            final heroTag = 'search-${product.id}';
            
            // Diseño especial para resultados de búsqueda
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _navigateToProductDetail(context, product, heroTag),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del producto
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Hero(
                          tag: heroTag,
                          child: Image.network(
                            product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Información del producto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Categoría 
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppStyles.primaryBrown.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product.category.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppStyles.primaryBrown,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // Precio
                                Text(
                                  '\$${product.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppStyles.primaryBrown,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
