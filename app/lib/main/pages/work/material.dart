import '../../component/table_cell.dart';
import '../../utils/btn_style.dart';
import '../../main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../component/main_widget.dart';
import '../../utils/app_vars.dart';
import '../../model/workdata.dart';

class Materials extends StatelessWidget {
  const Materials({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainWidget(
      page: Column(
        spacing: 10,
        children: [
          HeaderRouter(),
          SearchTasks(),
        ],
      ),
    );
  }
}

class HeaderRouter extends StatelessWidget {
  const HeaderRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        spacing: 3,
        children: [
          TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 3)),
            onPressed: () => Get.toNamed('/work'),
            child: const Text('منصة العمل', style: TextStyle(color: background, fontSize: 16)),
          ),
          const RotatedBox(quarterTurns: 2, child: Icon(Icons.double_arrow)),
          TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 3)),
            onPressed: () => Get.toNamed('/work/materials'),
            child: const Text('المواد', style: TextStyle(color: background, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class SearchTasks extends StatefulWidget {
  const SearchTasks({super.key});

  @override
  State<SearchTasks> createState() => _SearchTasksState();
}

class _SearchTasksState extends State<SearchTasks> {
  String? _selectedLevel;
  var c = Get.find<MainController>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    WorkData.getCurriculums(jwtToken: c.user.value.jwtToken);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      WorkData.getCurriculums(jwtToken: c.user.value.jwtToken);
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Obx(() {
        List<Curriculum> currics = c.tasks.value.curriculums;

        final levelValues = currics.map((cur) => cur.level).toSet().toList()..sort();

        final filteredCurrics = _selectedLevel == null ? currics : currics.where((cur) => cur.level == _selectedLevel).toList();

        List<TableRow> rows = [
          const TableRow(
            decoration: BoxDecoration(color: background),
            children: [
              AppTableCell(text: 'الاسم', isHead: true),
              AppTableCell(text: 'المرحلة الدراسية', isHead: true),
              AppTableCell(text: 'نسبة الاكتمال', isHead: true),
              AppTableCell(text: 'العملية', isHead: true),
            ],
          ),
        ];

        for (var i = 0; i < filteredCurrics.length; i++) {
          rows.add(TableRow(
            decoration: BoxDecoration(color: i.isEven ? componentBackground : const Color(0xFFEBECEE)),
            children: [
              AppTableCell(text: filteredCurrics[i].name),
              AppTableCell(text: filteredCurrics[i].level),
              AppTableCell(text: '${filteredCurrics[i].completedPercent} %'),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: TextButton(
                    onPressed: () => Get.toNamed('/work/materials/${filteredCurrics[i].id}'),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ).merge(deepBlueBtnStyle),
                    child: const Text('اختيار', style: TextStyle(color: componentBackground)),
                  ),
                ),
              ),
            ],
          ));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('اختر المادة التي ترغبها'),
                DropdownButton<String>(
                  value: _selectedLevel,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل', style: TextStyle(fontSize: 12))),
                    for (var lv in levelValues)
                      DropdownMenuItem(
                        value: lv,
                        child: Text(lv, style: const TextStyle(fontSize: 12)),
                      ),
                  ],
                  onChanged: (val) => setState(() => _selectedLevel = val),
                )
              ],
            ),
            Table(
              border: const TableBorder(
                top: BorderSide(color: background, width: 2),
                bottom: BorderSide(color: background, width: 1),
                left: BorderSide(color: background, width: 1),
                right: BorderSide(color: background, width: 1),
                horizontalInside: BorderSide(color: background, width: 1),
                verticalInside: BorderSide(color: background, width: 1),
              ),
              columnWidths: const {0: FlexColumnWidth(4), 1: FlexColumnWidth(4), 2: FlexColumnWidth(3), 3: FixedColumnWidth(75)},
              children: rows,
            ),
          ],
        );
      }),
    );
  }
}
