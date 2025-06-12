import 'component/question.dart';
import 'component/bottom_bar.dart';
import 'component/lesson_header.dart';
import 'component/part_editor.dart';
import 'controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'model/edit_note.dart';
import 'model/map.dart';

class Entidio extends StatelessWidget {
  const Entidio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      bottomNavigationBar: const BottomBar(),
      body: Center(child: GetBuilder<EntidioController>(id: 'updateView', builder: (c) => c.viewMode ? ViewerContent(c: c) : const EditorContent())),
    );
  }
}

class EditorContent extends StatelessWidget {
  const EditorContent({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scroll = ScrollController();

    return Container(
      height: double.infinity,
      color: Colors.blueGrey[800],
      width: 900,
      child: GetBuilder<EntidioController>(
        id: 'all',
        builder: (c) {
          List<Widget> childs = [WorkInfo(), Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Divider()), LessonHeader(lesson: c.lesson)];

          childs.addAll(buildParts([c.lesson.map], [], 'edit', null));

          if (c.lesson.questions.isNotEmpty) {
            childs.addAll([
              Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Divider()),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Text('أسئلة الدرس', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(10, 0, 10, 10), child: QuestionContent(c: c)),
            ]);
          }

          childs.addAll([Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Divider()), EditorNotes(), WorkSubmit()]);

          return Directionality(
            textDirection: (c.lesson.isRTL) ? TextDirection.rtl : TextDirection.ltr,
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                mainAxisMargin: 2,
                thumbColor: WidgetStateProperty.all(Colors.blueGrey[400]),
                trackColor: WidgetStateProperty.all(Colors.grey[300]),
                trackVisibility: WidgetStateProperty.all(true),
              ),
              child: Scrollbar(
                controller: scroll,
                thumbVisibility: true,
                thickness: 7.0,
                radius: const Radius.circular(4.0),
                child: SingleChildScrollView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: childs),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ViewerContent extends StatelessWidget {
  final EntidioController c;
  const ViewerContent({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    List<Widget> childs = [LessonHeader(lesson: c.lesson)];
    childs.addAll(buildParts([c.lesson.map], [], 'view', null));

    return Container(
      height: double.infinity,
      color: Colors.blueGrey[800],
      width: 900,
      child: Directionality(
        textDirection: (c.lesson.isRTL) ? TextDirection.rtl : TextDirection.ltr,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(Colors.blueGrey[400]),
            trackColor: WidgetStateProperty.all(Colors.grey[300]),
            trackVisibility: WidgetStateProperty.all(true),
          ),
          child: Scrollbar(
            controller: c.scroll,
            thumbVisibility: true,
            thickness: 7.0,
            radius: const Radius.circular(4.0),
            child: SingleChildScrollView(
              controller: c.scroll,
              child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: childs)),
            ),
          ),
        ),
      ),
    );
  }
}

class WorkInfo extends StatefulWidget {
  const WorkInfo({super.key});

  @override
  State<WorkInfo> createState() => _WorkInfoState();
}

class _WorkInfoState extends State<WorkInfo> {
  final c = Get.find<EntidioController>();
  late Stream<int> timerStream;

  @override
  void initState() {
    timerStream = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now().millisecondsSinceEpoch);
    super.initState();
  }

  String formatElapsedTime(Duration elapsed) {
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    //TODO: create event handler where user exceed the reserved time
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(color: Colors.blueGrey[600], borderRadius: BorderRadius.circular(13)),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'El Messiri'),
        child: Column(
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('المهمة', style: TextStyle(fontWeight: FontWeight.bold)), Text(c.taskName, textAlign: TextAlign.center)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('الأسهم', style: TextStyle(fontWeight: FontWeight.bold)), Text('${c.shares} دقيقة', textAlign: TextAlign.center)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مدة الحجز', style: TextStyle(fontWeight: FontWeight.bold)),
                StreamBuilder<int>(
                  stream: timerStream,
                  builder: (context, snapshot) {
                    final int startTime = c.time;
                    final int reservedTime = c.shares * 3 * 60 * 1000; // in milli secound
                    final int endTime = startTime + reservedTime;
                    final int remainingMillis = endTime - DateTime.now().millisecondsSinceEpoch;
                    final Duration remaining = Duration(milliseconds: remainingMillis > 0 ? remainingMillis : 0);

                    return Text(formatElapsedTime(remaining), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WorkSubmit extends GetView<EntidioController> {
  const WorkSubmit({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(7),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.blueGrey[600], borderRadius: BorderRadius.circular(13)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: controller.goBack,
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.all(10)),
              backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) return Colors.green.withValues(alpha: 0.8);
                if (states.contains(WidgetState.pressed)) return Colors.green.withValues(alpha: 0.7);
                return Colors.green;
              }),
            ),
            icon: Icon(Icons.undo, color: Colors.white),
            label: Text('الرجوع للخلف', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              // taskType 0 mean only map is needed (task name: get index)
              if (controller.taskType == 0) controller.lesson.map.setTitle(controller.lesson.map, controller.lesson.content);
              controller.submitTask();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('إرسال المهمة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class EditorNotes extends StatelessWidget {
  const EditorNotes({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EntidioController>();

    List<Widget> childs = [];
    for (var el in c.notes) {
      childs.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(color: Colors.blueGrey[600]!.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(13)),
          child: Column(
            spacing: 5,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التعديل رقم ${c.notes.indexOf(el) + 1} ${c.check ? 'للمستخدم رقم ${c.userId}' : ''}',
                      style: TextStyle(color: Colors.amberAccent, fontSize: 17),
                    ),
                    if (el.userId == c.userId) IconButton(onPressed: () => c.deleteNote(note: el), icon: Icon(Icons.delete, color: Colors.amberAccent)),
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.only(left: 10), child: Column(children: buildParts([el.map], [], 'edit', el))),
            ],
          ),
        ),
      );
    }

    if (childs.isNotEmpty) {
      childs.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            spacing: 5,
            children: [Icon(Icons.chat, color: Colors.yellow, size: 24), Text('التعديلات المقترحة', style: TextStyle(color: Colors.yellow, fontSize: 20))],
          ),
        ),
      );
    }

    return Column(children: childs);
  }
}

List<Widget> buildParts(List<LessonMap> parts, List<List> treeColors, String type, EditNote? note) {
  List<Widget> widgets = [];

  for (var part in parts) {
    List<List> currentTreeColors = List.from(treeColors);
    List<String> horizentalIds = part.children.map((el) => el.id).toList();

    List<String> verticalIds = [];
    if (part.children.isNotEmpty) verticalIds = getIds(part);

    currentTreeColors.add([part.trColor, verticalIds, horizentalIds]);

    /* if (type == 'view') widgets.add(PartBuilder(partId: part.id, treeColors: currentTreeColors)); */
    if (type == 'edit') widgets.add(PartEditor(partId: part.id, treeColors: currentTreeColors));
    if (part.children.isNotEmpty) widgets.addAll(buildParts(part.children, currentTreeColors, type, note));
  }

  return widgets;
}

List<String> getIds(LessonMap line) {
  List<String> ids = [line.id];

  String stopId = line.children.last.id;

  bool traverse(List<LessonMap> lines) {
    for (var line in lines) {
      ids.add(line.id);
      if (stopId == line.id) return true; // Stop traversal
      if (line.children.isNotEmpty) {
        bool found = traverse(line.children);
        if (found) return true; // Stop traversal
      }
    }
    return false; // Continue traversal
  }

  traverse(line.children);

  return ids;
}
