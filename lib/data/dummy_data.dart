import 'package:delipan/models/product.dart';

class DummyData {
  static List<Product> products = [
    Product(
      id: '1',
      name: 'Pan Francés',
      price: 3000,
      imageUrl: 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73',
      description: 'Pan francés tradicional, recién horneado',
      isFeatured: true,
      category: 'panes',
    ),
    Product(
      id: '2',
      name: 'Croissant',
      price: 5000,
      imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a',
      description: 'Croissant de mantequilla, crujiente por fuera y suave por dentro',
      isFeatured: true,
      category: 'bollería',
    ),
    Product(
      id: '3',
      name: 'Pan de Sandwich',
      price: 8000,
      imageUrl: 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df',
      description: 'Pan de molde para sandwiches, corte grueso',
      isFeatured: true,
      category: 'panes',
    ),
    Product(
      id: '4',
      name: 'Baguette',
      price: 6000,
      imageUrl: 'https://images.unsplash.com/photo-1568471173242-461f0a730452',
      description: 'Baguette tradicional con masa madre',
      isFeatured: false,
      category: 'panes',
    ),
    Product(
      id: '8',
      name: 'Baguette',
      price: 6000,
      imageUrl: 'https://images.unsplash.com/photo-1568471173242-461f0a730452',
      description: 'Baguette tradicional con masa madre',
      isFeatured: false,
      category: 'panes',
    ),
    Product(
      id: '5',
      name: 'Donas',
      price: 4000,
      imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b',
      description: 'Donas glaseadas de varios sabores',
      isFeatured: false,
      category: 'dulces',
    ),
    Product(
      id: '6',
      name: 'Muffins de Chocolate',
      price: 5500,
      imageUrl: 'https://images.unsplash.com/photo-1607478900766-efe13248b125',
      description: 'Muffins con chispas de chocolate',
      isFeatured: false,
      category: 'dulces',
    ),
    Product(
      id: '7',
      name: 'Pan de Queso',
      price: 7000,
      imageUrl: 'https://images.unsplash.com/photo-1631897642056-97a7abff6818',
      description: 'Pan relleno de queso fundido',
      isFeatured: false,
      category: 'especialidades',
    ),
    Product(
      id: '9',
      name: 'Donas',
      price: 4000,
      imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b',
      description: 'Donas glaseadas de varios sabores',
      isFeatured: false,
      category: 'dulces',
    ),
    Product(
      id: '10',
      name: 'Muffins de Chocolate',
      price: 5500,
      imageUrl: 'https://images.unsplash.com/photo-1607478900766-efe13248b125',
      description: 'Muffins con chispas de chocolate',
      isFeatured: false,
      category: 'dulces',
    ),
    Product(
      id: '11',
      name: 'Pan de Queso',
      price: 7000,
      imageUrl: 'https://images.unsplash.com/photo-1631897642056-97a7abff6818',
      description: 'Pan relleno de queso fundido',
      isFeatured: false,
      category: 'especialidades',
    ),
  ];

  static List<Product> getFeaturedProducts() {
    return products.where((product) => product.isFeatured).toList();
  }

  static List<Product> getMoreProducts() {
    return products.where((product) => !product.isFeatured).toList();
  }

  static List<Product> getProductsByCategory(String category) {
    return products.where((product) => product.category == category).toList();
  }
}