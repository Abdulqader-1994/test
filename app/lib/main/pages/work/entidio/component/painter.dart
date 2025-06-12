import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import '../controller.dart';
import '../util/quill_image_block.dart';
import '../util/show_error.dart';

class Painter extends StatefulWidget {
  const Painter({super.key});

  @override
  State<Painter> createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  EntidioController data = Get.find<EntidioController>();
  ui.Image? backgroundImage;
  late PainterController controller;
  Color textColor = Colors.black;
  FocusNode textFocusNode = FocusNode();
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: PainterSettings(
        text: TextSettings(focusNode: textFocusNode, textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
        freeStyle: const FreeStyleSettings(color: Colors.red, strokeWidth: 5),
        shape: ShapeSettings(paint: shapePaint),
        scale: const ScaleSettings(enabled: true, minScale: 1, maxScale: 5),
      ),
    );
    textFocusNode.addListener(onFocus);
  }

  @override
  void dispose() {
    textFocusNode.dispose();
    super.dispose();
  }

  void onFocus() {
    setState(() {});
  }

  void removeSelectedDrawable() {
    if (controller.selectedObjectDrawable == null) return;
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) controller.removeDrawable(selectedDrawable);
  }

  void flipSelectedImage() {
    if (controller.selectedObjectDrawable == null || controller.selectedObjectDrawable is! ImageDrawable) return;
    final imageDrawable = controller.selectedObjectDrawable as ImageDrawable;
    controller.replaceDrawable(imageDrawable, imageDrawable.copyWith(flipped: !imageDrawable.flipped));
  }

  void setBackgroundImage() async {
    Uint8List? img = await getImageBytes(800);
    if (img == null) return;
    final ui.Image image = await decodeImageFromList(img);
    setState(() {
      backgroundImage = image;
      controller.background = image.backgroundDrawable;
    });
  }

  Future<void> addImage() async {
    Uint8List? img = await getImageBytes(500);
    if (img == null) return;
    final ui.Image image = await decodeImageFromList(img);
    controller.addImage(image);
  }

  void renderAndDisplayImage() async {
    if (backgroundImage == null) {
      // Create an empty transparent image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = Colors.transparent;
      canvas.drawRect(Rect.fromLTWH(0, 0, 800.toDouble(), 500.toDouble()), paint);
      final picture = recorder.endRecording();
      backgroundImage = await picture.toImage(800, 500);
      controller.background = backgroundImage!.backgroundDrawable;
    }

    final backgroundImageSize = Size(backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());
    final ui.Image renderedImage = await controller.renderImage(backgroundImageSize);
    final pngBytes = await renderedImage.pngBytes;
    if (pngBytes == null) {
      Get.back();
      return;
    }

    String src = base64Encode(pngBytes);
    final block = ImageBlock.fromBase64(base64Data: src, width: 800, ratio: (800 / 500).toPrecision(3));
    final index = data.editor.selection.baseOffset;
    final length = data.editor.selection.extentOffset - index;
    data.editor.replaceText(index, length, block, TextSelection.collapsed(offset: index + 1));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Container(
          color: Colors.blueGrey[900],
          constraints: const BoxConstraints(minWidth: 400, minHeight: 250, maxWidth: 800, maxHeight: 500),
          child: ValueListenableBuilder<PainterControllerValue>(
            valueListenable: controller,
            builder: (context, _, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: AspectRatio(aspectRatio: 400 / 250, child: Container(color: Colors.blueGrey[800], child: FlutterPainter(controller: controller))),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: setBackgroundImage,
                        icon: const Icon(Icons.wallpaper, color: Colors.white),
                        label: const Text('إضافة خلفية', style: TextStyle(color: Colors.white)),
                      ),
                      // inside image
                      TextButton.icon(
                        onPressed: addImage,
                        icon: const Icon(Icons.photo_camera, color: Colors.white),
                        label: const Text('إضافة صورة', style: TextStyle(color: Colors.white)),
                      ),
                      TextButton.icon(
                        onPressed: flipSelectedImage,
                        icon: const Icon(Icons.flip, color: Colors.white),
                        label: const Text('قلب الصورة', style: TextStyle(color: Colors.white)),
                      ),
                      Container(color: Colors.white, height: 30, width: 3),
                      IconButton(onPressed: controller.addText, icon: const Icon(Icons.text_fields, color: Colors.white)),
                      IconButton(
                        onPressed: () {
                          Get.defaultDialog(
                            backgroundColor: Colors.blueGrey[800],
                            title: 'Pick Text Color',
                            titleStyle: const TextStyle(color: Colors.white),
                            content: Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 310,
                                      child: TextFieldTapRegion(
                                        child: ColorPicker(
                                          onColorChanged: (Color color) => setState(() => textColor = color),
                                          pickersEnabled: const {
                                            ColorPickerType.wheel: true,
                                            ColorPickerType.both: true,
                                            ColorPickerType.primary: false,
                                            ColorPickerType.accent: false,
                                          },
                                          width: 40,
                                          height: 40,
                                          borderRadius: 22,
                                          wheelSquarePadding: 10,
                                          wheelSquareBorderRadius: 20,
                                          subheading: const Column(
                                            children: [Divider(), Text('Select color shade', style: TextStyle(color: Colors.white, fontSize: 25))],
                                          ),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        controller.textSettings = TextSettings(textStyle: controller.textStyle.copyWith(color: textColor));
                                        Get.back();
                                      },
                                      style: TextButton.styleFrom(backgroundColor: Colors.blueGrey[600], elevation: 0),
                                      child: const Text('Submit', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.palette, color: Colors.white),
                      ),
                      Container(color: Colors.white, height: 30, width: 3),
                      IconButton(onPressed: () => Get.dialog(SelectingShape(controller: controller)), icon: const Icon(Icons.shape_line, color: Colors.white)),
                      Container(color: Colors.white, height: 30, width: 3),
                      IconButton(
                        onPressed: () {
                          controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.erase ? FreeStyleMode.erase : FreeStyleMode.none;
                        },
                        icon: Icon(
                          FontAwesomeIcons.eraser,
                          color: controller.freeStyleMode == FreeStyleMode.erase ? Theme.of(context).colorScheme.secondary : Colors.white,
                        ),
                      ),
                      IconButton(onPressed: removeSelectedDrawable, icon: const Icon(Icons.delete, color: Colors.white)),
                      Container(color: Colors.white, height: 30, width: 3),
                      IconButton(onPressed: controller.canUndo ? controller.undo : null, icon: const Icon(Icons.undo, color: Colors.white)),
                      IconButton(onPressed: controller.canRedo ? controller.redo : null, icon: const Icon(Icons.redo, color: Colors.white)),
                      SizedBox(
                        width: 75,
                        height: 25,
                        child: TextButton(
                          onPressed: renderAndDisplayImage,
                          style: TextButton.styleFrom(backgroundColor: Colors.white),
                          child: const Text('موافق'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SelectingShape extends StatefulWidget {
  final PainterController controller;
  const SelectingShape({super.key, required this.controller});

  @override
  State<SelectingShape> createState() => _SelectingShapeState();
}

class _SelectingShapeState extends State<SelectingShape> {
  Color selectedColor = Colors.blue;
  double stroke = 5;
  bool roundBorder = false;
  bool filled = false;

  void setShapeProb() {
    widget.controller.freeStyleSettings = FreeStyleSettings(color: selectedColor, strokeWidth: stroke);
    widget.controller.shapePaint = Paint()
      ..color = selectedColor
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = stroke.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        color: Colors.blueGrey[900],
        padding: const EdgeInsets.all(5),
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose Shape:', style: TextStyle(color: Colors.white, fontSize: 20)),
                SizedBox(
                  width: 240,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.defaultDialog(
                            backgroundColor: Colors.blueGrey[800],
                            title: 'Pick Shape Color',
                            titleStyle: const TextStyle(color: Colors.white),
                            content: Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 310,
                                      child: TextFieldTapRegion(
                                        child: ColorPicker(
                                          onColorChanged: (Color color) => setState(() => selectedColor = color),
                                          pickersEnabled: const {
                                            ColorPickerType.wheel: true,
                                            ColorPickerType.both: true,
                                            ColorPickerType.primary: false,
                                            ColorPickerType.accent: false,
                                          },
                                          width: 40,
                                          height: 40,
                                          borderRadius: 22,
                                          wheelSquarePadding: 10,
                                          wheelSquareBorderRadius: 20,
                                          subheading: const Column(
                                            children: [Divider(), Text('Select color shade', style: TextStyle(color: Colors.white, fontSize: 25))],
                                          ),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Get.back(),
                                      style: TextButton.styleFrom(backgroundColor: Colors.blueGrey[600], elevation: 0),
                                      child: const Text('Submit', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.palette, color: selectedColor),
                      ),
                      IconButton(
                        onPressed: () => setState(() => roundBorder = !roundBorder),
                        icon: Icon(Icons.rounded_corner, color: roundBorder ? Colors.grey[100] : Colors.grey[600]),
                      ),
                      IconButton(
                        onPressed: () => setState(() => filled = !filled),
                        icon: Icon(Icons.contrast, color: filled ? Colors.grey[100] : Colors.grey[600]),
                      ),
                      Container(height: 25, width: 3, color: Colors.white),
                      IconButton(onPressed: () => setState(() => stroke++), icon: const Icon(Icons.add_circle, color: Colors.white)),
                      Text(stroke.toString(), style: const TextStyle(color: Colors.white, fontSize: 20)),
                      IconButton(onPressed: () => stroke > 1 ? setState(() => stroke--) : null, icon: const Icon(Icons.remove_circle, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 240,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setShapeProb();
                          widget.controller.shapeFactory = LineFactory();
                          Get.back();
                        },
                        style: TextButton.styleFrom(backgroundColor: Colors.white, fixedSize: const Size(110, 30), padding: EdgeInsets.zero),
                        icon: const Icon(Icons.show_chart_outlined, color: Colors.blue),
                        label: const Text('Line', style: TextStyle(color: Colors.blue)),
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: () {
                          setShapeProb();
                          widget.controller.shapeFactory = ArrowFactory(arrowHeadSize: stroke * 4);
                          Get.back();
                        },
                        style: TextButton.styleFrom(backgroundColor: Colors.white, fixedSize: const Size(110, 30), padding: EdgeInsets.zero),
                        icon: const Icon(Icons.east, color: Colors.blue),
                        label: const Text('Arrow', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    setShapeProb();
                    widget.controller.shapeFactory = DoubleArrowFactory(arrowHeadSize: stroke * 4);
                    Get.back();
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.white, fixedSize: const Size(230, 30)),
                  icon: const Icon(Icons.show_chart_outlined, color: Colors.blue),
                  label: const Text('Double Arrow', style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 240,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setShapeProb();
                          widget.controller.shapeFactory = RectangleFactory(borderRadius: roundBorder ? BorderRadius.circular(20) : BorderRadius.circular(1));
                          Get.back();
                        },
                        style: TextButton.styleFrom(backgroundColor: Colors.white, fixedSize: const Size(110, 30)),
                        icon: const Icon(Icons.square, color: Colors.blue),
                        label: const Text('Square', style: TextStyle(color: Colors.blue)),
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: () {
                          setShapeProb();
                          widget.controller.shapeFactory = OvalFactory();
                          Get.back();
                        },
                        style: TextButton.styleFrom(backgroundColor: Colors.white, fixedSize: const Size(110, 30)),
                        icon: const Icon(Icons.circle, color: Colors.blue),
                        label: const Text('Circle', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    setShapeProb();
                    widget.controller.freeStyleMode = FreeStyleMode.draw;
                    Get.back();
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.white, fixedSize: const Size(230, 30)),
                  icon: const Icon(Icons.gesture, color: Colors.blue),
                  label: const Text('Free draw', style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text('CLOSE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<Uint8List?> getImageBytes(double imageWidth) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result == null) return null;

  PlatformFile file = result.files.first;
  Uint8List? bytes = file.bytes;

  if (!GetPlatform.isWeb) {
    File localFile = File(file.path!);
    bytes = await localFile.readAsBytes();
  }

  if (bytes == null) {
    showErrorMsg(text: 'Error occurred when picking image', func: () => {});
    return null;
  }

  img.Image? image = img.decodeImage(bytes);
  if (image == null) {
    showErrorMsg(text: 'Error occurred when decoding image', func: () => {});
    return null;
  }

  int w = image.width.toInt();
  int h = image.height.toInt();

  while (w > imageWidth) {
    w = (w * 0.9).floor();
    h = (h * 0.9).floor();
  }

  img.Image? resizedImage = img.copyResize(image, width: w, height: h, interpolation: img.Interpolation.cubic);

  Uint8List compressedBytes = img.encodeJpg(resizedImage, quality: 90);
  return compressedBytes;
}
