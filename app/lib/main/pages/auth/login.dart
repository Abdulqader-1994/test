import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'login_background.dart';
import '../../model/auth.dart';
import '../../utils/app_vars.dart';
import '../../utils/btn_style.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(tabs: [Tab(text: 'تسجيل دخول'), Tab(text: 'إنشاء حساب')]),
            SizedBox(height: 280, child: TabBarView(children: [SignInForm(), SignUpForm()])),
            SocialLogin(),
          ],
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn(GraphQLClient client) async {
    if (!_formKey.currentState!.validate()) return;
    String email = _emailController.text;
    String password = _passwordController.text;

    setState(() => _isLoading = true);
    await Auth.emailLogin(email: email, password: password);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
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
              TextFormField(
                controller: _passwordController,
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
                  if (value == null || value.isEmpty || value.length < 7) return 'يجب ألا يقل طول الكلمة عن سبع أحرف';
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () => _signIn(client),
                  style: deepBlueBtnStyle,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                      : const Text('تسجيل الدخول', style: TextStyle(color: Colors.white)),
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () => Get.toNamed('/restore-password'),
                child: Text('نسيت كلمة السر ؟'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp(GraphQLClient client) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    await Auth.createAccount(email: email, password: password);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
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
              TextFormField(
                controller: _passwordController,
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
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
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
                  if (value != _passwordController.text) return 'كلمة المرور غير متطابقة';
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () => _signUp(client),
                  style: deepBlueBtnStyle,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                      : const Text('إنشاء حساب', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        const Divider(),
        Text('أو سجل دخولك عبر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Auth.socialLogin(type: 'google'),
              icon: const FaIcon(FontAwesomeIcons.google, color: componentBackground, size: 25),
            ),
            IconButton(
              onPressed: () {},
              icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: 40),
            ),
            IconButton(
              onPressed: () {},
              style: TextButton.styleFrom(backgroundColor: const Color(0xFF737373)),
              icon: const FaIcon(FontAwesomeIcons.apple, color: componentBackground, size: 25),
            ),
          ],
        ),
      ],
    );
  }
}
