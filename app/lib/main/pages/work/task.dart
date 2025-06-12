import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../component/main_widget.dart';
import '../../utils/app_vars.dart';
import '../../model/workdata.dart';
import '../../utils/btn_style.dart';
import '../../main_controller.dart';

class Tasks extends StatelessWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainWidget(
      page: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [HeaderRouter(), ActiveTask()],
      ),
    );
  }
}

class HeaderRouter extends GetView<MainController> {
  const HeaderRouter({super.key});

  @override
  Widget build(BuildContext context) {
    String? id = Get.parameters['material'];
    var currics = controller.tasks.value.curriculums.where((el) => el.id.toString() == id);
    if (currics.isEmpty) return const Center(child: Text('الرجاء العودة واختيار المادة مرة أخرى'));

    Curriculum c = currics.toList()[0];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: componentBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Wrap(
        spacing: 3,
        crossAxisAlignment: WrapCrossAlignment.center,
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
          const RotatedBox(quarterTurns: 2, child: Icon(Icons.double_arrow)),
          TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 3)),
            onPressed: () => Get.toNamed('/work/materials/$id'),
            child: Text(c.name, style: const TextStyle(color: background, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class ActiveTask extends StatefulWidget {
  const ActiveTask({super.key});

  @override
  State<ActiveTask> createState() => _ActiveTaskState();
}

class _ActiveTaskState extends State<ActiveTask> {
  var c = Get.find<MainController>();
  bool loading = false;

  void fetchData() async {
    String? id = Get.parameters['material'];
    var currics = c.tasks.value.curriculums.where((el) => el.id.toString() == id);
    if (currics.isEmpty) {
      await Get.toNamed('/work/materials');
      return;
    }

    await WorkData.getActiveTasks(jwtToken: c.user.value.jwtToken, curriculumId: currics.first.id);
    setState(() => loading = false);
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(
          child: Column(
            spacing: 20,
            children: [
              CircularProgressIndicator(color: background),
              Text('جاري جلب المعلومات'),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      var tasks = c.tasks.value.activeTasks;

      List<Widget> childs = [];
      for (var el in tasks) {
        childs.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: componentBackground,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Row(children: [
                      const Text('المهمة : ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Flexible(child: Text(el.taskName)),
                    ]),
                    Row(children: [
                      const Text('وقت المهمة : ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Flexible(child: Text('${el.shares} دقيقة')),
                    ]),
                    Row(children: [
                      const Text('مدة الحجز : ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Flexible(child: Text('${el.shares * 3} دقيقة')),
                    ]),
                  ],
                ),
              ),
              Column(
                spacing: 5,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      MainController c = Get.find<MainController>();
                      var currics = c.tasks.value.curriculums.where((el) => el.id.toString() == Get.parameters['material']).toList();
                      if (currics.isEmpty) {
                        Get.toNamed('/work/materials');
                        return;
                      }

                      Curriculum curric = currics.toList()[0];

                      await WorkData.doTask(task: el, curriculum: curric);
                    },
                    style: deepBlueBtnStyle.copyWith(
                      shape: WidgetStatePropertyAll(BeveledRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      padding: const WidgetStatePropertyAll(EdgeInsets.all(20)),
                    ),
                    child: const Text(
                      'ابدأ بالمهمة',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: componentBackground),
                    ),
                  ),
                  if (el.occupied == c.user.value.id && el.occupiedTime != null) TaskTimer(startTime: el.occupiedTime!, shares: el.shares),
                ],
              ),
            ],
          ),
        ));
      }

      if (childs.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text('للأسف لا يوجد أي مهمة لعرضها الآن، الرجاء المحاولة لاحقاً أو اختيار مادة أخرى'),
          ),
        );
      } else {
        return Column(mainAxisSize: MainAxisSize.min, children: childs);
      }
    });
  }
}

class TaskTimer extends StatefulWidget {
  final int startTime;
  final int shares;

  const TaskTimer({super.key, required this.startTime, required this.shares});

  @override
  State<TaskTimer> createState() => _TaskTimerState();
}

class _TaskTimerState extends State<TaskTimer> {
  late Stream<int> timerStream;

  @override
  void initState() {
    super.initState();
    timerStream = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now().millisecondsSinceEpoch);
  }

  String formatElapsedTime(Duration elapsed) {
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: timerStream,
      builder: (context, snapshot) {
        final int reservedTime = widget.shares * 3 * 60 * 1000;
        final int endTime = widget.startTime + reservedTime;
        final int remainingMillis = endTime - DateTime.now().millisecondsSinceEpoch;
        final Duration remaining = Duration(milliseconds: remainingMillis > 0 ? remainingMillis : 0);

        return SizedBox(
          width: 90,
          child: Text(
            'المدة الباقية للحجز ${formatElapsedTime(remaining)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
