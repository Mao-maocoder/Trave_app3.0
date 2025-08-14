import 'package:flutter/material.dart';

class PlatformImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const PlatformImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder?.call(context, imageUrl) ?? 
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget?.call(context, imageUrl, error) ?? 
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
      },
    );
  }
} 