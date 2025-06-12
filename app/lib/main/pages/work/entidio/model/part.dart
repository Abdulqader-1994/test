import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import '../util/get_random_color.dart';
import 'package:uuid/uuid.dart';

class Part {
  String id = Uuid().v8();
  String parentId;
  int trColor;
  int partColor = 0; // transparent color
  List<String> childrenIDs = [];
  List<ContentData> content = [TextData(data: "\n")];
  ContentDecor decor = ContentDecor.normal;
  QuillController contentEditor = QuillController.basic(config: QuillControllerConfig(clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: false)));

  Part({required this.parentId}) : trColor = getRandomColor() {
    List<Map> d = content.map((el) => el.toQuill()).toList();
    contentEditor.document = Document.fromJson(d);
  }

  Map toJson() {
    // update content
    content = ContentData.updateFromQuill(contentEditor.document.toDelta().toJson());

    Map data = {'childrenIDs': []};

    data['id'] = id;
    data['parentId'] = parentId;
    data['trColor'] = trColor;
    data['partColor'] = partColor;
    data['content'] = jsonEncode(content.map((el) => el.toJson()).toList());
    data['decor'] = decor.toString();
    data['childrenIDs'] = childrenIDs.map((el) => el).toList();

    return data;
  }

  static Part restore({required Map data}) {
    Part part = Part(parentId: data['parentId']);

    part.id = data['id'];
    part.trColor = data['trColor'];
    part.content = ContentData.updateFromMap(jsonDecode(data['content']));
    part.contentEditor.document = Document.fromJson(part.content.map((el) => el.toQuill()).toList());
    part.partColor = data['partColor'];

    if (data['decor'] == ContentDecor.bullet.toString()) part.decor = ContentDecor.bullet;
    if (data['decor'] == ContentDecor.numeric.toString()) part.decor = ContentDecor.numeric;

    for (var element in data['childrenIDs']) {
      part.childrenIDs.add(element);
    }

    return part;
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();

    // Print the basic properties
    sb.writeln('Part {');
    sb.writeln('  id: $id,');
    sb.writeln('  parentId: $parentId,');
    sb.writeln('  trColor: $trColor,');
    sb.writeln('  partColor: $partColor,');
    sb.writeln('  decor: $decor,');
    sb.writeln('  content: ${jsonEncode(content)},');

    // Print children recursively
    if (childrenIDs.isNotEmpty) {
      sb.writeln('  children: [');
      for (var child in childrenIDs) {
        // Indent child output for clarity
        var childStr = child.toString().split('\n').map((line) => '    $line').join('\n');
        sb.writeln('$childStr,');
      }
      sb.writeln('  ]');
    } else {
      sb.writeln('  children: []');
    }

    sb.writeln('}');
    return sb.toString();
  }
}

class ContentData {
  String data;
  ContentType type;
  ContentData({required this.type, required this.data});

  Map toJson() => {};
  Map toQuill() => {};

  @override
  String toString() => '';

  static List<ContentData> updateFromQuill(List<Map<String, dynamic>> content) {
    List<ContentData> res = [];
    for (Map<String, dynamic> el in content) {
      if (el['insert'].runtimeType == String) {
        res.add(TextData(data: el['insert'], attr: el['attributes']));
      } else if ((el['insert'] as Map<String, dynamic>).containsKey('myImage')) {
        res.add(
          ImageData(
            data: el['insert']['myImage']['base64'],
            width: el['insert']['myImage']['width'],
            ratio: el['insert']['myImage']['ratio'],
            align: el['insert']['myImage']['align'],
          ),
        );
      } else if ((el['insert'] as Map<String, dynamic>).containsKey('myMath')) {
        res.add(MathData(data: el['insert']['myMath']));
      }
    }
    return res;
  }

  static List<ContentData> updateFromMap(List content) {
    List<ContentData> res = [];
    for (var el in content) {
      if (el['type'] == 'text') {
        res.add(TextData(data: el['data'], attr: el['attr']));
      } else if (el['type'] == 'text') {
        res.add(ImageData(data: el['data'], width: el['width'], ratio: el['ratio'], align: el['align']));
      } else if ((el['insert'] as Map<String, dynamic>).containsKey('myMath')) {
        res.add(MathData(data: el['data']));
      }
    }
    return res;
  }
}

class TextData extends ContentData {
  Map? attr;
  TextData({super.type = ContentType.text, required super.data, this.attr}) {
    attr = attr ?? {"direction": "rtl"};
  }

  @override
  Map toJson() => {'type': 'text', 'data': data, 'attr': attr};

  @override
  String toString() => '{type: text, data: $data, attr: $attr}';

  @override
  Map toQuill() {
    Map res = {'insert': data};
    if (attr != null) res['attributes'] = attr;
    return res;
  }
}

class ImageData extends ContentData {
  double width;
  double ratio;
  String align;
  ImageData({super.type = ContentType.image, required super.data, required this.width, required this.ratio, required this.align});

  @override
  Map toJson() => {'type': 'image', 'data': data, 'width': width, 'ratio': ratio, 'align': align};

  @override
  String toString() => '{type: image, data: $data, width: $width, ratio: $ratio, align: $align}';

  @override
  Map toQuill() {
    return {
      'insert': {
        "myImage": {'base64': data, 'width': width, 'ratio': ratio, 'align': align}
      }
    };
  }
}

class MathData extends ContentData {
  MathData({super.type = ContentType.math, required super.data});

  @override
  Map toJson() => {'type': 'math', 'data': data};

  @override
  String toString() => '{type: math, data: $data}';

  @override
  Map toQuill() => {
        'insert': {'myMath': data}
      };
}

enum ContentType { text, image, math }

enum ContentDecor { normal, numeric, bullet }
