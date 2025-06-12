import 'package:ailence/main/main_controller.dart';
import 'package:ailence/main/utils/btn_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/shares.dart';
import '../../utils/app_vars.dart';
import '../../component/table_cell.dart';
import 'package:intl/intl.dart' as intl;

class AccountBalance extends StatelessWidget {
  final double startExpandNum;
  const AccountBalance({super.key, required this.startExpandNum});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MainController>();

    final balance = intl.NumberFormat('#,##0.00', 'en_US').format(double.parse(c.user.value.balance));

    return Container(
      width: context.width > startExpandNum ? 220 : double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: fullBackground),
      ),
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned(
              top: -15,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 15, color: fullBackground),
                  color: componentBackground,
                ),
              ),
            ),
            Align(
              child: Obx(() {
                return Column(
                  spacing: 2,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('رصيدك', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$balance ل.س'),
                    SizedBox(height: 10),
                    Text('أسهمك', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${c.user.value.shares} دقيقة'),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class Statistics extends StatefulWidget {
  final double stopExpandNum;
  const Statistics({super.key, required this.stopExpandNum});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final c = Get.find<MainController>();

  @override
  void initState() {
    super.initState();
    c.shares.value.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: context.width > widget.stopExpandNum ? 1 : 0,
      child: Container(
        height: 160,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          color: componentBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 10,
                children: const [
                  Icon(Icons.analytics),
                  Text('احصائيات المنصة', style: TextStyle(color: background, fontWeight: FontWeight.bold, fontSize: 18))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('عدد أسهم المنصة'), Text('${c.shares.value.totalShares} دقيقة')],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('أعلى سعر لآخر يوم'), Text('${c.shares.value.bestToday} جنيه')],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('أعلى سعر لآخر شهر'), Text('${c.shares.value.bestMonth} جنيه')],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('أعلى سعر لآخر سنة'), Text('${c.shares.value.bestYear} جنيه')],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IndicatorThumbShape extends RoundSliderThumbShape {
  static const SliderComponentShape _indicatorShape = PaddleSliderValueIndicatorShape();

  const IndicatorThumbShape();

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    bool? isPressed,
  }) {
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );

    _indicatorShape.paint(
      context,
      center,
      activationAnimation: const AlwaysStoppedAnimation(1),
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );
  }
}

class NowHourBalance extends StatelessWidget {
  final double startExpandNum;
  const NowHourBalance({super.key, required this.startExpandNum});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MainController>();

    return Container(
      width: context.width > startExpandNum ? 200 : double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: fullBackground),
      ),
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned(
              top: -15,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 15, color: fullBackground),
                  color: componentBackground,
                ),
              ),
            ),
            Align(
              child: Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 70, child: Text('رصيد أوقات عمل جديدة', style: TextStyle(fontWeight: FontWeight.bold))),
                  Obx(() => Text('${c.user.value.balanceToBuyShare} ل.س')),
                  ElevatedButton(
                    onPressed: c.user.value.convertBuyShareToBalance,
                    style: deepBlueBtnStyle.copyWith(padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10))),
                    child: const Text('تحويل لرصيدك', style: TextStyle(color: componentBackground, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DistributeProfit extends StatefulWidget {
  final double stopExpandNum;
  const DistributeProfit({super.key, required this.stopExpandNum});

  @override
  State<DistributeProfit> createState() => _DistributeProfitState();
}

class _DistributeProfitState extends State<DistributeProfit> {
  final c = Get.find<MainController>();
  int value = 50;
  int savedVal = 50;

  @override
  void initState() {
    value = c.user.value.distributePercent;
    savedVal = c.user.value.distributePercent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: context.width > widget.stopExpandNum ? 1 : 0,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: componentBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.swap_horizontal_circle),
                    Text('تقسيم أرباحك', style: TextStyle(color: background, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                if (savedVal != value)
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => savedVal = value);
                      await c.user.value.updateDistributePercent(value);
                    },
                    style: deepBlueBtnStyle.copyWith(padding: WidgetStateProperty.all(EdgeInsets.zero)),
                    child: const Text('حفظ', style: TextStyle(color: componentBackground, fontSize: 13)),
                  ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 35, child: Text('سحب الأرباح', style: TextStyle(color: Colors.green))),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const IndicatorThumbShape(),
                      showValueIndicator: ShowValueIndicator.never,
                    ),
                    child: Slider(
                      value: value.toDouble(),
                      min: 0,
                      max: 100,
                      label: '${value.toInt()}% سحب  |  ${100 - value.toInt()}% شراء',
                      divisions: 20,
                      activeColor: Colors.green,
                      onChanged: (val) => setState(() => value = val.toInt()),
                    ),
                  ),
                ),
                const SizedBox(width: 70, child: Text('شراء أوقات عمل جديدة', style: TextStyle(color: Colors.grey))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DistributedMoney extends StatefulWidget {
  final double breakPoint;
  const DistributedMoney({super.key, required this.breakPoint});

  @override
  State<DistributedMoney> createState() => _DistributedMoneyState();
}

class _DistributedMoneyState extends State<DistributedMoney> {
  final c = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                spacing: 10,
                children: [Icon(Icons.cached), Text('توزيعات الأرباح', style: TextStyle(color: background, fontWeight: FontWeight.bold, fontSize: 18))],
              ),
              SizedBox(
                height: 20,
                child: ElevatedButton(
                  onPressed: () {},
                  style: deepBlueBtnStyle.copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.hovered)) return Colors.blue[900]!.withValues(alpha: 0.7);
                        if (states.contains(WidgetState.pressed)) return Colors.blue[900]!.withValues(alpha: 0.7);
                        return Colors.blue[900]!;
                      },
                    ),
                    overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                      return states.contains(WidgetState.pressed) ? Colors.blue[900]!.withValues(alpha: 0.7) : null;
                    }),
                  ),
                  child: const Text('انتقال لصفحة توزيع الأرباح', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
            ],
          ),
          Obx(() {
            List<DistruibutedProfit> profits = c.shares.value.distruibutedShares;

            List<TableRow> rows = [
              TableRow(
                decoration: BoxDecoration(color: Colors.blue[900]!),
                children: [
                  AppTableCell(text: 'التاريخ', isHead: true),
                  AppTableCell(text: 'المبلغ الكلي', isHead: true),
                  AppTableCell(text: 'حصتك', isHead: true),
                ],
              ),
            ];

            for (var i = 0; i < profits.length; i++) {
              DateTime date = DateTime.fromMillisecondsSinceEpoch(profits[i].createdAt * 1000);

              rows.add(TableRow(
                decoration: BoxDecoration(color: i.isEven ? componentBackground : const Color(0xFFEBECEE)),
                children: [
                  AppTableCell(text: intl.DateFormat('dd/MM/yyyy').format(date)),
                  AppTableCell(text: profits[i].amount.toString()),
                  AppTableCell(text: profits[i].userAmount.toString()),
                ],
              ));
            }

            if (rows.length == 1) {
              for (var i = 0; i < 4; i++) {
                rows.add(TableRow(
                  decoration: BoxDecoration(color: i.isEven ? componentBackground : const Color(0xFFDCE4FC)),
                  children: const [
                    AppTableCell(text: ''),
                    AppTableCell(text: ''),
                    AppTableCell(text: ''),
                  ],
                ));
              }
            }

            return Table(
              border: TableBorder(
                top: BorderSide(color: Colors.blue[900]!, width: 2),
                bottom: BorderSide(color: Colors.blue[900]!, width: 1),
                left: BorderSide(color: Colors.blue[900]!, width: 1),
                right: BorderSide(color: Colors.blue[900]!, width: 1),
                horizontalInside: BorderSide(color: Colors.blue[900]!, width: 1),
                verticalInside: BorderSide(color: Colors.blue[900]!, width: 1),
              ),
              children: rows,
            );
          }),
        ],
      ),
    );
  }
}

