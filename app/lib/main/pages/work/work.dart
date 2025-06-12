import 'package:ailence/main/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../component/table_cell.dart';
import '../../utils/btn_style.dart';
import '../../utils/app_vars.dart';
import '../../model/workdata.dart';

class StartWork extends StatelessWidget {
  final double startExpandNum;
  const StartWork({super.key, required this.startExpandNum});

  @override
  Widget build(BuildContext context) {
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
                width: 190,
                height: 190,
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
                  const Text('قسم العمل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/work/materials'),
                    style: deepBlueBtnStyle,
                    child: const Text('ابدأ', style: TextStyle(color: componentBackground)),
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

class AccountWorkInfo extends StatefulWidget {
  final double stopExpandNum;
  const AccountWorkInfo({super.key, required this.stopExpandNum});

  @override
  State<AccountWorkInfo> createState() => _AccountWorkInfoState();
}

class _AccountWorkInfoState extends State<AccountWorkInfo> {
  var c = Get.find<MainController>();

  @override
  void initState() {
    c.tasks.value.getDoneTask();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: context.width > widget.stopExpandNum ? 1 : 0,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: componentBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          spacing: 6,
          children: [
            const Row(
              spacing: 10,
              children: [
                Icon(Icons.equalizer),
                Text('معلومات عملك', style: TextStyle(color: background, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  spacing: 6,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('أسهم عملك المحـققـة', style: TextStyle(fontSize: 13, color: Colors.green)),
                    Text('أسهم عملك المـعـلـقـة', style: TextStyle(fontSize: 13, color: Colors.orange)),
                    Text('أسهم عملك المرفوضة', style: TextStyle(fontSize: 13, color: Colors.red)),
                    Text('أسهم عملك الـمـلـغـاة', style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
                  ],
                ),
                Obx(
                  <MainController>() => Column(
                    spacing: 6,
                    children: [
                      Text('${c.tasks.value.verfiedNum} دقيقة', style: const TextStyle(fontSize: 13, color: Colors.green)),
                      Text('${c.tasks.value.pendingNum} دقيقة', style: const TextStyle(fontSize: 13, color: Colors.orange)),
                      Text('${c.tasks.value.rejectedNum} دقيقة', style: const TextStyle(fontSize: 13, color: Colors.red)),
                      Text('${c.tasks.value.cancelledNum} دقيقة', style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LastAddedWork extends StatefulWidget {
  const LastAddedWork({super.key});

  @override
  State<LastAddedWork> createState() => _LastAddedWorkState();
}

class _LastAddedWorkState extends State<LastAddedWork> {
  bool fetchingData = false;
  int offset = 0;
  var c = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          const Row(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.post_add),
              Text(
                'آخر الأعمال المضافة',
                style: TextStyle(color: background, fontWeight: FontWeight.bold, fontSize: 18),
              )
            ],
          ),
          Obx(() {
            List<DoneTask> tasks = c.tasks.value.doneTasks;

            return Table(
              border: const TableBorder(
                top: BorderSide(color: background, width: 2),
                bottom: BorderSide(color: background, width: 1),
                left: BorderSide(color: background, width: 1),
                right: BorderSide(color: background, width: 1),
                horizontalInside: BorderSide(color: background, width: 1),
                verticalInside: BorderSide(color: background, width: 1),
              ),
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: background),
                  children: [
                    AppTableCell(text: 'التاريخ', isHead: true),
                    AppTableCell(text: 'النوع', isHead: true),
                    AppTableCell(text: 'المادة', isHead: true),
                    AppTableCell(text: 'الكمية المحققة', isHead: true),
                    AppTableCell(text: 'الكمية المرفوضة', isHead: true),
                    AppTableCell(text: 'الحالة', isHead: true),
                  ],
                ),
                if (tasks.isNotEmpty)
                  ...tasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    final bgColor = index % 2 == 0 ? Colors.white : background.withValues(alpha: 0.1);
                    final date = DateTime.fromMillisecondsSinceEpoch(task.time * 1000);
                    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

                    return TableRow(
                      decoration: BoxDecoration(color: bgColor),
                      children: [
                        AppTableCell(text: formattedDate),
                        AppTableCell(text: '${task.doItNum > 0 ? 'التحقق من ' : ''}${task.userTaskName}'),
                        AppTableCell(text: task.curriculum),
                        AppTableCell(text: task.userShare.toString()),
                        AppTableCell(text: '${(task.shares - task.userShare > 0) ? task.shares - task.userShare : 0}'),
                        AppTableCell(text: _getStatusText(task.status)),
                      ],
                    );
                  }),
                if (tasks.isEmpty) ...[
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.white),
                    children: [
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(color: background.withValues(alpha: 0.1)),
                    children: const [
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                    ],
                  ),
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.white),
                    children: [
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(color: background.withValues(alpha: 0.1)),
                    children: const [
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                      AppTableCell(text: ''),
                    ],
                  ),
                ]
              ],
            );
          }),
        ],
      ),
    );
  }
}

String _getStatusText(int status) {
  switch (status) {
    case 1:
      return "قيد التحقق";
    case 2:
      return "تم التحقق";
    case -1:
      return "تم الإلغاء";
    default:
      return "";
  }
}
