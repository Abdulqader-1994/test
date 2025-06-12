import 'package:ailence/main/model/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'login_background.dart';
import '../../utils/app_vars.dart';
import '../../utils/btn_style.dart';

class VerifyPassword extends StatefulWidget {
  const VerifyPassword({super.key});

  @override
  State<VerifyPassword> createState() => _VerifyPasswordState();
}

class _VerifyPasswordState extends State<VerifyPassword> {
  String password = '';
  String confirm = '';
  int? code = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading1 = false;
  bool _isLoading2 = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 15,
            children: [
              const Text(
                'تعديل كلمة السر',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                onChanged: (val) => setState(() => password = val),
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  value = value?.trim();
                  if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
                  if (value.length < 7) return 'يجب ألا يقل طول الكلمة عن سبع أحرف';
                  return null;
                },
              ),
              TextFormField(
                obscureText: _obscurePassword,
                onChanged: (val) => setState(() => confirm = val),
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  value = value?.trim();
                  if (value == null || value.isEmpty) return 'الرجاء تأكيد كلمة المرور';
                  if (password != confirm) return 'كلمة المرور غير متطابقة';
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Code'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (val) => setState(() => code = int.tryParse(val)),
                validator: (value) {
                  value = value?.trim();
                  if (value == null || value.isEmpty) return 'الرجاء إدخال الكود المرسل للإيميل';
                  if (value.length != 6) return 'يجب أن يكون الكود مؤلف من ستة أرقام';
                  return null;
                },
              ),
              ElevatedButton(
                style: deepBlueBtnStyle,
                onPressed: () async {
                  setState(() => _isLoading1 = true);
                  var res = await Auth.restorePassword(email: Get.arguments, password: password, code: code!);
                  setState(() => _isLoading1 = false);
                  if (res != 0) Get.toNamed('/login');
                },
                child: _isLoading1
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: background, strokeWidth: 2.0))
                    : const Text('موافق', style: TextStyle(color: Colors.white)),
              ),
              const Divider(),
              TextButton(
                onPressed: () async {
                  setState(() => _isLoading2 = true);
                  await Auth.sendRestoreEmail(email: Get.arguments);
                  setState(() => _isLoading2 = false);
                },
                child: _isLoading2
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: background, strokeWidth: 2.0))
                    : const Text('لم يصلك كود التأكيد ؟ إعد الإرسال الآن'),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/login'),
                child: const Text('العودة إلى تسجيل الدخول'),
              ),
              const Divider(),
              const Text(
                'ملاحظة: إذا لم تجد إيميل كود التأكيد في صندوق الوارد الخاص بك، يرجى التحقق من صندوق الرسائل غير المرغوب فيها (spam).',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
