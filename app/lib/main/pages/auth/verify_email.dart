import 'package:ailence/main/model/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'login_background.dart';
import '../../utils/app_vars.dart';
import '../../utils/btn_style.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final int codeLength = 6;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading1 = false;
  bool _isLoading2 = false;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(codeLength, (_) => TextEditingController());
    focusNodes = List.generate(codeLength, (_) => FocusNode());

    Auth.sendVerificationEmail(email: Get.arguments);
  }

  @override
  void dispose() {
    for (final ctrl in controllers) {
      ctrl.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void verifyCode() async {
    String code = controllers.map((controller) => controller.text).join();
    if (code.length != codeLength) return;

    setState(() => _isLoading1 = true);
    var res = await Auth.verifyEmail(email: Get.arguments, code: int.parse(code));
    if (res == 0) {
      for (var c in controllers) {
        c.text = '';
      }
    }
    setState(() => _isLoading1 = false);
  }

  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 15,
          children: [
            const Text(
              'الرجاء إضافة الكود المرسل للإيميل',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(codeLength, (index) {
                  return SizedBox(
                    width: 25,
                    height: 40,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      textInputAction: index < codeLength - 1 ? TextInputAction.next : TextInputAction.done,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        counterText: '',
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < codeLength - 1) {
                          FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                          controllers[index + 1].selection = TextSelection(baseOffset: 0, extentOffset: controllers[index + 1].text.length);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                          controllers[index - 1].selection = TextSelection(baseOffset: 0, extentOffset: controllers[index - 1].text.length);
                        }
                      },
                      onTap: () {
                        if (controllers[index].text.isNotEmpty) {
                          controllers[index].selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: controllers[index].text.length,
                          );
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
            ElevatedButton(
              style: deepBlueBtnStyle,
              onPressed: verifyCode,
              child: _isLoading1
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: background, strokeWidth: 2.0))
                  : const Text('تفعيل الحساب', style: TextStyle(color: Colors.white)),
            ),
            const Divider(),
            TextButton(
              onPressed: () async {
                setState(() => _isLoading2 = true);
                await Auth.sendVerificationEmail(email: Get.arguments);
                setState(() => _isLoading2 = false);
              },
              child: _isLoading2
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: background, strokeWidth: 2.0))
                  : const Text('لم يصلك كود التفعيل ؟ إعد الإرسال الآن'),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/login'),
              child: const Text('العودة إلى تسجيل الدخول'),
            ),
            const Divider(),
            const Text(
              'ملاحظة: إذا لم تجد إيميل كود التفعيل في صندوق الوارد الخاص بك، يرجى التحقق من صندوق الرسائل غير المرغوب فيها (spam).',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