class DistributedShares extends StatefulWidget {
  final double breakPoint;
  const DistributedShares({super.key, required this.breakPoint});

  @override
  State<DistributedShares> createState() => _DistributedSharesState();
}

class _DistributedSharesState extends State<DistributedShares> {
  final c = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.assured_workload), Text('الأسهم', style: TextStyle(color: background, fontWeight: FontWeight.bold, fontSize: 18))],
              ),
              SizedBox(
                height: 20,
                child: ElevatedButton(
                  onPressed: () {},
                  style: deepBlueBtnStyle.copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.hovered)) return Colors.yellow[900]!.withValues(alpha: 0.7);
                        if (states.contains(WidgetState.pressed)) return Colors.yellow[900]!.withValues(alpha: 0.7);
                        return Colors.yellow[900]!;
                      },
                    ),
                    overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                      return states.contains(WidgetState.pressed) ? Colors.yellow[900]!.withValues(alpha: 0.7) : null;
                    }),
                  ),
                  child: const Text('انتقال لصفحة توزيعات الأسهم', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
            ],
          ),
          Obx(() {
            List<SharesData> sharesData = c.shares.value.sharesData;

            List<TableRow> rows = [
              TableRow(
                decoration: BoxDecoration(color: Colors.yellow[900]!),
                children: [
                  AppTableCell(text: 'التاريخ', isHead: true),
                  AppTableCell(text: 'الكمية', isHead: true),
                  AppTableCell(text: 'المصدر', isHead: true),
                  AppTableCell(text: 'المهمة', isHead: true),
                ],
              ),
            ];

            for (var i = 0; i < sharesData.length; i++) {
              DateTime date = DateTime.fromMillisecondsSinceEpoch(sharesData[i].createdAt);

              rows.add(TableRow(
                decoration: BoxDecoration(color: i.isEven ? componentBackground : const Color(0xFFEBECEE)),
                children: [
                  AppTableCell(text: intl.DateFormat('dd/MM/yyyy').format(date)),
                  AppTableCell(text: sharesData[i].amount.toString()),
                  AppTableCell(text: sharesData[i].source),
                  MoreShareInfo(shareId: sharesData[i].id, amount: sharesData[i].amount),
                ],
              ));
            }

            if (rows.length == 1) {
              for (var i = 0; i < 4; i++) {
                rows.add(TableRow(
                  decoration: BoxDecoration(color: i.isEven ? componentBackground : const Color(0xFFDCE4FC)),
                  children: const [
                    AppTableCell(text: ''),
                    AppTableCell(text: ''),
                    AppTableCell(text: ''),
                    AppTableCell(text: ''),
                  ],
                ));
              }
            }

            return Table(
              border: TableBorder(
                top: BorderSide(color: Colors.yellow[900]!, width: 2),
                bottom: BorderSide(color: Colors.yellow[900]!, width: 1),
                left: BorderSide(color: Colors.yellow[900]!, width: 1),
                right: BorderSide(color: Colors.yellow[900]!, width: 1),
                horizontalInside: BorderSide(color: Colors.yellow[900]!, width: 1),
                verticalInside: BorderSide(color: Colors.yellow[900]!, width: 1),
              ),
              children: rows,
            );
          }),
        ],
      ),
    );
  }
}

