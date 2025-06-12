import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import '../controller.dart';

class ImageBlock extends CustomBlockEmbed {
  static const String noteType = 'myImage';

  const ImageBlock(String value) : super(noteType, value);

  static ImageBlock fromBase64({required String base64Data, required int width, required double ratio}) {
    Map<String, dynamic> data = {'base64': base64Data, 'width': width, 'ratio': ratio, 'align': 'center'};
    return ImageBlock(jsonEncode(data));
  }

  String get base64Data {
    Map<String, dynamic> dataMap = jsonDecode(data);
    return dataMap['base64'];
  }

  int get maxWidth {
    Map<String, dynamic> dataMap = jsonDecode(data);
    return dataMap['width'];
  }

  int get ratio {
    Map<String, dynamic> dataMap = jsonDecode(data);
    return dataMap['ratio'];
  }

  Alignment get align {
    Map<String, dynamic> dataMap = jsonDecode(data);
    Alignment align = Alignment.center;
    if (dataMap['align'] == 'left') align = Alignment.centerLeft;
    if (dataMap['align'] == 'right') align = Alignment.centerRight;
    return align;
  }
}

class ImageBlockBuilder extends EmbedBuilder {
  @override
  String get key => ImageBlock.noteType;

  final Map<String, Uint8List> _imageCache = {};

  EntidioController c = Get.find<EntidioController>();

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final String dataString = embedContext.node.value.data;

    Map<String, dynamic> data = jsonDecode(dataString);

    Alignment align = Alignment.center;
    if (data['align'] == 'left') align = Alignment.centerLeft;
    if (data['align'] == 'right') align = Alignment.centerRight;

    Uint8List imageBytes = _imageCache.putIfAbsent(data['base64'], () => base64Decode(data['base64']));

    int offset = embedContext.controller.selection.baseOffset;
    bool inRange = !embedContext.readOnly && embedContext.node.documentOffset == offset;
    if (!inRange) offset--;
    inRange = !embedContext.readOnly && embedContext.node.documentOffset == offset;

    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (inRange)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 5,
                runSpacing: 5,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      onPressed: () {
                        c.editor.document.delete(offset, 1);
                        c.update([c.selectedPart!.id]);
                      },
                      icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                        backgroundColor: Colors.blueGrey[900],
                        hoverColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      onPressed: () => c.updateImageProp(type: 'width', value: data['width'] + 10),
                      icon: const Icon(Icons.add, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                        backgroundColor: Colors.blueGrey[900],
                        hoverColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      onPressed: () => c.updateImageProp(type: 'width', value: data['width'] - 10),
                      icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                        backgroundColor: Colors.blueGrey[900],
                        hoverColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      onPressed: () => c.updateImageProp(type: 'align', value: 'left'),
                      icon: const Icon(Icons.format_align_left, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                        backgroundColor: align == Alignment.centerLeft ? Colors.blue : Colors.blueGrey[900],
                        hoverColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      onPressed: () => c.updateImageProp(type: 'align', value: 'center'),
                      icon: const Icon(Icons.format_align_center, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                        backgroundColor: align == Alignment.center ? Colors.blue : Colors.blueGrey[900],
                        hoverColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      onPressed: () => c.updateImageProp(type: 'align', value: 'right'),
                      icon: const Icon(Icons.format_align_right, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                        backgroundColor: align == Alignment.centerRight ? Colors.blue : Colors.blueGrey[900],
                        hoverColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(border: inRange ? Border.all(color: Colors.blue[300]!, width: 3) : null),
            width: data['width'] * 1.0,
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                Get.dialog(
                  Material(
                    color: Colors.black,
                    child: Stack(
                      children: [
                        Positioned.fill(child: InteractiveViewer(minScale: 0.5, maxScale: 5, child: Image.memory(imageBytes))),
                        Positioned(
                          right: 20,
                          top: 20,
                          child: IconButton(
                            onPressed: Get.back,
                            style: IconButton.styleFrom(backgroundColor: Colors.white),
                            icon: const Icon(Icons.close, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: AspectRatio(aspectRatio: data['ratio'], child: Image.memory(imageBytes, fit: BoxFit.fill)),
            ),
          ),
        ],
      ),
    );
  }
}
