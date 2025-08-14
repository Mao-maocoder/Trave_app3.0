import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_env.dart';
import '../constants.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({Key? key}) : super(key: key);

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  List categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/api/terms'));
      print('terms response: \n${response.body}'); // 调试用
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body)['data'];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('categories: $categories'); // 调试用
    if (loading) return const Center(child: CircularProgressIndicator());
    if (categories == null || categories.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('专有名词解释', style: TextStyle(fontFamily: kFontFamilyTitle))),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          return ExpansionTile(
            title: Text(cat['category'] ?? ''),
            children: [
              ...List<Widget>.from((cat['terms'] as List).map((term) => ListTile(
                title: Text(term['name'] ?? ''),
                subtitle: Text(term['definition'] ?? ''),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(term['name'] ?? '', style: const TextStyle(fontFamily: kFontFamilyTitle)),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (term['pinyin'] != null) Text('拼音: ${term['pinyin']}'),
                            Text('定义: ${term['definition'] ?? ''}'),
                            if (term['application'] != null) ...[
                              const SizedBox(height: 8),
                              Text('应用: ${term['application']}'),
                            ],
                            if (term['extension'] != null) ...[
                              const SizedBox(height: 8),
                              Text('延伸: ${term['extension']}'),
                            ],
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('关闭', style: TextStyle(fontFamily: kFontFamilyTitle)),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  );
                },
              )))
            ],
          );
        },
      ),
    );
  }
} 