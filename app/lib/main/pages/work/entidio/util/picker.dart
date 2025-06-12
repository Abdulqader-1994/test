import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import '../controller.dart';
import 'quill_image_block.dart';
import 'show_error.dart';
import 'package:image/image.dart' as img;

class AppPicker {
  static void pickColor({required BuildContext context, required String k}) {
    String txt = '';
    if (k == 'bgColor') txt = 'Pick font color';
    if (k == 'partColor') txt = 'Pick part background color';
    if (k == 'color') txt = 'Pick background color';
    if (k == 'trColor') txt = 'Pick tree node color';
    if (k == 'textColor') txt = 'Pick text color';

    final EntidioController c = Get.find<EntidioController>();

    Get.defaultDialog(
      backgroundColor: Colors.blueGrey[800],
      title: txt,
      titleStyle: const TextStyle(color: Colors.white),
      content: Flexible(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 310,
                child: TextFieldTapRegion(
                  child: ColorPicker(
                    onColorChanged: (Color color) {
                      final String hexColor = '#${color.hexAlpha.substring(2)}';
                      if (k == 'bgColor') c.editor.formatSelection(BackgroundAttribute(hexColor));
                      if (k == 'textColor') {
                        c.editor.formatSelection(ColorAttribute(hexColor));
                      }
                      if (k == 'trColor' || k == 'partColor') c.setPropColor(value: color.toARGB32(), type: k);
                    },
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
                    subheading: const Column(children: [Divider(), Text('Select color shade', style: TextStyle(color: Colors.white, fontSize: 25))]),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: k != 'trColor' ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                children: [
                  if (k != 'trColor')
                    ElevatedButton(
                      onPressed: () {
                        if (k == 'bgColor') c.editor.formatSelection(const BackgroundAttribute(null));
                        if (k == 'textColor') c.editor.formatSelection(const ColorAttribute(null));
                        if (k == 'partColor') c.setPropColor(value: 0, type: k);
                        Get.back();
                      },
                      style: TextButton.styleFrom(backgroundColor: Colors.blueGrey[600], elevation: 0),
                      child: const Text('Remove Color', style: TextStyle(color: Colors.white)),
                    ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(backgroundColor: Colors.blueGrey[600], elevation: 0),
                    child: const Text('Submit', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void pickImage(EntidioController controller) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    PlatformFile file = result.files.first;
    Uint8List? bytes = file.bytes;

    if (!GetPlatform.isWeb) {
      File localFile = File(file.path!);
      bytes = await localFile.readAsBytes();
    }

    if (bytes == null) {
      showErrorMsg(text: 'Error occurred when picking image', func: () => {});
      return;
    }

    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      showErrorMsg(text: 'Error occurred when decoding image', func: () => {});
      return;
    }

    int w = image.width.toInt();
    double r = w / image.height.toInt();

    while (w > 900) {
      w = (w * 0.9).floor();
    }

    Uint8List compressedBytes = img.encodeJpg(image, quality: 75);

    String src = base64Encode(compressedBytes);

    final block = ImageBlock.fromBase64(base64Data: src, width: w, ratio: r.toPrecision(3));

    final index = controller.editor.selection.baseOffset;
    final length = controller.editor.selection.extentOffset - index;

    controller.editor.replaceText(index, length, block, TextSelection.collapsed(offset: index + 1));
  }
}
