import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import '../main_controller.dart';
import 'api.dart';
import 'user.dart';

class Auth {
  static Future createAccount({required String email, required String password}) async {
    MainController c = Get.find<MainController>();

    final QueryResult result = await c.client.mutate(
      MutationOptions(
        variables: {'email': email, 'password': password},
        document: gql(r'''
        mutation createEmailAccount($email: String!, $password: String!) {
          createEmailAccount(email: $email, password: $password)
        }
      '''),
      ),
    );

    if (result.exception != null) {
      var res = ApiResponse.handleError(error: result.exception!);
      if (Get.isSnackbarOpen == true) return;

      Get.snackbar(
        'خطأ',
        res.data,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        maxWidth: 300,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'تم إنشاء الحساب بنجاح',
      'الرجاء إدخال الكود المرسل للإيميل لتفعيل حسابك',
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      maxWidth: 300,
      colorText: Colors.white,
    );

    Get.toNamed('/verify-email', arguments: email);
  }

  static Future sendVerificationEmail({required String email}) async {
    MainController c = Get.find<MainController>();
    final QueryResult result = await c.client.query(
      QueryOptions(
        variables: {'email': email},
        document: gql(r'''
        query sendVerificationEmail($email: String!) {
          sendVerificationEmail(email: $email)
        }
      '''),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.exception != null) {
      var res = ApiResponse.handleError(error: result.exception!);
      if (Get.isSnackbarOpen == true) return;

      Get.snackbar(
        'خطأ',
        res.data,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        maxWidth: 300,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'تم إرسال البريد',
      'تم إرسال كود التفعيل بنجاح',
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      maxWidth: 300,
      colorText: Colors.white,
    );
  }

  static Future sendRestoreEmail({required String email}) async {
    MainController c = Get.find<MainController>();
    final QueryResult result = await c.client.query(
      QueryOptions(
        variables: {'email': email},
        document: gql(r'''
        query restorePassword($email: String!) {
          restorePassword(email: $email)
        }
      '''),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.exception != null) {
      var res = ApiResponse.handleError(error: result.exception!);
      if (Get.isSnackbarOpen == true) return 0;

      Get.snackbar(
        'خطأ',
        res.data,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        maxWidth: 300,
        colorText: Colors.white,
      );
      return 0;
    }

    Get.snackbar(
      'تم إرسال البريد',
      'تم إرسال كود استعادة كلمة المرور بنجاح',
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      maxWidth: 300,
      colorText: Colors.white,
    );
  }

  static Future restorePassword({required String email, required String password, required int code}) async {
    MainController c = Get.find<MainController>();

    final QueryResult result = await c.client.mutate(
      MutationOptions(
        variables: {'email': email, 'password': password, 'code': code},
        document: gql(r'''
        mutation verifyPasswordCode($email: String!, $password: String!, $code: Int!) {
          verifyPasswordCode(email: $email, password: $password, code: $code)
        }
      '''),
      ),
    );

    if (result.exception != null) {
      var res = ApiResponse.handleError(error: result.exception!);
      if (Get.isSnackbarOpen == true) return 0;

      Get.snackbar(
        'خطأ',
        res.data,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        maxWidth: 300,
        colorText: Colors.white,
      );
      return 0;
    }

    Get.snackbar(
      'تم التعديل بنجاح',
      'تم تعديل كلمة المرور بنجاح',
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      maxWidth: 300,
      colorText: Colors.white,
    );
  }

  static Future verifyEmail({required String email, required int code}) async {
    MainController c = Get.find<MainController>();

    final QueryResult result = await c.client.mutate(
      MutationOptions(
        variables: {'email': email, 'code': code},
        document: gql(r'''
        mutation verifyEmail($email: String!, $code: Int!) {
          verifyEmail(email: $email, code: $code)
        }
      '''),
      ),
    );

    if (result.exception != null) {
      var res = ApiResponse.handleError(error: result.exception!);
      if (Get.isSnackbarOpen == true) return 0;

      Get.snackbar(
        'خطأ',
        res.data,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        maxWidth: 300,
        colorText: Colors.white,
      );
      return 0;
    }

    Get.snackbar(
      'تم تفعيل حسابك بنجاح',
      'يمكنك تسجيل دخولك الآن',
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      maxWidth: 300,
      colorText: Colors.white,
    );

    Get.toNamed('/login', arguments: email);
  }

  static Future<void> emailLogin({required String email, required String password}) async {
    MainController c = Get.find<MainController>();

    final QueryResult result = await c.client.query(
      QueryOptions(
        variables: {'email': email, 'password': password},
        document: gql(r'''
        query emailLogin($email: String!, $password: String!) {
          emailLogin(email: $email, password: $password) {
            id
            userName
            loginType
            loginInfo
            country
            time
            balance
            shares
            trustPoint
            balanceToBuyShare
            distributePercent
            jwtToken
          }
        }
        '''),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.exception != null) {
      var res = ApiResponse.handleError(error: result.exception!);
      if (Get.isSnackbarOpen == true) return;
      if (result.exception!.graphqlErrors.isEmpty) return;
      if (result.exception!.graphqlErrors.first.message == 'UNVERIFIED_EMAIL') {
        Get.toNamed('/verify-email', arguments: email);
      }

      Get.snackbar(
        'خطأ',
        res.data,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        maxWidth: 300,
        colorText: Colors.white,
      );
      return;
    }

    c.user.value.updateData(data: result.data!['emailLogin']);
    if (c.user.value.userName.isEmpty) {
      Get.toNamed('/login_data', arguments: email);
      return;
    }
    Get.toNamed('/account');
  }

  static void socialLogin({required String type}) {
    String platform = '';

    if (GetPlatform.isWeb) {
      platform = 'web'; // make it last one becuse browser in windoes mean desktop + web
    } else if (GetPlatform.isDesktop) {
      platform = 'desktop';
    } else {
      platform = 'android';
    }

    if (type == 'google') {
      GoogleAuth auth = GoogleAuth();
      if (platform == 'web') {
        auth.getWebToken();
      } else if (platform == 'android') {
        auth.getMobileToken();
      } else {
        auth.getDesktopToken();
      }
    }
  }

  Future<void> getUserData({
    required String redirect,
    required String platform,
    required String provider,
    required String code,
    String alreadyHasId = '',
  }) async {
    MainController c = Get.find<MainController>();
    var result = await c.client.query(
      QueryOptions(
        document: gql(r'''query Signin($redirectUri: String!, $loginType: String!, $platform: String!, $code: String!, $alreadyHasId: String!) {
          signin(redirectUri: $redirectUri, loginType: $loginType, platform: $platform, code: $code, alreadyHasId: $alreadyHasId) {
            id
            userName
            loginType
            loginInfo
            country
            time
            balance
            shares
            trustPoint
            balanceToBuyShare
            distributePercent
            jwtToken
          }
        }
      '''),
        variables: {
          "redirectUri": redirect,
          "loginType": provider,
          "platform": platform,
          "code": code,
          "alreadyHasId": alreadyHasId,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.data == null) return;

    // step 7: save user data
    c.user.value.updateData(data: result.data!['signin']);
    if (c.user.value.userName.isEmpty) {
      Get.toNamed('/login_data');
      return;
    }
    Get.toNamed('/account');
  }

  static void logOut() {
    var c = Get.find<MainController>();
    var newUser = User();
    c.user.value = newUser;
    c.user.value.save();
    c.user.refresh();
    Get.toNamed('/login');
  }
}

class GoogleAuth extends Auth {
  static String webClient = '1039087411910-kvkrgh0os6d8h8rq7v7anf2uv14kfi2m.apps.googleusercontent.com';
  static String androidClient = '1039087411910-8c7v2ro745qg6i8d4femcssvhqecqrnd.apps.googleusercontent.com';
  static String desktopClient = '1039087411910-4qr13dtntnb3ivqddo7pmhdaq4p1puo0.apps.googleusercontent.com';

  void getWebToken() {
    String redirect = '${html.window.location.origin}/login_redirect_google';

    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': webClient,
      'redirect_uri': redirect,
      'response_type': 'code',
      'scope': 'openid',
      'include_granted_scopes': 'true',
      'state': 'pass-through value'
    });

    html.window.location.href = authUrl.toString();
  }

  void getDesktopToken() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final redirect = 'http://${server.address.address}:${server.port}';

    // Step 2: Construct the authorization URL
    Uri authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'code',
      'client_id': '1039087411910-4qr13dtntnb3ivqddo7pmhdaq4p1puo0.apps.googleusercontent.com',
      'redirect_uri': redirect,
      'scope': 'email',
      'access_type': 'offline',
      'prompt': 'consent',
    });

    // Step 3: Open the authorization URL in the default browser
    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } else {
      return;
    }

    // step 4: get the auth code
    final request = await server.first;
    final params = request.uri.queryParameters;
    final authCode = params['code'];
    final error = params['error'];

    if (error != null || authCode == null) return;

    // step 5: show result to user
    request.response.statusCode = 200;
    request.response.headers.set('Content-Type', 'text/html; charset=utf-8');
    request.response.write('''
      <!DOCTYPE html>
      <html lang="ar" dir="rtl">
      <head>
      <meta charset="UTF-8">
      <title>تسجيل الدخول ناجح</title>
      <style>
      body {
          background-color: #01091D;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          margin: 0;
          font-family: Arial, sans-serif;
      }
      .message {
          color: #FFFFFF;
          text-align: center;
      }
      .message h1 {
          font-size: 2em;
          margin-bottom: 0.5em;
      }
      .message p {
          font-size: 1.2em;
      }
      </style>
      </head>
      <body>
      <div class="message">
          <h1>تسجيل الدخول ناجح</h1>
          <p>يمكنك الآن إغلاق هذه النافذة والعودة إلى التطبيق.</p>
      </div>
      </body>
      </html>
    ''');

    // step 6: close server
    await request.response.close();
    await server.close(force: true);

    await super.getUserData(redirect: redirect, platform: 'desktop', provider: 'google', code: authCode);
  }

  void getMobileToken() async {
    var user = GoogleSignIn.instance;
    user.attemptLightweightAuthentication();
    GoogleSignInAccount? account = await user.attemptLightweightAuthentication();

    if (account == null) return;

    await super.getUserData(
      redirect: '',
      platform: 'mobile',
      provider: 'google',
      code: '',
      alreadyHasId: account.id,
    );
  }
}
