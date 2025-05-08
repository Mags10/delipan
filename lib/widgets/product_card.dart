import 'package:flutter/material.dart';
import 'package:delipan/models/product.dart';
import 'package:delipan/config/styles.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final String heroTag;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.heroTag = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                "\$${product.price.toStringAsFixed(0)} mxn",
                style: TextStyle(
                  color: AppStyles.primaryBrown,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Hero(
                  tag: heroTag,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}