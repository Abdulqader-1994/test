import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_background.dart';
import '../../model/api.dart';
import '../../model/user.dart';
import '../../main_controller.dart';

class LoginData extends StatefulWidget {
  const LoginData({super.key});

  @override
  State<LoginData> createState() => _LoginDataState();
}

class _LoginDataState extends State<LoginData> {
  String name = '';
  bool wait = false;
  final deepBlue = const Color(0xFF062D67);
  ApiResponse? res;
  var c = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      child: Center(
        child: Column(
          spacing: 10,
          children: [
            const Text('اختر اسم مستخدم خاص بك', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                onChanged: (val) => setState(() {
                  name = val;
                  res = null;
                }),
                validator: (value) {
                  value = value?.trim();
                  if (value == null || value.isEmpty) return 'الرجاء إدخال اسم المستخدم';

                  if (value.length < 5) return 'يجب ألا يقل الاسم عن 5 أحرف';

                  final chars = RegExp(r'^[A-Za-z0-9_-]+$'); // Allowed Characters: only letters, numbers, underscores(_), and hyphens(-).
                  if (!chars.hasMatch(value)) return 'رمز غير مسموح، المسموح: (أحرف وأرقام و _ و -)';

                  final startsWithLetter = RegExp(r'^[A-Za-z]'); // Starting Character: must begin with a letter.
                  if (!startsWithLetter.hasMatch(value)) return 'يجب أن يبدأ اسم المستخدم بحرف';

                  const reservedWords = ['admin', 'root', 'system', 'test', 'ailence']; // Reserved and Inappropriate Words
                  if (reservedWords.contains(value.toLowerCase())) return 'اسم المستخدم يحتوي على كلمات محجوزة';
                  return null;
                },
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: DropdownButton<int>(
                padding: const EdgeInsets.only(bottom: 10),
                value: 1,
                onChanged: null,
                isExpanded: true,
                items: const [DropdownMenuItem(value: 1, child: Text("سوريا"))],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    setState(() {
                      wait = true;
                      res = null;
                    });

                    ApiResponse data = await User.updateUserName(newValue: name);

                    setState(() {
                      wait = false;
                      res = data;
                    });
                    if (data.success) {
                      c.user.value.userName = name;
                      c.user.value.save();
                      c.user.refresh();
                      Get.toNamed('/account');
                    }
                  },
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFF062D67), fixedSize: const Size(100, 34)),
                  label: wait
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('موافق', style: TextStyle(color: Colors.white)),
                  icon: wait ? null : const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
