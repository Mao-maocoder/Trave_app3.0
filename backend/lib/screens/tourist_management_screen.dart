import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/api_host.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TouristManagementScreen extends StatefulWidget {
  const TouristManagementScreen({Key? key}) : super(key: key);

  @override
  State<TouristManagementScreen> createState() => _TouristManagementScreenState();
}

class _TouristManagementScreenState extends State<TouristManagementScreen> {
  List<Map<String, dynamic>> boundTourists = [];
  List<Map<String, dynamic>> pendingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTouristData();
  }

  Future<void> _loadTouristData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser != null) {
        // 加载已绑定游客
        final boundResponse = await http.get(
          Uri.parse('${getApiBaseUrl()}/api/binding/tourists/${currentUser.id}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (boundResponse.statusCode == 200) {
          final boundData = json.decode(boundResponse.body);
          setState(() {
            boundTourists = List<Map<String, dynamic>>.from(boundData['tourists'] ?? []);
          });
        }

        // 加载待审核申请
        final pendingResponse = await http.get(
          Uri.parse('${getApiBaseUrl()}/api/binding/pending/${currentUser.id}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (pendingResponse.statusCode == 200) {
          final pendingData = json.decode(pendingResponse.body);
          setState(() {
            pendingRequests = List<Map<String, dynamic>>.from(pendingData['requests'] ?? []);
          });
        }
      }
    } catch (e) {
      print('加载游客数据失败: $e');
      // 加载模拟数据
      _loadMockData();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadMockData() {
    setState(() {
      boundTourists = [
        {
          'id': '1',
          'username': '游客001',
          'email': 'tourist1@example.com',
          'created_at': '2024-01-15T10:30:00Z',
          'status': 'active'
        },
        {
          'id': '2',
          'username': '游客002',
          'email': 'tourist2@example.com',
          'created_at': '2024-01-16T14:20:00Z',
          'status': 'active'
        },
        {
          'id': '3',
          'username': '游客003',
          'email': 'tourist3@example.com',
          'created_at': '2024-01-17T09:15:00Z',
          'status': 'active'
        },
      ];

      pendingRequests = [
        {
          'id': '1',
          'tourist_id': '4',
          'tourist_username': '游客004',
          'tourist_email': 'tourist4@example.com',
          'created_at': '2024-01-18T16:45:00Z',
          'status': 'pending'
        },
        {
          'id': '2',
          'tourist_id': '5',
          'tourist_username': '游客005',
          'tourist_email': 'tourist5@example.com',
          'created_at': '2024-01-19T11:30:00Z',
          'status': 'pending'
        },
      ];
    });
  }

  Future<void> _reviewRequest(String requestId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/review_bind_request'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'bindingId': requestId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'approved' ? '申请已批准' : '申请已拒绝'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );
        _loadTouristData(); // 重新加载数据
      }
    } catch (e) {
      print('审核申请失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _unbindTourist(String touristId) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/unbind_guide'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'touristId': touristId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已解除绑定'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadTouristData(); // 重新加载数据
      }
    } catch (e) {
      print('解除绑定失败: $e');
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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isChinese ? '游客管理' : 'Tourist Management'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.people),
                text: isChinese ? '已绑定 (${boundTourists.length})' : 'Bound (${boundTourists.length})',
              ),
              Tab(
                icon: Icon(Icons.person_add),
                text: isChinese ? '待审核 (${pendingRequests.length})' : 'Pending (${pendingRequests.length})',
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildBoundTouristsTab(isChinese),
                  _buildPendingRequestsTab(isChinese),
                ],
              ),
      ),
    );
  }

  Widget _buildBoundTouristsTab(bool isChinese) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: boundTourists.length,
      itemBuilder: (context, index) {
        final tourist = boundTourists[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                tourist['username']?.substring(0, 1) ?? 'T',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              tourist['username'] ?? 'Unknown',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tourist['email'] ?? ''),
                Text(
                  '绑定时间: ${_formatDate(tourist['created_at'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'unbind') {
                  _showUnbindDialog(tourist['id'], tourist['username'], isChinese);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'unbind',
                  child: Row(
                    children: [
                      Icon(Icons.link_off, color: Colors.red),
                      SizedBox(width: 8),
                      Text(isChinese ? '解除绑定' : 'Unbind'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingRequestsTab(bool isChinese) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person_add, color: Colors.white),
            ),
            title: Text(
              request['tourist_username'] ?? 'Unknown',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request['tourist_email'] ?? ''),
                Text(
                  '申请时间: ${_formatDate(request['created_at'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _reviewRequest(request['id'], 'approved'),
                  tooltip: isChinese ? '批准' : 'Approve',
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => _reviewRequest(request['id'], 'rejected'),
                  tooltip: isChinese ? '拒绝' : 'Reject',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUnbindDialog(String touristId, String touristName, bool isChinese) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '解除绑定' : 'Unbind Tourist'),
        content: Text(isChinese 
          ? '确定要解除与 $touristName 的绑定关系吗？'
          : 'Are you sure you want to unbind from $touristName?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _unbindTourist(touristId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isChinese ? '解除绑定' : 'Unbind'),
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