import 'package:flutter/material.dart';
import '../utils/app_vars.dart';

class AppTableCell extends StatelessWidget {
  final String text;
  final bool isHead;
  final Color? color;
  const AppTableCell({super.key, required this.text, this.isHead = false, this.color});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: isHead ? const TextStyle(color: componentBackground) : TextStyle(color: color),
        ),
      ),
    );
  }
}
