import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import '../utils/api_host.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewManagementScreen extends StatefulWidget {
  const ReviewManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReviewManagementScreen> createState() => _ReviewManagementScreenState();
}

class _ReviewManagementScreenState extends State<ReviewManagementScreen> {
  List<Map<String, dynamic>> pendingReviews = [];
  List<Map<String, dynamic>> approvedReviews = [];
  List<Map<String, dynamic>> rejectedReviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 加载待审核评价
      final pendingResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/reviews/pending'),
        headers: {'Content-Type': 'application/json'},
      );

      if (pendingResponse.statusCode == 200) {
        final pendingData = json.decode(pendingResponse.body);
        setState(() {
          pendingReviews = List<Map<String, dynamic>>.from(pendingData['reviews'] ?? []);
        });
      }

      // 加载已批准评价
      final approvedResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/reviews/approved'),
        headers: {'Content-Type': 'application/json'},
      );

      if (approvedResponse.statusCode == 200) {
        final approvedData = json.decode(approvedResponse.body);
        setState(() {
          approvedReviews = List<Map<String, dynamic>>.from(approvedData['reviews'] ?? []);
        });
      }

      // 加载已拒绝评价
      final rejectedResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/reviews/rejected'),
        headers: {'Content-Type': 'application/json'},
      );

      if (rejectedResponse.statusCode == 200) {
        final rejectedData = json.decode(rejectedResponse.body);
        setState(() {
          rejectedReviews = List<Map<String, dynamic>>.from(rejectedData['reviews'] ?? []);
        });
      }
    } catch (e) {
      print('加载评价数据失败: $e');
      _loadMockData();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadMockData() {
    setState(() {
      pendingReviews = [
        {
          'id': '1',
          'user_name': '游客001',
          'spot_name': '故宫',
          'rating': 5,
          'content': '故宫真是太美了！建筑宏伟，历史感很强，值得一游。',
          'created_at': '2024-01-18T10:30:00Z',
          'status': 'pending',
        },
        {
          'id': '2',
          'user_name': '游客002',
          'spot_name': '天坛',
          'rating': 4,
          'content': '天坛公园环境很好，祈年殿很壮观，但是人有点多。',
          'created_at': '2024-01-19T14:20:00Z',
          'status': 'pending',
        },
        {
          'id': '3',
          'user_name': '游客003',
          'spot_name': '钟鼓楼',
          'rating': 3,
          'content': '钟鼓楼还可以，但是感觉有点小，很快就看完了。',
          'created_at': '2024-01-20T09:15:00Z',
          'status': 'pending',
        },
      ];

      approvedReviews = [
        {
          'id': '4',
          'user_name': '游客004',
          'spot_name': '前门大街',
          'rating': 5,
          'content': '前门大街很有老北京的味道，小吃很多，值得推荐！',
          'created_at': '2024-01-15T16:45:00Z',
          'status': 'approved',
        },
        {
          'id': '5',
          'user_name': '游客005',
          'spot_name': '什刹海',
          'rating': 4,
          'content': '什刹海风景优美，可以划船，晚上灯光很美。',
          'created_at': '2024-01-16T11:30:00Z',
          'status': 'approved',
        },
      ];

      rejectedReviews = [
        {
          'id': '6',
          'user_name': '游客006',
          'spot_name': '永定门',
          'rating': 2,
          'content': '这里太差了，一点都不好玩，浪费时间和金钱。',
          'created_at': '2024-01-17T13:20:00Z',
          'status': 'rejected',
          'reject_reason': '评价过于负面，缺乏建设性',
        },
      ];
    });
  }

  Future<void> _reviewReview(String reviewId, String status, {String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/reviews/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reviewId': reviewId,
          'status': status,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'approved' ? '评价已批准' : '评价已拒绝'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );
        _loadReviewData(); // 重新加载数据
      }
    } catch (e) {
      print('审核评价失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/reviews/$reviewId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('评价已删除'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadReviewData(); // 重新加载数据
      }
    } catch (e) {
      print('删除评价失败: $e');
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
          title: Text(isChinese ? '评价管理' : 'Review Management'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.pending),
                text: isChinese ? '待审核 (${pendingReviews.length})' : 'Pending (${pendingReviews.length})',
              ),
              Tab(
                icon: Icon(Icons.thumb_up),
                text: isChinese ? '已批准 (${approvedReviews.length})' : 'Approved (${approvedReviews.length})',
              ),
              Tab(
                icon: Icon(Icons.thumb_down),
                text: isChinese ? '已拒绝 (${rejectedReviews.length})' : 'Rejected (${rejectedReviews.length})',
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildPendingReviewsTab(isChinese),
                  _buildApprovedReviewsTab(isChinese),
                  _buildRejectedReviewsTab(isChinese),
                ],
              ),
      ),
    );
  }

  Widget _buildPendingReviewsTab(bool isChinese) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: pendingReviews.length,
      itemBuilder: (context, index) {
        final review = pendingReviews[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        review['user_name']?.substring(0, 1) ?? 'U',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['user_name'] ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            review['spot_name'] ?? 'Unknown Spot',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    _buildRatingStars(review['rating'] ?? 0),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  review['content'] ?? '',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '提交时间: ${_formatDate(review['created_at'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _reviewReview(review['id'], 'approved'),
                        icon: Icon(Icons.check, color: Colors.white),
                        label: Text(isChinese ? '批准' : 'Approve'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRejectDialog(review['id'], isChinese),
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
        );
      },
    );
  }

  Widget _buildApprovedReviewsTab(bool isChinese) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: approvedReviews.length,
      itemBuilder: (context, index) {
        final review = approvedReviews[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['user_name'] ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            review['spot_name'] ?? 'Unknown Spot',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    _buildRatingStars(review['rating'] ?? 0),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  review['content'] ?? '',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '批准时间: ${_formatDate(review['created_at'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteDialog(review['id'], review['user_name'], isChinese),
                        icon: Icon(Icons.delete, color: Colors.white),
                        label: Text(isChinese ? '删除' : 'Delete'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRejectedReviewsTab(bool isChinese) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: rejectedReviews.length,
      itemBuilder: (context, index) {
        final review = rejectedReviews[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['user_name'] ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            review['spot_name'] ?? 'Unknown Spot',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    _buildRatingStars(review['rating'] ?? 0),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  review['content'] ?? '',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '拒绝时间: ${_formatDate(review['created_at'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (review['reject_reason']?.isNotEmpty == true) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '拒绝原因: ${review['reject_reason']}',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _reviewReview(review['id'], 'approved'),
                        icon: Icon(Icons.restore, color: Colors.white),
                        label: Text(isChinese ? '恢复' : 'Restore'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteDialog(review['id'], review['user_name'], isChinese),
                        icon: Icon(Icons.delete, color: Colors.white),
                        label: Text(isChinese ? '删除' : 'Delete'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  void _showRejectDialog(String reviewId, bool isChinese) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '拒绝评价' : 'Reject Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isChinese ? '请输入拒绝原因:' : 'Please enter the rejection reason:'),
            SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: isChinese ? '拒绝原因...' : 'Rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _reviewReview(reviewId, 'rejected', reason: reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isChinese ? '拒绝' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String reviewId, String userName, bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '删除评价' : 'Delete Review'),
        content: Text(isChinese 
          ? '确定要删除 $userName 的评价吗？此操作不可撤销。'
          : 'Are you sure you want to delete the review from $userName? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReview(reviewId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isChinese ? '删除' : 'Delete'),
          ),
        ],
      ),
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