class MoreShareInfo extends StatefulWidget {
  final int shareId;
  final int amount;
  const MoreShareInfo({super.key, required this.shareId, required this.amount});

  @override
  State<MoreShareInfo> createState() => _MoreShareInfoState();
}

class _MoreShareInfoState extends State<MoreShareInfo> {
  bool waiting = false;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ElevatedButton(
          onPressed: () async {
            setState(() => waiting = true);
            ShareInfo? info = await Shares.getShareInfo(widget.shareId);
            if (info != null) {
              Get.defaultDialog(
                title: 'معلومات الأسهم',
                textCancel: 'إغلاق',
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 120, child: Text('المستوى :', style: TextStyle(fontWeight: FontWeight.bold))),
                        Flexible(child: Text(info.level)),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 120, child: Text('المادة :', style: TextStyle(fontWeight: FontWeight.bold))),
                        Flexible(child: Text(info.curriculum)),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 120, child: Text('المهمة :', style: TextStyle(fontWeight: FontWeight.bold))),
                        Flexible(child: Text(info.userTaskName)),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 120, child: Text('تاريخ المهمة :', style: TextStyle(fontWeight: FontWeight.bold))),
                        Flexible(child: Text(info.time)),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 120, child: Text('كامل الأسهم :', style: TextStyle(fontWeight: FontWeight.bold))),
                        Flexible(child: Text('${info.shares} سهم')),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 120, child: Text('حصتك من الأسهم :', style: TextStyle(fontWeight: FontWeight.bold))),
                        Flexible(child: Text('${widget.amount} سهم')),
                      ],
                    ),
                  ],
                ),
              );
            }
            setState(() => waiting = false);
          },
          child: waiting ? CircularProgressIndicator(color: Colors.yellow[900]!) : FittedBox(child: Text('المزيد')),
        ),
      ),
    );
  }
}
