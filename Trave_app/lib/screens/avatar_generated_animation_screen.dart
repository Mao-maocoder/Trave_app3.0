import 'package:flutter/material.dart';
import '../constants.dart';

class AvatarGeneratedAnimationScreen extends StatefulWidget {
  final String avatarPath;
  const AvatarGeneratedAnimationScreen({Key? key, required this.avatarPath}) : super(key: key);

  @override
  State<AvatarGeneratedAnimationScreen> createState() => _AvatarGeneratedAnimationScreenState();
}

class _AvatarGeneratedAnimationScreenState extends State<AvatarGeneratedAnimationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('形象生成', style: TextStyle(fontFamily: kFontFamilyTitle)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '根据调查问卷的选择内容为您生成的个人形象',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: kFontFamilyTitle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Hero(
              tag: 'user-avatar',
              child: ScaleTransition(
                scale: _scale,
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage(widget.avatarPath),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('确认', style: TextStyle(fontFamily: kFontFamilyTitle)),
            ),
          ],
        ),
      ),
    );
  }
} 