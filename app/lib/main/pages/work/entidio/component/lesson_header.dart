import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller.dart';
import '../model/lesson.dart';

class LessonHeader extends GetView<EntidioController> {
  final Lesson lesson;
  const LessonHeader({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Wrap(
              spacing: 2,
              runSpacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(lesson.year, style: const TextStyle(color: Colors.black)),
                const RotatedBox(quarterTurns: 2, child: Icon(Icons.double_arrow, size: 20)),
                Text(lesson.term, style: const TextStyle(color: Colors.black)),
                const RotatedBox(quarterTurns: 2, child: Icon(Icons.double_arrow, size: 20)),
                Text(lesson.subject, style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
          ViewModeBtn(isRtl: lesson.isRTL),
        ],
      ),
    );
  }
}

class ViewModeBtn extends StatefulWidget {
  final bool isRtl;
  const ViewModeBtn({super.key, required this.isRtl});

  @override
  State<ViewModeBtn> createState() => _ViewModeBtnState();
}

class _ViewModeBtnState extends State<ViewModeBtn> {
  EntidioController c = Get.find<EntidioController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => c.setLessonDir(isRTL: true),
            child: Icon(Icons.format_textdirection_r_to_l_outlined, color: widget.isRtl ? Colors.blue : Colors.black),
          ),
        ),
        Container(margin: const EdgeInsets.symmetric(horizontal: 5), color: Colors.black, width: 3, height: 25),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => c.setLessonDir(isRTL: false),
            child: Icon(Icons.format_textdirection_l_to_r_outlined, color: !widget.isRtl ? Colors.blue : Colors.black),
          ),
        ),
        Container(margin: const EdgeInsets.symmetric(horizontal: 5), color: Colors.black, width: 3, height: 25),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(onTap: () => c.setViewMode(), child: c.viewMode ? const Icon(Icons.edit) : const Icon(Icons.visibility)),
        ),
      ],
    );
  }
}
