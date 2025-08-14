import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoPlayEnabled = true;
  double _fontSize = 1.0;

  @override
  Widget build(BuildContext context) {
    final isChinese = Provider.of<LocaleProvider>(context).locale == AppLocale.zh;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? '设置' : 'Settings', style: const TextStyle(fontFamily: kFontFamilyTitle)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 通知设置
            _buildSection(
              title: isChinese ? '通知设置' : 'Notifications',
              icon: Icons.notifications,
              children: [
                SwitchListTile(
                  title: Text(isChinese ? '推送通知' : 'Push Notifications'),
                  subtitle: Text(isChinese ? '接收应用更新和活动提醒' : 'Receive app updates and activity reminders'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 显示设置
            _buildSection(
              title: isChinese ? '显示设置' : 'Display',
              icon: Icons.display_settings,
              children: [
                SwitchListTile(
                  title: Text(isChinese ? '深色模式' : 'Dark Mode'),
                  subtitle: Text(isChinese ? '使用深色主题' : 'Use dark theme'),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                ),
                ListTile(
                  title: Text(isChinese ? '字体大小' : 'Font Size'),
                  subtitle: Text(isChinese ? '调整应用字体大小' : 'Adjust app font size'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_fontSize > 0.8) {
                            setState(() {
                              _fontSize -= 0.1;
                            });
                          }
                        },
                      ),
                      Text('${(_fontSize * 100).toInt()}%'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_fontSize < 1.5) {
                            setState(() {
                              _fontSize += 0.1;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 媒体设置
            _buildSection(
              title: isChinese ? '媒体设置' : 'Media',
              icon: Icons.media_bluetooth_on,
              children: [
                SwitchListTile(
                  title: Text(isChinese ? '自动播放' : 'Auto Play'),
                  subtitle: Text(isChinese ? '自动播放视频和音频' : 'Auto play videos and audio'),
                  value: _autoPlayEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoPlayEnabled = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 语言设置
            _buildSection(
              title: isChinese ? '语言设置' : 'Language',
              icon: Icons.language,
              children: [
                ListTile(
                  title: Text(isChinese ? '应用语言' : 'App Language'),
                  subtitle: Text(isChinese ? '选择应用显示语言' : 'Choose app display language'),
                  trailing: DropdownButton<String>(
                    value: isChinese ? 'zh' : 'en',
                    items: [
                      DropdownMenuItem(
                        value: 'zh',
                        child: Text('中文'),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                        localeProvider.setLocale(value == 'zh' ? AppLocale.zh : AppLocale.en);
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 存储设置
            _buildSection(
              title: isChinese ? '存储设置' : 'Storage',
              icon: Icons.storage,
              children: [
                ListTile(
                  title: Text(isChinese ? '清除缓存' : 'Clear Cache'),
                  subtitle: Text(isChinese ? '释放存储空间' : 'Free up storage space'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showClearCacheDialog();
                  },
                ),
                ListTile(
                  title: Text(isChinese ? '数据使用情况' : 'Data Usage'),
                  subtitle: Text(isChinese ? '查看应用数据使用情况' : 'View app data usage'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showDataUsageDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _saveSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isChinese ? '保存设置' : 'Save Settings',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kPrimaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showClearCacheDialog() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '清除缓存' : 'Clear Cache'),
        content: Text(isChinese ? '确定要清除所有缓存数据吗？这将释放存储空间但可能需要重新下载一些内容。' : 'Are you sure you want to clear all cache data? This will free up storage space but may require re-downloading some content.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            child: Text(isChinese ? '清除' : 'Clear'),
          ),
        ],
      ),
    );
  }

  void _showDataUsageDialog() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '数据使用情况' : 'Data Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isChinese ? '应用数据使用情况：' : 'App data usage:'),
            const SizedBox(height: 16),
            Text('缓存数据: 45.2 MB'),
            Text('图片缓存: 23.1 MB'),
            Text('音频缓存: 12.8 MB'),
            Text('其他数据: 9.3 MB'),
            const SizedBox(height: 8),
            Text('总计: 90.4 MB', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isChinese ? '关闭' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '缓存已清除' : 'Cache cleared'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveSettings() {
    final isChinese = Provider.of<LocaleProvider>(context, listen: false).locale == AppLocale.zh;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isChinese ? '设置已保存' : 'Settings saved'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }
} 