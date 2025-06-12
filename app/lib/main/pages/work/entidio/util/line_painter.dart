import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller.dart';
import '../model/part.dart';

class AppBorder extends CustomPainter {
  final bool isRtl;
  final List<List> treeColors;
  final Part part;
  final c = Get.find<EntidioController>();

  AppBorder({super.repaint, required this.part, required this.treeColors, required this.isRtl});

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < treeColors.length; i++) {
      Part? parent = c.lesson.content.where((el) => el.id == part.parentId).firstOrNull;
      bool isArrow = parent != null && parent.decor == ContentDecor.normal && part.childrenIDs.isNotEmpty;

      // part.parent == null mean the part is the lesson title
      if (isArrow || (parent == null && part.childrenIDs.isNotEmpty)) {
        Path path = Path();
        if (isRtl) {
          path.moveTo(size.width - ((treeColors.length - 1) * 20) - 10, (size.height / 2) - 5);
          path.lineTo(size.width - ((treeColors.length - 1) * 20), (size.height / 2) - 5);
          path.lineTo(size.width - ((treeColors.length - 1) * 20) - 5, (size.height / 2) + 3);
        } else {
          path.moveTo(((treeColors.length - 1) * 20) - 10, (size.height / 2) - 5);
          path.lineTo(((treeColors.length - 1) * 20), (size.height / 2) - 5);
          path.lineTo(((treeColors.length - 1) * 20) - 5, (size.height / 2) + 3);
        }
        path.close();
        var p = Paint();
        p.color = Color(part.trColor);
        p.style = PaintingStyle.fill;
        canvas.drawPath(path, p);
      }

      // draw circle
      if (parent != null && parent.decor == ContentDecor.bullet) {
        var p = Paint()..color = Color(parent.trColor);
        p.style = PaintingStyle.fill;
        isRtl
            ? canvas.drawCircle(Offset(size.width - ((treeColors.length - 1) * 20) - 5, (size.height / 2)), 5, p)
            : canvas.drawCircle(Offset(((treeColors.length - 1) * 20) - 5, (size.height / 2)), 5, p);
      }

      // draw text
      if (parent != null && parent.decor == ContentDecor.numeric) {
        final textSpan = TextSpan(text: (parent.childrenIDs.indexOf(part.id) + 1).toString(), style: TextStyle(color: Color(parent.trColor), fontSize: 18));
        final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout();

        isRtl
            ? textPainter.paint(canvas, Offset(size.width - ((treeColors.length - 1) * 20) - 10, (size.height / 2) - 12))
            : textPainter.paint(canvas, Offset(((treeColors.length - 1) * 20) - 5, (size.height / 2)));
      }

      // draw vertical lines
      if (treeColors[i][1].contains(part.id)) {
        double hStart = 0;
        double hEnd = size.height;

        if (treeColors[i][1].first == part.id) hStart = (size.height / 2) + 10;
        if (treeColors[i][1].last == part.id) hEnd = (size.height / 2);

        Offset start, end;

        if (isRtl) {
          start = Offset(size.width - (i * 20) - 5, hStart);
          end = Offset(size.width - (i * 20) - 5, hEnd);
        } else {
          start = Offset((i * 20) - 5, hStart);
          end = Offset((i * 20) - 5, hEnd);
        }

        canvas.drawLine(start, end, Paint()..color = Color(treeColors[i][0]));
      }

      // draw horizental lines
      if (treeColors[i][2].contains(part.id)) {
        Offset start, end;
        if (isRtl) {
          start = Offset(size.width - (i * 20) - 17, size.height / 2);
          end = Offset(size.width - (i * 20) - 5, size.height / 2);
        } else {
          start = Offset((i * 20) - 5, size.height / 2);
          end = Offset((i * 20) + 7, size.height / 2);
        }

        canvas.drawLine(start, end, Paint()..color = Color(treeColors[i][0]));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
