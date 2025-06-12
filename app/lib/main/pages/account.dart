import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../component/main_widget.dart';
import '../component/table_cell.dart';
import '../model/auth.dart';
import '../model/api.dart';
import '../model/user.dart';
import '../utils/app_vars.dart';
import '../main_controller.dart';
import '../utils/btn_style.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return MainWidget(
      page: Column(
        spacing: 25,
        children: [
          const Row(children: [Hello(), AccountBedge()]),
          IntrinsicHeight(
            child: Flex(
              direction: context.width > 500 ? Axis.horizontal : Axis.vertical,
              children: const [AccountInfo(), AccountBalance()],
            ),
          ),
          const TransectionTable(),
        ],
      ),
    );
  }
}

class Hello extends StatelessWidget {
  const Hello({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MainController>();
    double totalWidth = context.width < appWidth ? context.width : appWidth;
    double settedSize = totalWidth / 100 * 3.5;
    double size = settedSize < 15 ? settedSize : 15;

    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: componentBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(
              () => RichText(
                text: TextSpan(
                  style: const TextStyle(color: background),
                  children: [
                    TextSpan(text: 'مرحباً بك ', style: TextStyle(fontSize: size)),
                    TextSpan(text: c.user.value.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: size)),
                  ],
                ),
              ),
            ),
            Text('سعيدون بلقائك مرة أخرى', style: TextStyle(color: background, fontSize: size)),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Get.toNamed('/faq'),
                child: Text('ننصحك بشدة مراجعة الأسئلة الشائعة', style: TextStyle(color: Colors.blue, fontSize: size - 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountBedge extends StatelessWidget {
  const AccountBedge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width > 500 ? 200 : 120,
      height: 100,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        children: [
          Icon(Icons.account_circle, color: background, size: 70),
          Text('الحساب الشخصي', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class AccountInfo extends GetView<MainController> {
  const AccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: context.width > 500 ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: componentBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: const Row(
                spacing: 5,
                children: [
                  Icon(Icons.contacts),
                  Text('معلومات الحساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('رقم المعرف الخاص بك'),
                Text('${controller.user.value.id + 1000000}', textAlign: TextAlign.center),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('اسم المستخدم'),
                Obx(() => Text(controller.user.value.userName, textAlign: TextAlign.center)),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('البلد'),
                Text('سوريا', textAlign: TextAlign.center),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await Get.defaultDialog(title: 'تعديل اسم المستخدم', content: const EditUserName());
                  },
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 3)),
                  label: const Text('تعديل اسم المستخدم', style: TextStyle(fontSize: 12)),
                ),
                TextButton.icon(
                  onPressed: Auth.logOut,
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 3)),
                  label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditUserName extends StatefulWidget {
  const EditUserName({super.key});

  @override
  State<EditUserName> createState() => _EditUserNameState();
}

class _EditUserNameState extends State<EditUserName> {
  bool wait = false;
  final deepBlue = const Color(0xFF062D67);
  ApiResponse? res;
  var c = Get.find<MainController>();
  var controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = c.user.value.userName;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: controller,
              onChanged: (val) => setState(() => res = null),
              decoration: InputDecoration(
                label: const Text('اسم المستخدم'),
                helperText: 'يجب أن لا يقل عن 5 أحرف',
                errorText: (res != null && !res!.success) ? res!.data : null,
              ),
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
                  if (controller.value.text == c.user.value.userName) {
                    Get.back();
                    return;
                  }

                  setState(() {
                    wait = true;
                    res = null;
                  });

                  ApiResponse data = await User.updateUserName(newValue: controller.value.text);

                  setState(() {
                    wait = false;
                    res = data;
                  });

                  if (data.success) {
                    c.user.value.userName = controller.value.text;
                    c.user.value.save();
                    c.user.refresh();
                    Get.back();
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
    );
  }
}

class AccountBalance extends GetView<MainController> {
  const AccountBalance({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = intl.NumberFormat('#,##0.00', 'en_US').format(double.parse(controller.user.value.balance));

    return Container(
      width: context.width > 500 ? 200 : null,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      margin: EdgeInsets.only(right: context.width > 500 ? 20 : 0, top: context.width > 500 ? 0 : 20),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Flex(
        spacing: 10,
        direction: context.width > 500 ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: context.width > 500 ? 15 : 25,
            children: [
              const Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.paid),
                  Text('رصيد الحساب', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(balance, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('ليرة', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Column(
            spacing: 15,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: deepBlueBtnStyle,
                child: const Text('سحب الرصيد', style: TextStyle(color: componentBackground)),
              ),
              ElevatedButton(
                onPressed: () {},
                style: deepBlueBtnStyle,
                child: const Text('تعبئة الرصيد', style: TextStyle(color: componentBackground)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TransectionTable extends StatefulWidget {
  const TransectionTable({super.key});

  @override
  State<TransectionTable> createState() => _TransectionTableState();
}

class _TransectionTableState extends State<TransectionTable> {
  int offset = 0;
  var c = Get.find<MainController>();
  bool fetchingData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchTransactions());
  }

  // TODO: add offset for transcrtion
  Future<void> fetchTransactions() async {
    setState(() => fetchingData = true);
    await User.getTransections(
      jwtToken: c.user.value.jwtToken,
      userId: c.user.value.id,
      offset: offset * 10,
    );
    setState(() => fetchingData = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                spacing: 10,
                children: [
                  Icon(Icons.currency_exchange),
                  Text('التحويلات السابقة', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              if (fetchingData) const CircularProgressIndicator(color: background, strokeWidth: 3)
            ],
          ),
          Stack(
            children: [
              Obx(<MainController>() {
                List<TableRow> rows = [
                  const TableRow(
                    decoration: BoxDecoration(color: background),
                    children: [
                      AppTableCell(text: 'التاريخ', isHead: true),
                      AppTableCell(text: 'رقم العملية', isHead: true),
                      AppTableCell(text: 'المبلغ', isHead: true),
                      AppTableCell(text: 'طريقة التحويل', isHead: true),
                      AppTableCell(text: 'نوع التحويل', isHead: true),
                    ],
                  ),
                ];

                for (var i = 0; i < c.user.value.transection.length; i++) {
                  var trans = c.user.value.transection[i];
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(trans.time * 1000);

                  rows.add(TableRow(
                    decoration: BoxDecoration(color: i.isEven ? componentBackground : const Color(0xFFDCE4FC)),
                    children: [
                      AppTableCell(text: intl.DateFormat('dd/MM/yyyy').format(date)),
                      AppTableCell(text: '${trans.id + 1000000}'),
                      AppTableCell(text: '${trans.amount} ${trans.currencyInfo}'),
                      AppTableCell(text: trans.provider),
                      AppTableCell(text: (trans.type == 0) ? 'سحب' : 'إيداع'),
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
                        AppTableCell(text: ''),
                      ],
                    ));
                  }
                }

                return Table(
                  border: const TableBorder(
                    top: BorderSide(color: background, width: 2),
                    bottom: BorderSide(color: background, width: 1),
                    left: BorderSide(color: background, width: 1),
                    right: BorderSide(color: background, width: 1),
                    horizontalInside: BorderSide(color: background, width: 1),
                    verticalInside: BorderSide(color: background, width: 1),
                  ),
                  children: rows,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
