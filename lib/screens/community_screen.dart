import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../models/chat.dart';
import '../models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/message.dart';
import 'dart:async';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区', style: TextStyle(fontFamily: 'PingFang SC', fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _fakeChats.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
        itemBuilder: (context, index) {
          final chat = _fakeChats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(chat['avatar'] as String),
              radius: 26,
            ),
            title: Text(
              chat['username'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'PingFang SC'),
            ),
            subtitle: Text(
              chat['lastMsg'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'] as String,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if ((chat['unread'] as int) > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
                  child: WechatFakeChat(
                    username: chat['username'] as String,
                    avatar: chat['avatar'] as String,
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }
}

// 假数据
const _fakeChats = [
  {
    'avatar': 'assets/default_avatar.png',
    'username': '小明',
    'lastMsg': '你好，今天有空吗？',
    'time': '上午10:00',
    'unread': 2,
  },
  {
    'avatar': 'assets/default_avatar.png',
    'username': '测试群聊',
    'lastMsg': '欢迎新成员加入本群！',
    'time': '昨天',
    'unread': 0,
  },
  {
    'avatar': 'assets/default_avatar.png',
    'username': '小红',
    'lastMsg': '[图片]',
    'time': '星期一',
    'unread': 1,
  },
  {
    'avatar': 'assets/default_avatar.png',
    'username': '张三',
    'lastMsg': '收到，谢谢！',
    'time': '上午9:30',
    'unread': 0,
  },
  {
    'avatar': 'assets/default_avatar.png',
    'username': '项目讨论组',
    'lastMsg': '下次会议时间定了吗？',
    'time': '星期天',
    'unread': 3,
  },
  {
    'avatar': 'assets/default_avatar.png',
    'username': '李老师',
    'lastMsg': '[语音]',
    'time': '上午8:15',
    'unread': 0,
  },
  {
    'avatar': 'assets/default_avatar.png',
    'username': '测试用户1',
    'lastMsg': '请查收附件。',
    'time': '昨天',
    'unread': 0,
  },
  {
    'avatar': 'assets/default_avatar.png',
    'username': '群聊A',
    'lastMsg': '大家好！',
    'time': '星期六',
    'unread': 0,
  },
  {
    'avatar': 'assets/default_avatar.png',
    'username': '小王',
    'lastMsg': '收到，马上处理。',
    'time': '上午7:50',
    'unread': 0,
  },
  {
    'avatar': 'assets/default_avatar.png',
    'username': '系统通知',
    'lastMsg': '您的验证码是123456。',
    'time': '刚刚',
    'unread': 1,
  },
];

// 微信仿真聊天弹窗组件
class WechatFakeChat extends StatelessWidget {
  final String username;
  final String avatar;
  const WechatFakeChat({required this.username, required this.avatar, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fakeMsgs = _wechatFakeMsgs[username] ?? [
      WechatMsg(isMe: false, type: 'text', content: '你好！'),
      WechatMsg(isMe: true, type: 'text', content: '你好，有什么事吗？'),
    ];
    return Container(
      width: 350,
      height: 520,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        image: const DecorationImage(
          image: AssetImage('assets/wechat_bg.png'), // 可自定义插画背景
          fit: BoxFit.cover,
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)],
      ),
      child: Column(
        children: [
          Container(
            height: 56,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              color: Colors.white70,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: fakeMsgs.length,
              itemBuilder: (context, idx) {
                final msg = fakeMsgs[idx];
                return WechatMsgBubble(
                  msg: msg,
                  avatar: avatar,
                );
              },
            ),
          ),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.mic, color: Colors.grey), onPressed: () {}),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text('仿微信输入框（仅展示）', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                IconButton(icon: const Icon(Icons.emoji_emotions, color: Colors.grey), onPressed: () {}),
                IconButton(icon: const Icon(Icons.add, color: Colors.grey), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WechatMsg {
  final bool isMe;
  final String type; // text, image, voice, time
  final String content; // 文本或图片路径
  final String? time;
  WechatMsg({required this.isMe, required this.type, required this.content, this.time});
}

class WechatMsgBubble extends StatelessWidget {
  final WechatMsg msg;
  final String avatar;
  const WechatMsgBubble({required this.msg, required this.avatar, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (msg.type == 'time') {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(msg.content, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ),
      );
    }
    final bubbleColor = msg.isMe ? const Color(0xFF95EC69) : Colors.white;
    final align = msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final rowAlign = msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
      bottomRight: Radius.circular(msg.isMe ? 4 : 16),
    );
    return Row(
      mainAxisAlignment: rowAlign,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!msg.isMe)
          Padding(
            padding: const EdgeInsets.only(right: 6, top: 2),
            child: CircleAvatar(
              backgroundImage: AssetImage(avatar),
              radius: 18,
            ),
          ),
        Flexible(
          child: Column(
            crossAxisAlignment: align,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: msg.type == 'text'
                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                    : const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: _buildMsgContent(msg),
              ),
              if (msg.time != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Text(msg.time!, style: const TextStyle(fontSize: 11, color: Colors.black38)),
                ),
            ],
          ),
        ),
        if (msg.isMe)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 2),
            child: CircleAvatar(
              backgroundImage: AssetImage(avatar),
              radius: 18,
            ),
          ),
      ],
    );
  }

  Widget _buildMsgContent(WechatMsg msg) {
    switch (msg.type) {
      case 'text':
        return Text(msg.content, style: const TextStyle(fontSize: 16));
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            msg.content,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      case 'voice':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, color: Colors.blue, size: 22),
            const SizedBox(width: 6),
            Text(msg.content, style: const TextStyle(fontSize: 15)),
          ],
        );
      case 'call':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.call, color: Colors.green, size: 22),
            const SizedBox(width: 6),
            Text(msg.content, style: const TextStyle(fontSize: 15)),
          ],
        );
      case 'like':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.thumb_up, color: Colors.green, size: 22),
            const SizedBox(width: 6),
            Text(msg.content, style: const TextStyle(fontSize: 15)),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}

