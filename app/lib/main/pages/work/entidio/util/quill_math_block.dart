import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller.dart';

class MathBlock extends CustomBlockEmbed {
  static const String noteType = 'myMath';

  const MathBlock(String value) : super(noteType, value);

  static MathBlock fromLatex(String latex) => MathBlock(latex);

  String get latex => data;
}

class MathBlockBuilder extends EmbedBuilder {
  @override
  String get key => MathBlock.noteType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final String latex = embedContext.node.value.data;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(onTap: () => Get.dialog(MathEditor(latex: latex, offset: embedContext.node.offset)), child: MathViewer(result: latex)),
        ),
      ),
    );
  }
}

class MathEditor extends StatefulWidget {
  final String? latex;
  final int? offset;
  const MathEditor({super.key, this.latex, this.offset});

  @override
  State<MathEditor> createState() => _MathEditorState();
}

class _MathEditorState extends State<MathEditor> {
  String result = '';
  ScrollController scroll = ScrollController();
  EntidioController c = Get.find<EntidioController>();

  @override
  void initState() {
    result = widget.latex ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.latex == null ? 'إنشاء المعادلة' : 'تعديل المعادلة',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      !await launchUrl(Uri.parse('https://www.imatheq.com/imatheq/com/imatheq/math-equation-editor-latex-mathml.html'));
                    },
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text('فتح المحرر'),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Center(
                    child: TextFormField(
                      initialValue: result,
                      onChanged: (val) => setState(() => result = val),
                      maxLines: null,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blueGrey[700],
                        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.blueGrey[700]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.blueGrey[700]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.blueGrey[700]!)),
                      ),
                    ),
                  ),
                ),
                if (result.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text('الـنـتـيـجـة', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                if (result.isNotEmpty)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor: WidgetStateProperty.all(Colors.blueGrey[400]),
                        trackColor: WidgetStateProperty.all(Colors.grey[300]),
                        trackVisibility: WidgetStateProperty.all(true),
                      ),
                      child: Scrollbar(
                        controller: scroll,
                        thumbVisibility: true,
                        thickness: 7.0,
                        child: SingleChildScrollView(
                          controller: scroll,
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MathViewer(result: result),
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(backgroundColor: Colors.white), child: const Text('الرجوع')),
                      TextButton(
                        onPressed: () {
                          if (result.isEmpty) {
                            Get.back();
                            return;
                          }
                          final block = MathBlock(result);

                          if (widget.offset != null) {
                            // Editing an existing block
                            final index = widget.offset!;
                            const length = 1; // Embeds are represented by a single character
                            c.editor.replaceText(index, length, block, TextSelection.collapsed(offset: index + 1));
                          } else {
                            // Creating a new block
                            final index = c.editor.selection.baseOffset;
                            final length = c.editor.selection.extentOffset - index;
                            c.editor.replaceText(index, length, block, TextSelection.collapsed(offset: index + 1));
                          }

                          Get.back();
                        },
                        style: TextButton.styleFrom(backgroundColor: Colors.white),
                        child: const Text('موافق'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MathViewer extends StatelessWidget {
  final String result;
  const MathViewer({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      result,
      mathStyle: MathStyle.text,
      textStyle: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'El Messiri'),
      onErrorFallback: (FlutterMathException e) {
        return const Text('Error rendering Math', style: TextStyle(color: Colors.red));
      },
    );
  }
}
