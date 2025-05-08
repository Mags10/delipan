class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final bool isFeatured;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description = '',
    this.isFeatured = false,
    this.category = 'general',
  });
}