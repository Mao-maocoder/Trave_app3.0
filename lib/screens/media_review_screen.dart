import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import '../utils/api_host.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MediaReviewScreen extends StatefulWidget {
  const MediaReviewScreen({Key? key}) : super(key: key);

  @override
  State<MediaReviewScreen> createState() => _MediaReviewScreenState();
}

class _MediaReviewScreenState extends State<MediaReviewScreen> {
  List<Map<String, dynamic>> pendingPhotos = [];
  List<Map<String, dynamic>> pendingVideos = [];
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMediaData();
  }

  Future<void> _loadMediaData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 加载待审核照片
      final photosResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/photos/pending'),
        headers: {'Content-Type': 'application/json'},
      );

      if (photosResponse.statusCode == 200) {
        final photosData = json.decode(photosResponse.body);
        setState(() {
          pendingPhotos = List<Map<String, dynamic>>.from(photosData['photos'] ?? []);
        });
      }

      // 加载待审核视频
      final videosResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/videos/pending'),
        headers: {'Content-Type': 'application/json'},
      );

      if (videosResponse.statusCode == 200) {
        final videosData = json.decode(videosResponse.body);
        setState(() {
          pendingVideos = List<Map<String, dynamic>>.from(videosData['videos'] ?? []);
        });
      }

      // 加载举报
      final reportsResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/reports'),
        headers: {'Content-Type': 'application/json'},
      );

      if (reportsResponse.statusCode == 200) {
        final reportsData = json.decode(reportsResponse.body);
        setState(() {
          reports = List<Map<String, dynamic>>.from(reportsData['reports'] ?? []);
        });
      }
    } catch (e) {
      print('加载媒体数据失败: $e');
      _loadMockData();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadMockData() {
    setState(() {
      pendingPhotos = [
        {
          'id': '1',
          'filename': 'photo1.jpg',
          'uploader': '游客001',
          'spot_name': '故宫',
          'title': '故宫角楼',
          'description': '美丽的故宫角楼',
          'uploaded_at': '2024-01-18T10:30:00Z',
          'image_url': 'https://example.com/photo1.jpg',
        },
        {
          'id': '2',
          'filename': 'photo2.jpg',
          'uploader': '游客002',
          'spot_name': '天坛',
          'title': '祈年殿',
          'description': '天坛祈年殿',
          'uploaded_at': '2024-01-19T14:20:00Z',
          'image_url': 'https://example.com/photo2.jpg',
        },
        {
          'id': '3',
          'filename': 'photo3.jpg',
          'uploader': '游客003',
          'spot_name': '钟鼓楼',
          'title': '钟楼',
          'description': '钟鼓楼钟楼',
          'uploaded_at': '2024-01-20T09:15:00Z',
          'image_url': 'https://example.com/photo3.jpg',
        },
      ];

      pendingVideos = [
        {
          'id': '1',
          'filename': 'video1.mp4',
          'uploader': '游客004',
          'spot_name': '前门大街',
          'title': '前门大街游览',
          'description': '前门大街的繁华景象',
          'uploaded_at': '2024-01-21T16:45:00Z',
          'video_url': 'https://example.com/video1.mp4',
          'duration': '2:30',
        },
        {
          'id': '2',
          'filename': 'video2.mp4',
          'uploader': '游客005',
          'spot_name': '什刹海',
          'title': '什刹海风光',
          'description': '什刹海的美丽风光',
          'uploaded_at': '2024-01-22T11:30:00Z',
          'video_url': 'https://example.com/video2.mp4',
          'duration': '1:45',
        },
      ];

      reports = [
        {
          'id': '1',
          'reporter': '游客006',
          'reported_content': 'photo1.jpg',
          'reason': '不当内容',
          'reported_at': '2024-01-23T10:00:00Z',
          'status': 'pending',
        },
        {
          'id': '2',
          'reporter': '游客007',
          'reported_content': 'video1.mp4',
          'reason': '版权问题',
          'reported_at': '2024-01-24T15:30:00Z',
          'status': 'pending',
        },
      ];
    });
  }

  Future<void> _reviewMedia(String mediaId, String type, String status) async {
    try {
      final endpoint = type == 'photo' ? '/api/photos/review' : '/api/videos/review';
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mediaId': mediaId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'approved' ? '已批准' : '已拒绝'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );
        _loadMediaData(); // 重新加载数据
      }
    } catch (e) {
      print('审核媒体失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleReport(String reportId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/reports/handle'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reportId': reportId,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'resolve' ? '举报已处理' : '举报已忽略'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMediaData(); // 重新加载数据
      }
    } catch (e) {
      print('处理举报失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isChinese ? '媒体审核' : 'Media Review'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.photo),
                text: isChinese ? '照片 (${pendingPhotos.length})' : 'Photos (${pendingPhotos.length})',
              ),
              Tab(
                icon: Icon(Icons.videocam),
                text: isChinese ? '视频 (${pendingVideos.length})' : 'Videos (${pendingVideos.length})',
              ),
              Tab(
                icon: Icon(Icons.report),
                text: isChinese ? '举报 (${reports.length})' : 'Reports (${reports.length})',
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildPhotosTab(isChinese),
                  _buildVideosTab(isChinese),
                  _buildReportsTab(isChinese),
                ],
              ),
      ),
    );
  }

  Widget _buildPhotosTab(bool isChinese) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: pendingPhotos.length,
      itemBuilder: (context, index) {
        final photo = pendingPhotos[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片预览
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    photo['image_url'] ?? 'https://via.placeholder.com/400x200',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 64, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                photo['title'] ?? '无标题',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '上传者: ${photo['uploader']} | 景点: ${photo['spot_name']}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '上传时间: ${_formatDate(photo['uploaded_at'])}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (photo['description']?.isNotEmpty == true) ...[
                      SizedBox(height: 8),
                      Text(
                        photo['description'],
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _reviewMedia(photo['id'], 'photo', 'approved'),
                            icon: Icon(Icons.check, color: Colors.white),
                            label: Text(isChinese ? '批准' : 'Approve'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _reviewMedia(photo['id'], 'photo', 'rejected'),
                            icon: Icon(Icons.close, color: Colors.white),
                            label: Text(isChinese ? '拒绝' : 'Reject'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideosTab(bool isChinese) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: pendingVideos.length,
      itemBuilder: (context, index) {
        final video = pendingVideos[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 视频预览
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        color: Colors.black,
                        child: Center(
                          child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video['duration'] ?? '0:00',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['title'] ?? '无标题',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '上传者: ${video['uploader']} | 景点: ${video['spot_name']}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '上传时间: ${_formatDate(video['uploaded_at'])}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (video['description']?.isNotEmpty == true) ...[
                      SizedBox(height: 8),
                      Text(
                        video['description'],
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _reviewMedia(video['id'], 'video', 'approved'),
                            icon: Icon(Icons.check, color: Colors.white),
                            label: Text(isChinese ? '批准' : 'Approve'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _reviewMedia(video['id'], 'video', 'rejected'),
                            icon: Icon(Icons.close, color: Colors.white),
                            label: Text(isChinese ? '拒绝' : 'Reject'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportsTab(bool isChinese) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.report, color: Colors.white),
            ),
            title: Text(
              '举报: ${report['reported_content']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('举报人: ${report['reporter']}'),
                Text('原因: ${report['reason']}'),
                Text(
                  '举报时间: ${_formatDate(report['reported_at'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _handleReport(report['id'], 'resolve'),
                  tooltip: isChinese ? '处理' : 'Resolve',
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () => _handleReport(report['id'], 'ignore'),
                  tooltip: isChinese ? '忽略' : 'Ignore',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
} 