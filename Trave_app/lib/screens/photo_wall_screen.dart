import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_app/widgets/photo_wall_item.dart';
import 'package:travel_app/models/photo.dart';
import 'package:travel_app/services/photo_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class PhotoWallScreen extends StatefulWidget {
  const PhotoWallScreen({Key? key}) : super(key: key);

  @override
  _PhotoWallScreenState createState() => _PhotoWallScreenState();
}

class _PhotoWallScreenState extends State<PhotoWallScreen> {
  final PhotoService _photoService = PhotoService();
  List<Photo> _photos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final photosData = await _photoService.getPhotos();
      final photos = photosData.map((data) => Photo.fromJson(data)).toList();
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载照片失败，请稍后重试';
        print('Error details: $e'); // 添加日志以便调试
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadPhoto() async {
    // 使用 file_picker 选择图片
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        final platformFile = result.files.first;
        final bytes = platformFile.bytes;
        final name = platformFile.name;
        
        if (bytes == null) {
          throw Exception('无法读取文件');
        }
        
        await _photoService.uploadPhotoBytes(
          bytes: bytes,
          fileName: name,
          title: '未知景点',
        );
        setState(() {
          _isLoading = false;
        });
        
        // 刷新照片列表
        await _loadPhotos();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('照片上传成功')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('照片上传失败: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('照片墙'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: _uploadPhoto,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPhotos,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPhotos,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_photos.isEmpty) {
      return const Center(child: Text('暂无照片'));
    }

    return RefreshIndicator(
      onRefresh: _loadPhotos,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          return PhotoWallItem(photo: _photos[index]);
        },
      ),
    );
  }
}
