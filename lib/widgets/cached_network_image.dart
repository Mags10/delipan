import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  
  const SafeNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final fallbackImage = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppStyles.primaryBrown.withOpacity(0.5),
          size: (width != null && height != null) 
              ? (width! < height! ? width! * 0.5 : height! * 0.5)
              : 24,
        ),
      ),
    );
    
    // Verificar si la URL es válida
    if (imageUrl.isEmpty || !Uri.parse(imageUrl).isAbsolute) {
      return fallbackImage;
    }
    
    final imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Devolver imagen de fallback en caso de error
        return fallbackImage;
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
              strokeWidth: 2.0,
              color: AppStyles.primaryBrown,
            ),
          ),
        );
      },
    );
    
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
}
