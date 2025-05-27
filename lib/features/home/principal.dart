import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:delipan/models/product.dart';
import 'package:delipan/widgets/featured_product_card.dart';
import 'package:delipan/widgets/product_card.dart';
import 'package:delipan/services/product_service.dart';
import 'package:delipan/features/product/product_detail.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:delipan/models/firebase_cart.dart';
import 'package:delipan/features/cart/cart_page.dart';
import 'package:delipan/features/admin/admin_page.dart';
import 'package:delipan/services/user_service.dart';
import 'package:delipan/features/notifications/notifications_screen.dart';
import 'package:delipan/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delipan/utils/auth_services.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isAdmin = false;
  int _unreadCount = 0;
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _checkAdminStatus();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _userService.isCurrentUserAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }
  Future<void> _loadUnreadCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final count = await _notificationService.getUnreadCount(user.uid);
      setState(() {
        _unreadCount = count;
      });
    }
  }
  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/auth');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: NotificationsScreen(),
      ),
    ).then((_) {
      // Recargar el conteo cuando se regrese de la pantalla de notificaciones
      _loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProducts,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 60), // Espacio para la barra de búsqueda
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _isSearching
                                ? _buildSearchResults()
                                : Column(
                                    children: [
                                      SizedBox(height: 10),
                                      _buildFeaturedProductsSection(),
                                      SizedBox(height: 20),
                                      _buildMoreProductsSection(),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    // Barra de búsqueda flotante
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _buildFloatingSearchBar(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshProducts() async {
    await Future.delayed(Duration(seconds: 1));
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
          Text(
            'Delipan',
            style: AppStyles.appTitle,
          ),
          Spacer(),
          PopupMenuButton<String>(
            icon: Icon(Icons.person_outline, color: AppStyles.primaryBrown),
            offset: Offset(0, 50),            onSelected: (value) {
              switch (value) {
                case 'mi_cuenta':
                  print('Navegando a Mi Cuenta');
                  break;
                case 'admin':
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: AdminPage(),
                    ),
                  );
                  break;
                case 'cerrar_sesion':
                  _signOut();
                  break;
              }
            },itemBuilder: (BuildContext context) {
              List<PopupMenuItem<String>> items = [
                
              ];

              // Agregar opción de admin solo si el usuario es administrador
              if (_isAdmin) {
                items.add(
                  PopupMenuItem<String>(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: AppStyles.primaryBrown),
                        SizedBox(width: 10),
                        Text('Administración', style: AppStyles.bodyText),
                      ],
                    ),
                  ),
                );
              }

              items.add(
                PopupMenuItem<String>(
                  value: 'cerrar_sesion',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppStyles.primaryBrown),
                      SizedBox(width: 10),
                      Text('Cerrar Sesión', style: AppStyles.bodyText),
                    ],
                  ),
                ),
              );

              return items;
            },          ),
          // Botón de notificaciones con badge
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: AppStyles.primaryBrown),
                onPressed: _navigateToNotifications,
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Consumer<FirebaseCart>(
            builder: (context, cart, child) {
              return Stack(
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
                          style: AppStyles.bodyText.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

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
      children: [        Text(
          'PRODUCTOS DESTACADOS',
          style: AppStyles.cardTitle.copyWith(
            color: AppStyles.darkGrey,
          ),
        ),
        SizedBox(height: 10),
        StreamBuilder<List<Product>>(
          stream: _productService.getFeaturedProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppStyles.primaryBrown),
              );
            }            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar productos destacados',
                  style: AppStyles.bodyText.copyWith(color: Colors.red),
                ),
              );
            }

            final featuredProducts = snapshot.data ?? [];            if (featuredProducts.isEmpty) {
              return Center(
                child: Text(
                  'No hay productos destacados disponibles',
                  style: AppStyles.bodyText,
                ),
              );
            }

            return ListView.builder(
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoreProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        Text(
          'MÁS PRODUCTOS',
          style: AppStyles.cardTitle.copyWith(
            color: AppStyles.darkGrey,
          ),
        ),
        SizedBox(height: 10),
        StreamBuilder<List<Product>>(
          stream: _productService.getMoreProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppStyles.primaryBrown),
              );
            }            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar productos',
                  style: AppStyles.bodyText.copyWith(color: Colors.red),
                ),
              );
            }

            final moreProducts = snapshot.data ?? [];            if (moreProducts.isEmpty) {
              return Center(
                child: Text(
                  'No hay productos disponibles',
                  style: AppStyles.bodyText,
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 8,
                childAspectRatio: 2.2,
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
          controller: _searchController,          decoration: InputDecoration(
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
            hintStyle: AppStyles.bodyText.copyWith(
              color: Colors.grey[600],
            ),
          ),
          style: AppStyles.bodyText,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _searchQuery = value;
                _isSearching = true;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Product>>(
      stream: _productService.searchProducts(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppStyles.primaryBrown),
          );
        }        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al buscar productos',
              style: AppStyles.bodyText.copyWith(color: Colors.red),
            ),
          );
        }

        final searchResults = snapshot.data ?? [];

        if (searchResults.isEmpty) {
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
                SizedBox(height: 16),                Text(
                  'No se encontraron productos',
                  style: AppStyles.heading.copyWith(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Intenta con otra palabra clave',
                  style: AppStyles.bodyText.copyWith(
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
          children: [            Text(
              'RESULTADOS DE BÚSQUEDA',
              style: AppStyles.cardTitle.copyWith(
                color: AppStyles.darkGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Se encontraron ${searchResults.length} productos para "$_searchQuery"',
              style: AppStyles.bodyText.copyWith(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final product = searchResults[index];
                final heroTag = 'search-${product.id}';

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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),                            child: Hero(
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
                                    decoration: BoxDecoration(
                                      color: AppStyles.primaryBrown.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.fastfood,
                                      color: AppStyles.primaryBrown.withOpacity(0.5),
                                      size: 40,
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppStyles.primaryBrown,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [                                Text(
                                  product.name,
                                  style: AppStyles.cardTitle,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  product.description,
                                  style: AppStyles.bodyText.copyWith(
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
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppStyles.primaryBrown.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child:                                      Text(
                                        product.category.toUpperCase(),
                                        style: AppStyles.bodyText.copyWith(
                                          fontSize: 11,
                                          color: AppStyles.primaryBrown,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),                                    Text(
                                      '\$${product.price.toStringAsFixed(0)}',
                                      style: AppStyles.cardTitle.copyWith(
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
      },
    );
  }
}
