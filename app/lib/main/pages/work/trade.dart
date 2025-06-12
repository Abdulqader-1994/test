import 'package:ailence/main/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import '../../component/table_cell.dart';
import '../../model/shares.dart';
import '../../model/shares_trade.dart';
import '../../utils/app_vars.dart';

class PriceChart extends StatefulWidget {
  const PriceChart({super.key});

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  var c = Get.find<MainController>();

  int currentRangeDays = 10;
  final List<Color> gradientColors = [Colors.cyan, Colors.blue];
  late double overallMin, overallMax;

  @override
  void initState() {
    super.initState();
    c.trade.value.connect();
  }

  @override
  void dispose() {
    super.dispose();
    c.trade.value.closeConnection();
  }

  List<Statistics> downsampleData(List<Statistics> data) {
    int n = data.length;
    if (n <= 10) return data;
    List<Statistics> sampled = [];
    for (int i = 0; i < 10; i++) {
      int index = (i * (n - 1) / 9).round();
      sampled.add(data[index]);
    }
    return sampled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 25, 5),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Obx(() {
        List<Statistics> statistics = c.shares.value.statistics;
        if (statistics.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        overallMin = statistics.map((s) => s.price).reduce(math.min).toDouble();
        overallMax = statistics.map((s) => s.price).reduce(math.max).toDouble();
        double overallPadding = (overallMax - overallMin) * 0.1;
        overallMin -= overallPadding;
        overallMax += overallPadding;

        List<Statistics> visibleData = statistics.reversed.take(currentRangeDays).toList();
        List<Statistics> chartData = downsampleData(visibleData.reversed.toList());

        List<FlSpot> spots = [];
        for (int i = 0; i < chartData.length; i++) {
          spots.add(FlSpot(i.toDouble(), chartData[i].price.toDouble()));
        }

        List<String> dateLabels = chartData.map((entry) => intl.DateFormat('d/M').format(entry.createdAt)).toList();

        DateTime oldestDate = statistics.last.createdAt;
        DateTime newestDate = statistics.first.createdAt;
        int totalDays = oldestDate.difference(newestDate).inDays + 1;

        return Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    overlayColor: Colors.blue[900]!,
                  ),
                  onPressed: () {
                    if (currentRangeDays > 10) setState(() => currentRangeDays = (currentRangeDays ~/ 2).clamp(10, totalDays));
                  },
                  child: const Text('تصغير', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    overlayColor: Colors.blue[900],
                  ),
                  onPressed: () {
                    setState(() {
                      int newRange = currentRangeDays * 2;
                      currentRangeDays = newRange > totalDays ? totalDays : newRange;
                    });
                  },
                  child: const Text('تكبير', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (v) => Colors.blue[900]!,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((lineBarSpot) {
                          return LineTooltipItem(lineBarSpot.y.toStringAsFixed(1), const TextStyle(color: Colors.white));
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= dateLabels.length) return Container();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 1, height: 10, color: const Color(0xff37434d)),
                              Text(
                                dateLabels[index],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: ((overallMax - overallMin) / 8),
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const double tolerance = 0.001;
                          if ((value - overallMin).abs() < tolerance || (value - overallMax).abs() < tolerance) return Container();
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(height: 1, width: 10, color: const Color(0xff37434d)),
                              Text(
                                value.toStringAsFixed(1),
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Color(0xff37434d), width: 2),
                      bottom: BorderSide(color: Color(0xff37434d), width: 2),
                    ),
                  ),
                  minX: 0,
                  maxX: 9,
                  minY: overallMin,
                  maxY: overallMax,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[600]!]),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (FlSpot spot, double xPercentage, LineChartBarData bar, int index) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 1,
                          strokeColor: Colors.blue[900]!,
                        ),
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class OrderBook extends StatefulWidget {
  final int stopExpandNum;
  const OrderBook({super.key, required this.stopExpandNum});

  @override
  State<OrderBook> createState() => _OrderBookState();
}

class _OrderBookState extends State<OrderBook> {
  final c = Get.find<MainController>();
  var amount = TextEditingController();
  var price = TextEditingController();

  int total = 0;
  int shares = 0;

