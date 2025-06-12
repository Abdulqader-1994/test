import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller.dart';
import '../model/edit_note.dart';
import '../model/part.dart';
import '../util/line_painter.dart';
import 'rich_text_editor.dart';

class PartEditor extends StatelessWidget {
  final String partId;
  final List<List> treeColors;
  final EditNote? note;
  const PartEditor({super.key, required this.partId, required this.treeColors, this.note});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EntidioController>(
      id: partId,
      builder: (c) {
        bool exist = c.notes.where((el) => el.partId == partId).isNotEmpty;

        List<EditNote> uniqeIDs = [];
        for (var note in c.notes) {
          var notExist = uniqeIDs.where((el) => el.partId == note.partId).isEmpty;
          if (notExist) uniqeIDs.add(note);
        }

        Part part;
        if (note != null) {
          part = note!.content.where((el) => el.id == partId).first;
        } else {
          part = c.lesson.content.where((el) => el.id == partId).first;
        }

        return Row(
          children: [
            Expanded(
              child: CustomPaint(
                willChange: true,
                isComplex: true,
                painter: AppBorder(part: part, treeColors: treeColors, isRtl: c.lesson.isRTL),
                child: Container(
                  margin: EdgeInsets.only(
                    right: c.lesson.isRTL ? (treeColors.length - 1) * 20 + 10 + 3 : 0,
                    left: !c.lesson.isRTL ? (treeColors.length - 1) * 20 + 10 + 3 : 0,
                    bottom: 3,
                  ),
                  child: RichTextEditor(controller: part.contentEditor, part: part, note: note),
                ),
              ),
            ),
            if ((c.verify || c.check) && exist)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Text((uniqeIDs.indexWhere((el) => el.partId == part.id) + 1).toString(), style: TextStyle(color: Colors.grey)),
                    Icon(Icons.sticky_note_2, color: Colors.grey),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
