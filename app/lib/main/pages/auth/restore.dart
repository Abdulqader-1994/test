import 'package:ailence/main/pages/auth/login_background.dart';
import 'package:ailence/main/model/auth.dart';
import 'package:ailence/main/utils/btn_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestorePassword extends StatefulWidget {
  const RestorePassword({super.key});

  @override
  State<RestorePassword> createState() => _RestorePasswordState();
}

class _RestorePasswordState extends State<RestorePassword> {
  bool _isLoading = false;
  String email = '';

  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      child: Column(
        spacing: 10,
        children: [
          const Text(
            'تأكيد الإيميل',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextFormField(
              onChanged: (val) => setState(() => email = val),
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
                value = value?.trim();
                final emailRegex = RegExp(r"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*");
                if (value == null || value.isEmpty || !emailRegex.hasMatch(value)) return 'الرجاء إدخال الإيميل بشكل صحيح';
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                var res = await Auth.sendRestoreEmail(email: email);
                setState(() => _isLoading = false);

                if (res != 0) Get.toNamed('/verify-password', arguments: email);
              },
              style: deepBlueBtnStyle,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                  : const Text('موافق', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
