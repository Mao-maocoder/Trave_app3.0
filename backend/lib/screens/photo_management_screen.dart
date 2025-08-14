import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../services/photo_service.dart';
import '../constants.dart';
import '../theme.dart';

class PhotoManagementScreen extends StatefulWidget {
  @override
  _PhotoManagementScreenState createState() => _PhotoManagementScreenState();
}

class _PhotoManagementScreenState extends State<PhotoManagementScreen> {
  List<Photo> photos = [];
  bool isLoading = false;
  String? selectedSpot;
  String? selectedStatus;
  int currentPage = 1;
  bool hasMore = true;

  final List<String> spots = ['故宫', '天坛', '前门', '钟鼓楼', '什刹海万宁桥', '先农坛', '永定门'];
  final List<String> statuses = ['pending', 'approved', 'rejected'];

  // 示例图片数据（如无审核图片时展示）
  final List<Map<String, dynamic>> _demoPhotos = [
    {
      'path': 'assets/images/tmp/1.jpg',
      'uploader': 'admin',
      'spotName': '天坛',
      'status': 'approved',
      'title': '天坛美景',
    },
    {
      'path': 'assets/images/tmp/2.jpg',
      'uploader': 'user',
      'spotName': '故宫',
      'status': 'approved',
      'title': '故宫一角',
    },
    {
      'path': 'assets/images/tmp/3.jpg',
      'uploader': 'chun',
      'spotName': '钟鼓楼',
      'status': 'approved',
      'title': '钟鼓楼夜色',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      
      final photoService = PhotoService();
      // 获取照片列表
      final result = await photoService.getPhotosAdvanced(
        status: selectedStatus,
        spotName: selectedSpot,
        page: currentPage,
        limit: 10,
      );

      List<Photo> newPhotos = (result['photos'] as List)
          .map((json) => Photo.fromJson(json))
          .toList();

      // 如果用户已登录且没有选择特定状态，确保用户能看到自己上传的所有照片
      if (user != null && selectedStatus == null) {
        // 获取用户上传的所有照片
        final userResult = await photoService.getPhotosAdvanced(
          uploader: user.username,
          limit: 100,
        );
        
        final userPhotos = (userResult['photos'] as List)
            .map((json) => Photo.fromJson(json))
            .toList();
        
        // 过滤掉已经在当前列表中的照片
        final existingIds = newPhotos.map((p) => p.id).toSet();
        final additionalUserPhotos = userPhotos.where((p) => !existingIds.contains(p.id)).toList();
        
        // 合并照片列表
        newPhotos.addAll(additionalUserPhotos);
        
        // 按上传时间排序
        newPhotos.sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
      }

      if (mounted) {
        setState(() {
          if (currentPage == 1) {
            photos = newPhotos;
          } else {
            photos.addAll(newPhotos);
          }
          hasMore = newPhotos.length == 10;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  Future<void> _uploadPhotos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        final user = context.read<AuthProvider>().currentUser;
        if (user == null) {
          final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isChinese ? '请先登录' : 'Please login first')),
          );
          return;
        }

        // 显示上传对话框
        showDialog(
          context: context,
          builder: (context) => _UploadDialog(
            platformFiles: result.files,
            spots: spots,
            user: user,
            onUploadComplete: () {
              _loadPhotos();
              Navigator.pop(context);
            },
          ),
        );
      }
    } catch (e) {
      final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isChinese ? '选择文件失败: $e' : 'File selection failed: $e')),
      );
    }
  }

  Future<void> _reviewPhoto(Photo photo, String status) async {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;

    try {
      final photoService = PhotoService();
      await photoService.reviewPhoto(
        photoId: photo.id,
        approved: status == 'approved',
        comment: status == 'rejected' ? (isChinese ? '内容不符合要求' : 'Content does not meet requirements') : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isChinese ? '审核完成' : 'Review completed')),
      );

      _loadPhotos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isChinese ? '审核失败: $e' : 'Review failed: $e')),
      );
    }
  }

  Future<void> _deletePhoto(Photo photo) async {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '确认删除' : 'Confirm Delete', style: const TextStyle(fontFamily: kFontFamilyTitle)),
        content: Text(isChinese ? '确定要删除这张照片吗？' : 'Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isChinese ? '取消' : 'Cancel', style: const TextStyle(fontFamily: kFontFamilyTitle)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isChinese ? '删除' : 'Delete', style: const TextStyle(fontFamily: kFontFamilyTitle)),
            style: TextButton.styleFrom(foregroundColor: kErrorColor),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final photoService = PhotoService();
        await photoService.deletePhoto(photo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isChinese ? '删除成功' : 'Deleted successfully')),
        );
        _loadPhotos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isChinese ? '删除失败: $e' : 'Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;

    return Scaffold(
      appBar: AppBar(
        title: const Text('照片管理', style: TextStyle(fontFamily: kFontFamilyTitle)),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 筛选器
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSpot,
                    decoration: InputDecoration(
                      labelText: isChinese ? '景点' : 'Attraction',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(isChinese ? '全部景点' : 'All Attractions')),
                      ...spots.map((spot) => DropdownMenuItem(
                        value: spot,
                        child: Text(spot),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSpot = value;
                        currentPage = 1;
                      });
                      _loadPhotos();
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: isChinese ? '状态' : 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(isChinese ? '全部状态' : 'All Status')),
                      ...statuses.map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusText(status)),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                        currentPage = 1;
                      });
                      _loadPhotos();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 照片列表
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                currentPage = 1;
                await _loadPhotos();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: photos.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == photos.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  final photo = photos[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 照片预览
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kLightGrey,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(kBorderRadius),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(kBorderRadius),
                              ),
                              child: Image.network(
                                PhotoService().getPhotoUrl(photo.path),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: kGrey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        // 照片信息
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      photo.title.isNotEmpty ? photo.title : (isChinese ? '无标题' : 'No Title'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(photo.status),
                                      borderRadius: BorderRadius.circular(kBorderRadius),
                                    ),
                                    child: Text(
                                      _getStatusText(photo.status),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(isChinese ? '景点: ${photo.spotName}' : 'Attraction: ${photo.spotName}'),
                              Text(isChinese ? '上传者: ${photo.uploader} (${photo.userRole})' : 'Uploader: ${photo.uploader} (${photo.userRole})'),
                              Text(isChinese ? '上传时间: ${_formatDate(photo.uploadTime)}' : 'Upload Time: ${_formatDate(photo.uploadTime)}'),
                              if (photo.description.isNotEmpty)
                                Text(isChinese ? '描述: ${photo.description}' : 'Description: ${photo.description}'),
                            ],
                          ),
                        ),
                        
                        // 操作按钮
                        if (photo.isPending || _canDeletePhoto(photo))
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // 审核按钮（只有导游可以看到，且只对待审核照片显示）
                                if (photo.isPending && Provider.of<AuthProvider>(context, listen: false).currentUser?.isGuide == true) ...[
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _reviewPhoto(photo, 'approved'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kSuccessColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(isChinese ? '通过' : 'Approve'),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _reviewPhoto(photo, 'rejected'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kErrorColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(isChinese ? '拒绝' : 'Reject'),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                ],
                                // 删除按钮（根据权限显示）
                                if (_canDeletePhoto(photo))
                                  IconButton(
                                    onPressed: () => _deletePhoto(photo),
                                    icon: Icon(Icons.delete, color: kErrorColor),
                                    tooltip: isChinese ? '删除' : 'Delete',
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadPhotos,
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.add_a_photo, color: Colors.white),
        tooltip: isChinese ? '上传照片' : 'Upload Photos',
      ),
    );
  }

  String _getStatusText(String status) {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;

    switch (status) {
      case 'pending':
        return isChinese ? '待审核' : 'Pending';
      case 'approved':
        return isChinese ? '已通过' : 'Approved';
      case 'rejected':
        return isChinese ? '已拒绝' : 'Rejected';
      default:
        return status;
    }
  }

  // 检查用户是否可以删除照片
  bool _canDeletePhoto(Photo photo) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return false;

    // 导游可以删除所有照片
    if (user.isGuide) return true;

    // 用户只能删除自己上传的照片
    return photo.uploader == user.username;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return kWarningColor;
      case 'approved':
        return kSuccessColor;
      case 'rejected':
        return kErrorColor;
      default:
        return kGrey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _UploadDialog extends StatefulWidget {
  final List<PlatformFile> platformFiles;
  final List<String> spots;
  final User user;
  final VoidCallback onUploadComplete;

  _UploadDialog({
    required this.platformFiles,
    required this.spots,
    required this.user,
    required this.onUploadComplete,
  });

  @override
  _UploadDialogState createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  String? selectedSpot;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;

    return AlertDialog(
      title: Text(isChinese ? '上传照片' : 'Upload Photos', style: const TextStyle(fontFamily: kFontFamilyTitle)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isChinese
              ? '选择了 ${widget.platformFiles.length} 张照片'
              : 'Selected ${widget.platformFiles.length} photos', style: const TextStyle(fontFamily: kFontFamilyTitle)),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSpot,
              decoration: InputDecoration(
                labelText: isChinese ? '选择景点 *' : 'Select Attraction *',
                border: OutlineInputBorder(),
              ),
              items: widget.spots.map((spot) => DropdownMenuItem(
                value: spot,
                child: Text(spot),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSpot = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: isChinese ? '标题' : 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: isChinese ? '描述' : 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isUploading ? null : () => Navigator.pop(context),
          child: Text(isChinese ? '取消' : 'Cancel', style: const TextStyle(fontFamily: kFontFamilyTitle)),
        ),
        ElevatedButton(
          onPressed: isUploading || selectedSpot == null
              ? null
              : _uploadPhotos,
          child: isUploading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isChinese ? '上传' : 'Upload', style: const TextStyle(fontFamily: kFontFamilyTitle)),
        ),
      ],
    );
  }

  Future<void> _uploadPhotos() async {
    if (selectedSpot == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      final photoService = PhotoService();
      await photoService.uploadPhotosFromBytes(
        files: widget.platformFiles,
        spotName: selectedSpot!,
        user: widget.user,
        title: titleController.text.isNotEmpty ? titleController.text : null,
        description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
      );

      final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isChinese ? '上传成功' : 'Upload successful')),
      );

      widget.onUploadComplete();
    } catch (e) {
      final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isChinese ? '上传失败: $e' : 'Upload failed: $e')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }
} 