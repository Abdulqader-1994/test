import 'package:ailence/main/utils/app_vars.dart';
import 'package:ailence/main/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/btn_style.dart';

class MainWidget extends StatelessWidget {
  final Widget page;
  const MainWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    ScrollController scroll = ScrollController();

    return SafeArea(
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TopBar(),
        ),
        drawer: context.width <= drawerSideBreakPoint
            ? const Drawer(
                width: 220,
                backgroundColor: background,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: AppDrawer(),
                ),
              )
            : null,
        backgroundColor: fullBackground,
        body: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            constraints: const BoxConstraints(maxWidth: appWidth),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (context.width > drawerSideBreakPoint) const AppDrawer(),
                Expanded(
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(background),
                      trackColor: WidgetStateProperty.all(componentBackground),
                      trackVisibility: WidgetStateProperty.all(true),
                    ),
                    child: Scrollbar(
                      controller: scroll,
                      thumbVisibility: true,
                      thickness: 7.0,
                      radius: const Radius.circular(4.0),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 20, right: 10),
                        controller: scroll,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: appWidth),
                          child: page,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        elevation: 3,
        shadowColor: background.withValues(alpha: 0.7),
        backgroundColor: background,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: context.width <= drawerSideBreakPoint
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  var c = Get.find<MainController>();
                  c.drawerExpanded = true;
                  Scaffold.of(context).openDrawer();
                },
              )
            : null,
        flexibleSpace: Center(
          child: Container(
            padding: EdgeInsets.only(right: context.width <= drawerSideBreakPoint ? 40 : 0),
            constraints: const BoxConstraints(maxWidth: appWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ailence',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isExpanded = true;
  ScrollController scroll = ScrollController();
  var c = Get.find<MainController>();

  @override
  void initState() {
    super.initState();
    isExpanded = c.drawerExpanded;
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(background),
          trackColor: WidgetStateProperty.all(componentBackground),
          trackVisibility: WidgetStateProperty.all(true),
        ),
        child: Scrollbar(
          controller: scroll,
          thumbVisibility: true,
          thickness: 7.0,
          radius: const Radius.circular(4.0),
          child: SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.only(right: 13),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isExpanded ? 200 : 66,
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', width: 50, height: 50),
                      const Text('Ailence', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: fullBackground,
                  ),
                  DrawerButton(
                    icon: Icons.auto_stories,
                    text: 'منصـة الدراسـة',
                    name: 'study',
                    func: () async => await Get.toNamed('/study'),
                  ),
                  DrawerButton(
                    icon: Icons.engineering,
                    text: 'مـنـصـة الـعـمـل',
                    name: 'work',
                    func: () async => await Get.toNamed('/work'),
                  ),
                  /*  DrawerButton(
                    icon: Icons.groups,
                    text: 'منصة التواصـل',
                    name: 'social',
                    func: () async => await Get.toNamed('/social'),
                  ),
                  DrawerButton(
                    icon: Icons.sports_esports,
                    text: 'منصـة الألـعـاب',
                    name: 'games',
                    func: () async => await Get.toNamed('/games'),
                  ), */
                  Container(
                    width: double.infinity,
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: fullBackground,
                  ),
                  DrawerButton(
                    icon: Icons.add_shopping_cart,
                    text: 'الـــــمـــــتـــــجـــــر',
                    name: 'store',
                    func: () async => await Get.toNamed('/store'),
                  ),
                  DrawerButton(
                    icon: Icons.account_circle,
                    text: 'الحساب الشخصي',
                    name: 'account',
                    func: () async => await Get.toNamed('/account'),
                  ),
                  DrawerButton(
                    icon: Icons.contact_support,
                    text: 'الأسئلة الشائعة',
                    name: 'faq',
                    func: () async => await Get.toNamed('/faq'),
                  ),
                  Container(
                    width: double.infinity,
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: fullBackground,
                  ),
                  IconButton(
                    onPressed: () {
                      if (context.width <= drawerSideBreakPoint) {
                        Scaffold.of(context).closeDrawer();
                      } else {
                        setState(() => isExpanded = !isExpanded);
                        c.drawerExpanded = isExpanded;
                      }
                    },
                    style: drawerBtnStyle(),
                    icon: Icon(
                      isExpanded ? Icons.keyboard_double_arrow_right : Icons.keyboard_double_arrow_left,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function func;
  final String name;
  const DrawerButton({super.key, required this.icon, required this.text, required this.func, required this.name});

  @override
  Widget build(BuildContext context) {
    final String currentPageRoute = ModalRoute.of(context)?.settings.name ?? '';
    final String routeSegment = currentPageRoute.split('/').where((e) => e.isNotEmpty).firstOrNull ?? '';

    return Container(
      width: 200,
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () => func(),
        style: drawerBtnStyle(isActive: routeSegment == name),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            Expanded(
              child: Text(
                text,
                softWrap: false,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
