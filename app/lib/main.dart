import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'main/pages/auth/restore.dart';
import 'main/pages/auth/verify_password.dart';
import 'main/main_controller.dart';
import 'main/pages/work/entidio/controller.dart';
import 'main/pages/work/entidio/model/lesson.dart';
import 'main/pages/work/entidio/model/map.dart';
import 'main/pages/work/entidio/model/part.dart';
import 'main/pages/work/entidio/view.dart';
import 'main/pages/account.dart';
import 'main/pages/auth/verify_email.dart';
import 'main/pages/faq.dart';
import 'main/pages/games.dart';
import 'main/pages/auth/login_data.dart';
import 'main/pages/work/index.dart';
import 'main/pages/social.dart';
import 'main/pages/study.dart';
import 'main/pages/work/task.dart';
import 'main/pages/store.dart' as s;
import 'main/pages/auth/login.dart';
import 'main/pages/auth/loign_redirect.dart';
import 'main/pages/work/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  setPathUrlStrategy(); // to remove # from url

  final c = Get.put(MainController());
  await c.checkUserData();

  Part p = Part(parentId: '0');
  LessonMap m = LessonMap(id: p.id, trColor: p.trColor, children: []);
  Lesson l = Lesson(content: [p], map: m);

  Get.put(EntidioController(lesson: l));

  final ValueNotifier<GraphQLClient> client = ValueNotifier(c.client);

  runApp(GraphQLProvider(client: client, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ailence',
      textDirection: TextDirection.rtl,
      debugShowCheckedModeBanner: false,
      initialRoute: '/account',
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 750),
      builder: (context, child) => SafeArea(child: child!),
      getPages: [
        // protected routes
        GetPage(name: '/study', page: () => const Study(), middlewares: [ProtectedRoute()]),
        GetPage(name: '/work', page: () => const Work(), middlewares: [ProtectedRoute()]),
        GetPage(name: '/social', page: () => const Social(), middlewares: [ProtectedRoute()]),
        GetPage(name: '/games', page: () => const Games(), middlewares: [ProtectedRoute()]),
        GetPage(name: '/store', page: () => const s.Store(), middlewares: [ProtectedRoute()]),
        GetPage(name: '/account', page: () => const Account(), middlewares: [ProtectedRoute()]),
        GetPage(name: '/faq', page: () => const FAQ(), middlewares: [ProtectedRoute()]),

        // deep protected routes
        GetPage(name: '/work/materials', page: () => const Materials(), middlewares: [ProtectedRoute()]),
        GetPage(name: '/work/materials/:material', page: () => const Tasks(), middlewares: [ProtectedRoute()]),
        GetPage(name: '/work/entidio', page: () => const Entidio(), middlewares: [ProtectedRoute()]),

        // unProteced routes
        GetPage(name: '/login', page: () => const Login(), middlewares: [UnProtectedRoute()]),
        GetPage(name: '/restore-password', page: () => const RestorePassword(), middlewares: [UnProtectedRoute()]),
        GetPage(name: '/verify-password', page: () => const VerifyPassword(), middlewares: [UnProtectedRoute()]),
        GetPage(name: '/verify-email', page: () => const VerifyEmail(), middlewares: [UnProtectedRoute()]),
        GetPage(name: '/login_data', page: () => const LoginData(), middlewares: [CompleteDataRoute()]),
        GetPage(
          name: '/login_redirect_google',
          page: () => const LoginRedirect(provider: 'google'),
          middlewares: [UnProtectedRoute()],
        ),
      ],
      onUnknownRoute: (s) => GetPageRoute(settings: s, page: () => const Account()),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'El Messiri',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        textTheme: const TextTheme(displayMedium: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class ProtectedRoute extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    final c = Get.find<MainController>();
    if (c.user.value.jwtToken.isEmpty) return const RouteSettings(name: '/login');
    if (c.user.value.userName.isEmpty) return const RouteSettings(name: '/login_data');
    return null; // Allow navigation
  }
}

class UnProtectedRoute extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    final c = Get.find<MainController>();
    if (c.user.value.jwtToken.isNotEmpty) return const RouteSettings(name: '/account');
    return null; // Allow navigation
  }
}

class CompleteDataRoute extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    final c = Get.find<MainController>();
    if (c.user.value.jwtToken.isEmpty) return const RouteSettings(name: '/login');
    if (c.user.value.userName.isNotEmpty) return const RouteSettings(name: '/account');
    return null; // Allow navigation
  }
}
