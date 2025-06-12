import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../component/main_widget.dart';
import '../../component/page_header.dart';
import '../../main_controller.dart';
import '../../utils/app_vars.dart';
import 'balance.dart';
import 'trade.dart';
import 'work.dart';

class Work extends StatelessWidget {
  const Work({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MainController>();
    return MainWidget(
      page: Obx(() {
        bool connecting = c.trade.value.isConnecting;

        return Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: 'منصة العمل', desc: 'منصة لإدارة الأرباح والعمل لكسب الأسهم وتداولها ', icon: Icons.engineering),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  TabButton(tabIndex: 3, clipper: Leftpath(), label: 'التداول', roundedTopLeft: true, roundedBottomLeft: true),
                  TabButton(tabIndex: 2, clipper: Bothpath(), label: 'العمل', roundedTopLeft: false, roundedBottomLeft: false),
                  TabButton(tabIndex: 1, clipper: Rightpath(), label: 'الرصيد', roundedTopRight: true, roundedBottomRight: true),
                ],
              ),
            ),

            // balance page
            if (c.profitTab.value == 1)
              Flex(
                spacing: 20,
                direction: context.width > 500 ? Axis.horizontal : Axis.vertical,
                children: const [AccountBalance(startExpandNum: 500), Statistics(stopExpandNum: 500)],
              ),
            if (c.profitTab.value == 1)
              Flex(
                spacing: 20,
                direction: context.width > 500 ? Axis.horizontal : Axis.vertical,
                children: const [DistributeProfit(stopExpandNum: 500), NowHourBalance(startExpandNum: 500)],
              ),
            if (c.profitTab.value == 1) DistributedMoney(breakPoint: 300),
            if (c.profitTab.value == 1) DistributedShares(breakPoint: 300),

            // work page
            if (c.profitTab.value == 2)
              Flex(
                spacing: 20,
                direction: context.width > 500 ? Axis.horizontal : Axis.vertical,
                children: const [StartWork(startExpandNum: 500), AccountWorkInfo(stopExpandNum: 500)],
              ),
            if (c.profitTab.value == 2) const LastAddedWork(),

            // trade page
            if (c.profitTab.value == 3)
              Stack(
                children: [
                  if (connecting) Center(child: Text('connecting ...')),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      PriceChart(),
                      Flex(
                          spacing: 20,
                          direction: context.width > 500 ? Axis.horizontal : Axis.vertical,
                          children: [OrderBook(stopExpandNum: 500), PlaceNewOrder(stopExpandNum: 500)]),
                      HistoryOrders()
                    ],
                  ),
                ],
              )
          ],
        );
      }),
    );
  }
}

class TabButton extends StatelessWidget {
  final int tabIndex;
  final CustomClipper<Path> clipper;
  final String label;
  final bool roundedTopLeft;
  final bool roundedTopRight;
  final bool roundedBottomLeft;
  final bool roundedBottomRight;
  const TabButton({
    super.key,
    required this.tabIndex,
    required this.clipper,
    required this.label,
    this.roundedTopLeft = false,
    this.roundedTopRight = false,
    this.roundedBottomLeft = false,
    this.roundedBottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MainController>();
    return Expanded(
      child: ClipPath(
        clipper: clipper,
        child: Obx(<MainController>() {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: context.width > 500 ? 20 : 15),
              backgroundColor: c.profitTab.value == tabIndex ? Colors.green : background,
              overlayColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: roundedTopLeft ? Radius.circular(15.0) : Radius.zero,
                  topRight: roundedTopRight ? Radius.circular(15.0) : Radius.zero,
                  bottomLeft: roundedBottomLeft ? Radius.circular(15.0) : Radius.zero,
                  bottomRight: roundedBottomRight ? Radius.circular(15.0) : Radius.zero,
                ),
              ),
            ),
            onPressed: () => c.profitTab.value = tabIndex,
            child: Text(label, style: TextStyle(color: Colors.white, fontSize: context.width > 500 ? 20 : 18)),
          );
        }),
      ),
    );
  }
}

class Leftpath extends CustomClipper<Path> {
  final double notchDepth;

  Leftpath({this.notchDepth = 4.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(0, 0);
    path.lineTo(w - notchDepth * 3, 0);
    path.quadraticBezierTo(w + notchDepth, h / 4, w - notchDepth, h / 2);
    path.quadraticBezierTo(w - notchDepth * 3, h / 4 * 3, w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(Leftpath oldClipper) => oldClipper.notchDepth != notchDepth;
}

class Rightpath extends CustomClipper<Path> {
  final double notchDepth;

  Rightpath({this.notchDepth = 4.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(notchDepth * 3, h);
    path.quadraticBezierTo(0 - notchDepth, h / 4 * 3, notchDepth, h / 2);
    path.quadraticBezierTo(notchDepth * 3, h / 4, 0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(Rightpath oldClipper) => oldClipper.notchDepth != notchDepth;
}

class Bothpath extends CustomClipper<Path> {
  final double notchDepth;

  Bothpath({this.notchDepth = 4.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(0, 0);
    path.lineTo(w - notchDepth * 3, 0);
    path.quadraticBezierTo(w + notchDepth, h / 4, w - notchDepth, h / 2);
    path.quadraticBezierTo(w - notchDepth * 3, h / 4 * 3, w, h);
    path.lineTo(notchDepth * 3, h);
    path.quadraticBezierTo(0 - notchDepth, h / 4 * 3, notchDepth, h / 2);
    path.quadraticBezierTo(notchDepth * 3, h / 4, 0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(Bothpath oldClipper) => oldClipper.notchDepth != notchDepth;
}
