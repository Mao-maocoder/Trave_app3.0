import 'package:flutter/material.dart';
import '../models/user.dart';

class TestRegisterScreen extends StatefulWidget {
  const TestRegisterScreen({Key? key}) : super(key: key);

  @override
  State<TestRegisterScreen> createState() => _TestRegisterScreenState();
}

class _TestRegisterScreenState extends State<TestRegisterScreen> {
  UserRole _selectedRole = UserRole.tourist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测试注册页面'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '测试角色选择功能',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UserRole>(
                  value: _selectedRole,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: UserRole.tourist,
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text('游客'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: UserRole.guide,
                      child: Row(
                        children: [
                          const Icon(Icons.work, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text('导游'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '当前选择: ${_selectedRole == UserRole.tourist ? '游客' : '导游'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
} 