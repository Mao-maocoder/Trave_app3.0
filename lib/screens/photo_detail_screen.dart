import 'package:flutter/material.dart';
import 'package:travel_app/models/photo.dart';
import '../services/photo_service.dart';

class PhotoDetailScreen extends StatefulWidget {
  final Photo photo;

  const PhotoDetailScreen({
    Key? key,
    required this.photo,
  }) : super(key: key);

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photo.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              try {
                await PhotoService().downloadPhoto(widget.photo.path);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('照片下载成功')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('照片下载失败: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 实现分享功能
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'photo-${widget.photo.id}',
              child: Image.asset(
                widget.photo.path,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.photo.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (widget.photo.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.photo.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        child: const Icon(Icons.person),
                        backgroundColor: Colors.grey[300],
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.photo.uploader,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            widget.photo.uploadTime.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
