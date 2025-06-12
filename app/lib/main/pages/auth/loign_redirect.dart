import 'package:ailence/main/model/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_background.dart';
import 'package:universal_html/html.dart' as html;
import '../../utils/app_vars.dart';

class LoginRedirect extends StatelessWidget {
  final String provider;
  const LoginRedirect({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (Get.parameters['code'] != null) {
      Auth().getUserData(
        provider: provider,
        platform: 'web',
        redirect: '${html.window.location.origin}${Get.currentRoute.split('?')[0]}',
        code: Get.parameters['code']!,
      );
    }

    return LoginBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: componentBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                spacing: 10,
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  Flexible(
                      child: Text(
                    'يتم الآن جلب المعلومات، الرجاء الانتظار للحظات',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