  @override
  void initState() {
    super.initState();
    shares = c.user.value.shares;
    c.trade.value.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: context.width > widget.stopExpandNum ? 1 : 0,
      child: Container(
        height: 355,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: componentBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 5,
              children: [
                Icon(Icons.price_change, color: background),
                const Text('عروض البيع والشراء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            Obx(() {
              List<Order> sellOrders = c.trade.value.sellOrders.take(4).toList().reversed.toList();
              List<Order> buyOrders = c.trade.value.buyOrders.reversed.take(4).toList();

              List<Widget> childs = [
                Container(
                  color: background,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OrderText(text: 'الكمية', color: componentBackground),
                      OrderText(text: 'السعر', color: componentBackground),
                      OrderText(text: 'المجموع', color: componentBackground),
                    ],
                  ),
                ),
              ];

              for (var order in sellOrders) {
                final orderTotal = (order.price * order.amount).toString();
                final fraction = 1 - (order.executed / order.amount).clamp(0.0, 1.0);

                childs.add(Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      stops: [0.0, fraction, fraction, 1.0],
                      colors: [
                        componentBackground,
                        componentBackground,
                        Colors.red.withValues(alpha: 0.2),
                        Colors.red.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OrderText(text: order.amount.toString(), color: Colors.red),
                      OrderText(text: order.price.toString(), color: Colors.red),
                      OrderText(text: orderTotal, color: Colors.red),
                    ],
                  ),
                ));
              }

              int spread = 0;
              if (sellOrders.isNotEmpty && buyOrders.isNotEmpty) spread = sellOrders.last.price - buyOrders.first.price;

              childs.add(Container(
                color: background.withValues(alpha: 0.75),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text('فرق السعر : $spread ليرة سورية', textAlign: TextAlign.center, style: TextStyle(color: componentBackground)),
                    ),
                  ],
                ),
              ));

              for (var order in buyOrders) {
                final orderTotal = (order.price * order.amount).toString();
                final fraction = 1 - (order.executed / order.amount).clamp(0.0, 1.0);

                childs.add(Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      stops: [0.0, fraction, fraction, 1.0],
                      colors: [
                        componentBackground,
                        componentBackground,
                        Colors.green.withValues(alpha: 0.2),
                        Colors.green.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OrderText(text: order.amount.toString(), color: Colors.green),
                      OrderText(text: order.price.toString(), color: Colors.green),
                      OrderText(text: orderTotal, color: Colors.green),
                    ],
                  ),
                ));
              }

              return Column(children: childs);
            }),
          ],
        ),
      ),
    );
  }
}

class OrderText extends StatelessWidget {
  final String text;
  final Color color;
  const OrderText({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    double width = 60;

    return Container(
      width: width,
      padding: const EdgeInsets.all(5.0),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: color)),
    );
  }
}

class PlaceNewOrder extends StatefulWidget {
  final int stopExpandNum;
  const PlaceNewOrder({super.key, required this.stopExpandNum});

  @override
  State<PlaceNewOrder> createState() => _PlaceNewOrderState();
}

class _PlaceNewOrderState extends State<PlaceNewOrder> {
  final c = Get.find<MainController>();
  var amount = TextEditingController();
  var price = TextEditingController();
  bool market = true;
  int orderType = 0;
  int total = 0;

