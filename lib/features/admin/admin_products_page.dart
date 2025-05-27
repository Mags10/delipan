import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:delipan/models/product.dart';
import 'package:delipan/services/product_service.dart';
import 'package:delipan/services/unsplash_service.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final ProductService _productService = ProductService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _buildProductsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(),
        backgroundColor: AppStyles.primaryBrown,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
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
            'Gestión de Productos',
            style: AppStyles.appTitle.copyWith(fontSize: 24),
          ),
          Spacer(),
          Icon(Icons.inventory, color: AppStyles.primaryBrown),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppStyles.primaryBrown),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildProductsList() {
    return StreamBuilder<List<Product>>(
      stream: _searchQuery.isEmpty
          ? _productService.getProducts()
          : _productService.searchProducts(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppStyles.primaryBrown),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error al cargar productos',
                  style: AppStyles.cardTitle.copyWith(color: Colors.red),
                ),
                SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: AppStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: AppStyles.primaryBrown.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No hay productos registrados'
                      : 'No se encontraron productos',
                  style: AppStyles.heading.copyWith(
                    color: AppStyles.primaryBrown,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'Comienza agregando tu primer producto'
                      : 'Intenta con otros términos de búsqueda',
                  style: AppStyles.bodyText.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppStyles.cardTitle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.isFeatured)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Destacado',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Categoría: ${product.category}',
                    style: AppStyles.bodyText.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: AppStyles.bodyText.copyWith(
                          color: AppStyles.primaryBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Stock: ${product.stock}',
                        style: AppStyles.bodyText.copyWith(
                          color: product.stock > 0 ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.isActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 10,
                            color: product.isActive ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Botones de acción
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppStyles.primaryBrown),
                  onPressed: () => _showEditProductDialog(product),
                  style: IconButton.styleFrom(
                    backgroundColor: AppStyles.primaryBrown.withOpacity(0.1),
                  ),
                ),
                SizedBox(height: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(product),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    _showProductDialog(null);
  }

  void _showEditProductDialog(Product product) {
    _showProductDialog(product);
  }

  void _showProductDialog(Product? product) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '0');
    bool isFeatured = product?.isFeatured ?? false;
    bool isActive = product?.isActive ?? true;
    String? selectedImageUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            product == null ? 'Agregar Producto' : 'Editar Producto',
            style: AppStyles.cardTitle,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del producto',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixText: '\$',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 16),
                // Botón para buscar imagen
                ElevatedButton.icon(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      setDialogState(() => _isLoading = true);
                      try {
                        selectedImageUrl = await UnsplashService.getRandomProductImage(nameController.text);
                        setDialogState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Imagen encontrada para el producto'),
                            backgroundColor: Colors.green,
                          ),
                        );                      } catch (e) {
                        setDialogState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al buscar imagen: ${e.toString().replaceAll('Exception: ', '')}'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Primero ingresa el nombre del producto'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  icon: _isLoading 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.image_search),
                  label: Text(_isLoading ? 'Buscando...' : 'Buscar Imagen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryBrown,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                // Switches
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: Text('Destacado', style: AppStyles.bodyText),
                        value: isFeatured,
                        onChanged: (value) => setDialogState(() => isFeatured = value),
                        activeColor: AppStyles.primaryBrown,
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        title: Text('Activo', style: AppStyles.bodyText),
                        value: isActive,
                        onChanged: (value) => setDialogState(() => isActive = value),
                        activeColor: AppStyles.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveProduct(
                  product,
                  nameController.text,
                  double.tryParse(priceController.text) ?? 0,
                  descriptionController.text,
                  categoryController.text,
                  int.tryParse(stockController.text) ?? 0,
                  selectedImageUrl ?? product?.imageUrl ?? '',
                  isFeatured,
                  isActive,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryBrown,
                foregroundColor: Colors.white,
              ),
              child: Text(product == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct(
    Product? existingProduct,
    String name,
    double price,
    String description,
    String category,
    int stock,
    String imageUrl,
    bool isFeatured,
    bool isActive,
  ) async {
    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final newProduct = Product(
        id: existingProduct?.id ?? '',
        name: name,
        price: price,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/300x200?text=Sin+Imagen',
        description: description,
        category: category.isNotEmpty ? category : 'general',
        isFeatured: isFeatured,
        isActive: isActive,
        stock: stock,
        createdAt: existingProduct?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (existingProduct == null) {
        success = await _productService.addProduct(newProduct);
      } else {
        success = await _productService.updateProduct(existingProduct.id, newProduct);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existingProduct == null ? 'Producto agregado exitosamente' : 'Producto actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al guardar el producto');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar Producto', style: AppStyles.cardTitle),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${product.name}"? Esta acción no se puede deshacer.',
          style: AppStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      final success = await _productService.deleteProduct(product.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al eliminar el producto');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