// 仿微信假消息内容（不含用户真实内容）
final Map<String, List<WechatMsg>> _wechatFakeMsgs = {
  '小明': [
    WechatMsg(isMe: false, type: 'text', content: '你好，今天有空吗？', time: '晚上7:06'),
    WechatMsg(isMe: true, type: 'text', content: '不方便开', time: '晚上7:06'),
    WechatMsg(isMe: false, type: 'image', content: 'assets/wechat_img1.png'),
    WechatMsg(isMe: false, type: 'text', content: '非常的帅气'),
    WechatMsg(isMe: true, type: 'text', content: '这哪儿帅了', time: '晚上7:11'),
    WechatMsg(isMe: false, type: 'like', content: '👍'),
    WechatMsg(isMe: false, type: 'text', content: '咋不帅了'),
    WechatMsg(isMe: false, type: 'text', content: '我喜欢'),
  ],
  '测试群聊': [
    WechatMsg(isMe: false, type: 'text', content: '欢迎新成员加入本群！'),
    WechatMsg(isMe: false, type: 'text', content: '大家好！'),
    WechatMsg(isMe: true, type: 'text', content: '大家好，我是新来的'),
    WechatMsg(isMe: false, type: 'image', content: 'assets/wechat_img2.png'),
  ],
  '小红': [
    WechatMsg(isMe: false, type: 'image', content: 'assets/wechat_img3.png'),
    WechatMsg(isMe: true, type: 'text', content: '图片不错'),
  ],
  '张三': [
    WechatMsg(isMe: true, type: 'text', content: '收到，谢谢！'),
    WechatMsg(isMe: false, type: 'voice', content: '00:12'),
  ],
  '项目讨论组': [
    WechatMsg(isMe: false, type: 'text', content: '下次会议时间定了吗？'),
    WechatMsg(isMe: true, type: 'text', content: '还没，等通知'),
  ],
  '李老师': [
    WechatMsg(isMe: false, type: 'voice', content: '00:46'),
    WechatMsg(isMe: false, type: 'text', content: '请查收作业'),
    WechatMsg(isMe: true, type: 'text', content: '收到'),
  ],
  '测试用户1': [
    WechatMsg(isMe: false, type: 'text', content: '请查收附件。'),
    WechatMsg(isMe: true, type: 'text', content: '收到'),
  ],
  '群聊A': [
    WechatMsg(isMe: false, type: 'text', content: '大家好！'),
    WechatMsg(isMe: true, type: 'text', content: '大家好'),
  ],
  '小王': [
    WechatMsg(isMe: true, type: 'text', content: '收到，马上处理。'),
  ],
  '系统通知': [
    WechatMsg(isMe: false, type: 'text', content: '您的验证码是123456。'),
  ],
}; 