  @override
  Widget build(BuildContext context) {
    int shares = c.user.value.shares;
    int balance = double.parse(c.user.value.balance).ceil();

    for (var el in c.trade.value.history) {
      if (el.orderStatus != 1) continue;
      if (el.orderType == 0) balance -= el.amount * el.price;
      if (el.orderType == 1) shares -= el.amount - el.executed;
    }

    return Expanded(
      flex: context.width > widget.stopExpandNum ? 1 : 0,
      child: Container(
        height: 355,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: componentBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // title
            Row(
              spacing: 5,
              children: [
                Icon(Icons.post_add, color: background),
                const Text('إضافة عرض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),

            // select order
            Row(
              spacing: 5,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      price.text = '';
                      amount.text = '';

                      setState(() {
                        total = 0;
                        market = true;
                        orderType = 0;
                      });
                    },
                    style: TextButton.styleFrom(
                      overlayColor: Colors.white,
                      backgroundColor: orderType == 0 ? Colors.green : null,
                      side: BorderSide(width: 2, color: Colors.green),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(13))),
                    ),
                    child: Text('شراء', style: TextStyle(color: orderType == 0 ? Colors.white : Colors.green)),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      price.text = '';
                      amount.text = '';

                      setState(() {
                        total = 0;
                        market = true;
                        orderType = 1;
                      });
                    },
                    style: TextButton.styleFrom(
                      overlayColor: Colors.white,
                      backgroundColor: orderType == 1 ? Colors.red : null,
                      side: BorderSide(width: 2, color: Colors.red),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(13))),
                    ),
                    child: Text('بيع', style: TextStyle(color: orderType == 1 ? Colors.white : Colors.red)),
                  ),
                ),
              ],
            ),

            // amount TextField
            TextField(
              controller: amount,
              style: TextStyle(color: Colors.black, fontSize: 14),
              cursorColor: Colors.black,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                int newTotal = 0;
                if (price.text.isNotEmpty && v.isNotEmpty && !market) newTotal = int.parse(v) * int.parse(price.text);
                if (v.isNotEmpty && market) {
                  int a = int.parse(v);
                  List<Order> ords = orderType == 0 ? c.trade.value.sellOrders : c.trade.value.buyOrders.reversed.toList();
                  for (Order ord in ords) {
                    if (a > ord.amount) {
                      newTotal += ord.amount * ord.price;
                      a -= ord.amount;
                    } else {
                      newTotal += a * ord.price;
                      a -= a;
                      break;
                    }
                  }

                  if (a > 0 && ords.isNotEmpty) newTotal += a * ords.last.price;
                }

                setState(() => total = newTotal);
              },
              decoration: InputDecoration(
                isDense: true,
                labelText: 'الكمية',
                labelStyle: TextStyle(color: Colors.black, fontSize: 14),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 1)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 2)),
              ),
            ),

            // price TextField
            Row(
              spacing: 5,
              children: [
                Flexible(
                  child: TextField(
                    controller: price,
                    enabled: !market,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) {
                      int newTotal = 0;
                      if (v.isNotEmpty && amount.text.isNotEmpty) newTotal = int.parse(amount.text) * int.parse(price.text);
                      setState(() => total = newTotal);
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      filled: market,
                      label: Text(market ? 'السعر: حسب الأفضل في السوق' : 'السعر', style: TextStyle(fontSize: market ? 12 : null)),
                      labelStyle: TextStyle(fontSize: market ? 11 : null),
                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 1)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 2)),
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: market ? Colors.grey[800] : Colors.transparent,
                  child: IconButton(
                    onPressed: () => setState(() {
                      market = !market;
                      price.text = '';

                      if (market) {
                        int newTotal = 0;
                        if (amount.text.isNotEmpty) {
                          int a = int.parse(amount.text);

                          List<Order> ords = orderType == 0 ? c.trade.value.sellOrders : c.trade.value.buyOrders.reversed.toList();
                          for (Order ord in ords) {
                            if (a > ord.amount) {
                              newTotal += ord.amount * ord.price;
                              a -= ord.amount;
                            } else {
                              newTotal += a * ord.price;
                              a -= a;
                              break;
                            }
                          }

                          if (a > 0 && ords.isNotEmpty) newTotal += a * ords.last.price;
                        }
                        setState(() => total = newTotal);
                      } else {
                        int newTotal = 0;
                        if (price.text.isNotEmpty && amount.text.isNotEmpty) newTotal = int.parse(amount.text) * int.parse(price.text);
                        setState(() => total = newTotal);
                      }
                    }),
                    icon: Icon(Icons.edit, color: market ? Colors.white : background, size: 20),
                  ),
                ),
              ],
            ),

            // total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('المجموع', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('$total ليرة سورية', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // sell/buy button
            ElevatedButton(
              onPressed: () {
                int? a = int.tryParse(amount.text);
                int p = int.tryParse(price.text) ?? 0; // 0 mean the best market price

                bool isValid = c.trade.value.validateOrder(total: total, amount: a, orderType: orderType, balance: balance, shares: shares);
                if (!isValid) return;

                setState(() {
                  amount.text = '';
                  price.text = '';
                  market = true;
                  total = 0;
                });
                c.trade.value.placeOrder(amount: a!, price: p, orderType: orderType);
              },
              style: ElevatedButton.styleFrom(
                overlayColor: Colors.white,
                backgroundColor: orderType == 0 ? Colors.green : Colors.red,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              child: (!c.trade.value.waiting)
                  ? Text(orderType == 0 ? 'إضافة طلب شراء' : 'إضافة طلب بيع', style: TextStyle(color: Colors.white))
                  : CircleAvatar(radius: 12, backgroundColor: Colors.transparent, child: CircularProgressIndicator(color: Colors.white)),
            ),

            // balance data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (orderType == 0) Text('الرصيد المتوفر'),
                if (orderType == 0) Text('${balance.toString()} ليرة سورية'),
                if (orderType == 1) Text('الأسهم المتوفرة'),
                if (orderType == 1) Text('${shares.toString()} سهم'),
              ],
            ),

            // tax
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange[700]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.info, color: Colors.orange[700]!),
                  Text('ضريبة : 100 ل.س لكل عملية', style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryOrders extends StatefulWidget {
  const HistoryOrders({super.key});

  @override
  State<HistoryOrders> createState() => _HistoryOrdersState();
}

class _HistoryOrdersState extends State<HistoryOrders> {
  final c = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              Icon(Icons.history),
              Text('التداولات السابقة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          Obx(() {
            List<HistoryOrder> orders = c.trade.value.history;

            List<TableRow> rows = [
              TableRow(
                decoration: BoxDecoration(color: Colors.black),
                children: [
                  AppTableCell(text: 'التاريخ', isHead: true),
                  AppTableCell(text: 'النوع', isHead: true),
                  AppTableCell(text: 'الكمية المنفذة', isHead: true),
                  AppTableCell(text: 'السعر', isHead: true),
                  AppTableCell(text: 'الحالة', isHead: true),
                ],
              ),
            ];

            for (var i = 0; i < orders.length; i++) {
              String p = orders[i].price.toString();
              if (p == '0') p = 'الأفضل في السوق';

              rows.add(TableRow(
                decoration: BoxDecoration(color: i.isEven ? componentBackground : const Color(0xFFEBECEE)),
                children: [
                  AppTableCell(text: '${orders[i].hourDate}\n${orders[i].dayDate}'),
                  OrderTypeCell(orderType: orders[i].orderType),
                  AppTableCell(text: '${orders[i].executed}  من  ${orders[i].amount}'),
                  AppTableCell(text: p),
                  OrderStatusCell(orderStatus: orders[i].orderStatus, orderId: orders[i].id),
                ],
              ));
            }

            if (rows.length == 1) {
              for (var i = 0; i < 4; i++) {
                rows.add(TableRow(
                  decoration: BoxDecoration(color: i.isEven ? componentBackground : const Color(0xFFEBECEE)),
                  children: [
                    AppTableCell(text: ''),
                    AppTableCell(text: ''),
                    AppTableCell(text: ''),
                    AppTableCell(text: ''),
                    AppTableCell(text: ''),
                  ],
                ));
              }
            }

            return Table(
              border: const TableBorder(
                top: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 1),
                left: BorderSide(color: Colors.black, width: 1),
                right: BorderSide(color: Colors.black, width: 1),
              ),
              children: rows,
            );
          }),
        ],
      ),
    );
  }
}

class OrderTypeCell extends StatelessWidget {
  final int orderType;
  const OrderTypeCell({super.key, required this.orderType});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(
        child: Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: (orderType == 0) ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(15)),
          child: Text(
            (orderType == 0) ? 'شراء' : 'بيع',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class OrderStatusCell extends StatelessWidget {
  final int orderStatus;
  final int orderId;
  const OrderStatusCell({super.key, required this.orderStatus, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MainController>();

    String text = 'ملغى'; // orders[i].orderStatus == 0
    if (orderStatus == 1) text = 'قيد التنفيذ';
    if (orderStatus == 2) text = 'مكتمل';

    Color color = Colors.blueGrey[800]!;
    if (orderStatus == 1) color = Colors.orange;
    if (orderStatus == 2) color = Colors.blue;

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            spacing: 3,
            children: [
              Container(
                width: 70,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
                child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
              if (orderStatus == 1)
                TextButton(
                  onPressed: () => c.trade.value.cancelOrder(orderId),
                  child: Text('إلغاء الطلب', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey[800], fontSize: 13)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
