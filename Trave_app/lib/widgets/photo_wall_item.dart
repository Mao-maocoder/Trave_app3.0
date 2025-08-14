import 'package:flutter/material.dart';
import 'package:travel_app/models/photo.dart';
import 'package:travel_app/screens/photo_detail_screen.dart';
import 'package:flutter/material.dart';
import '../utils/api_host.dart';

class PhotoWallItem extends StatelessWidget {
  final Photo photo;

  const PhotoWallItem({
    Key? key,
    required this.photo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPhotoDetail(context),
      child: Hero(
        tag: 'photo-${photo.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              photo.path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading asset image: ${photo.path}');
                debugPrint('Error details: $error');
                return _buildErrorWidget();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error),
            const SizedBox(height: 8),
            Text('标题: ${photo.title}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text('路径: ${photo.path}',
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoDetailScreen(photo: photo),
      ),
    );
  }
}
