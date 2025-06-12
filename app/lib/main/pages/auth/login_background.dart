import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_vars.dart';

class LoginBackground extends StatefulWidget {
  final Widget child;
  const LoginBackground({super.key, required this.child});

  @override
  State<LoginBackground> createState() => _LoginBackgroundState();
}

class _LoginBackgroundState extends State<LoginBackground> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color?> gradientStart;
  late Animation<Color?> gradientEnd;
  late Animation<Alignment> gradientBegin;
  late Animation<Alignment> gradientFinish;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();

    const deepBlue = Color(0xFF062D67);
    const deepPink = Color(0xFF67083A);

    gradientStart = ColorTween(begin: deepBlue, end: deepPink).animate(controller);
    gradientEnd = ColorTween(begin: deepPink, end: deepBlue).animate(controller);

    gradientBegin = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1.0),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1.0),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1.0),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1.0),
    ]).animate(controller);

    gradientFinish = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1.0),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1.0),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1.0),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1.0),
    ]).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: gradientBegin.value,
                end: gradientFinish.value,
                colors: [gradientStart.value!, gradientEnd.value!],
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 280,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                decoration: BoxDecoration(
                  color: componentBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: widget.child,
              ),
              Container(
                width: 280,
                padding: const EdgeInsets.only(top: 20, bottom: 5),
                child: const Text(
                  'تسجيل دخولك للمنصة يعني موافقتك على جميع الأحكام والشروط',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: componentBackground),
                ),
              ),
              Row(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      var authUrl = Uri.https('ailence.com', '/terms');
                      if (await canLaunchUrl(authUrl)) await launchUrl(authUrl, mode: LaunchMode.externalApplication);
                    },
                    child: const Text(
                      'سياسة الاستخدام',
                      style: TextStyle(
                        fontSize: 11,
                        color: componentBackground,
                        decoration: TextDecoration.underline,
                        decorationColor: componentBackground,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      var authUrl = Uri.https('ailence.com', '/privacy');
                      if (await canLaunchUrl(authUrl)) await launchUrl(authUrl, mode: LaunchMode.externalApplication);
                    },
                    child: const Text(
                      'بيان الخصوصية',
                      style: TextStyle(
                        fontSize: 11,
                        color: componentBackground,
                        decoration: TextDecoration.underline,
                        decorationColor: componentBackground,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
