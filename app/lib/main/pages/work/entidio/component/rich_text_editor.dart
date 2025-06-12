import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import '../controller.dart';
import '../model/edit_note.dart';
import '../model/part.dart';
import '../util/quill_image_block.dart';
import '../util/quill_math_block.dart';

class RichTextEditor extends StatelessWidget {
  final Part part;
  final QuillController controller;
  final EditNote? note;
  const RichTextEditor({super.key, required this.part, required this.controller, this.note});

  @override
  Widget build(BuildContext context) {
    var decor = BoxDecoration(
      color: Colors.blueGrey[600],
      boxShadow: [BoxShadow(offset: const Offset(1, 1), color: Colors.blueGrey[600]!.withValues(alpha: 0.5), spreadRadius: 3, blurRadius: 3)],
    );

    return GetBuilder<EntidioController>(
      id: part.id,
      builder: (c) {
        return Focus(
          onFocusChange: (focused) {
            if (!focused) return;
            c.setPart(part: part);
            c.setEditor(c: controller, note: note);
          },
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              decoration: c.selectedPart != part ? BoxDecoration(color: Color(part.partColor)) : decor,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              child: TextSelectionTheme(
                data: const TextSelectionThemeData(cursorColor: Colors.white),
                child: QuillEditor.basic(
                  controller: controller,
                  config: QuillEditorConfig(
                    scrollable: false,
                    expands: false,
                    placeholder: ' أضف نصاً هنا',
                    disableClipboard: true,
                    //clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: false),
                    embedBuilders: [ImageBlockBuilder(), MathBlockBuilder()],
                    customStyles: DefaultStyles(
                      placeHolder: DefaultTextBlockStyle(
                        TextStyle(fontSize: 16, color: Colors.grey[200]!, fontFamily: 'El Messiri'),
                        const HorizontalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                      paragraph: const DefaultTextBlockStyle(
                        TextStyle(color: Colors.white, fontFamily: 'El Messiri'),
                        HorizontalSpacing(0, 0),
                        VerticalSpacing(0, 0),
                        VerticalSpacing(0, 0),
                        null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
