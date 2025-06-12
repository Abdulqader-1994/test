import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'model/edit_note.dart';
import 'model/lesson.dart';
import 'model/map.dart';
import 'model/part.dart';
import 'model/question.dart';

class EntidioController extends GetxController {
  int userId = -1;
  bool verify = false;
  bool check = false;
  int shares = 0;
  String taskName = '';
  int taskType = -1;
  VoidCallback submitTask = () {};
  VoidCallback goBack = () {};
  int time = 0;

  Lesson lesson;
  EntidioController({required this.lesson});

  List<EditNote> notes = [];
  bool viewMode = false;
  Part? selectedPart;
  List<Part>? copiedPart;
  QuillController editor = QuillController.basic();
  ScrollController scroll = ScrollController();

  Map<String, dynamic> avtiveBtn = {
    'fontFamily': 'El Messiri',
    'align': '',
    'fontSize': 'medium',
    'bold': false,
    'italic': false,
    'underline': false,
    'strikeThrough': false,
    'rtl': false,
    'imageWidth': 0,
    'imageAlign': 'center',
  };

  Future<void> setViewMode() async {
    viewMode = !viewMode;
    if (viewMode) {
      selectedPart = null;
      lesson = Lesson.restore(data: lesson.toJson());
    } else {
      void updateEditor(Part part) {
        part.contentEditor.document = Document.fromJson(part.content);
        part.contentEditor.readOnly = false;
        for (var child in part.childrenIDs) {
          Part part = lesson.content.where((el) => el.id == child).first;
          updateEditor(part);
        }
      }

      Part anchestor = lesson.content.where((el) => el.id == lesson.map.id).first;
      updateEditor(anchestor);
    }
    update(['viewMode', 'viewLesson', 'editLesson', 'viewer', 'updateView', 'all', 'control']);
  }

  void setPart({required Part part}) {
    if (selectedPart == part) return;

    List<String> ids = [part.id];
    if (selectedPart != null) ids.add(selectedPart!.id);
    selectedPart = part;

    updateActiveBtn(editor.selection);

    update(ids);
  }

  void setEditor({required QuillController c, EditNote? note}) {
    editor = c;
    if (verify && note != null && note.userId != userId) c.readOnly = true;
    editor.onSelectionChanged = updateActiveBtn;
  }

  void addPart({bool isChild = true}) {
    // this (!isChild && selectedPart!.parentId != lesson.map.id) => enusre that the anchstor part has no parallel part
    if (selectedPart == null) return;

    resetActiveBtn();

    // check if the selected part is note
    bool isItEditNote = false;
    for (var note in notes) {
      isItEditNote = note.content.where((el) => el.id == selectedPart!.id).isNotEmpty;
      if (isItEditNote) break;
    }

    if (!isItEditNote) {
      // enusre that the anchstor part has no parallel part (for other note)
      if ((!isChild && selectedPart!.id == lesson.map.id)) return;

      Part part;
      if (isChild) {
        part = Part(parentId: selectedPart!.id);
        selectedPart?.childrenIDs.add(part.id);
      } else {
        part = Part(parentId: selectedPart!.parentId);
        Part parent = lesson.content.where((el) => el.id == selectedPart!.parentId).first;
        parent.childrenIDs.add(part.id);
      }
      lesson.content.add(part);
      lesson.map = LessonMap.getTreeMap(lesson.content, lesson.map.id);
      selectedPart = part;
    } else {
      for (var note in notes) {
        Part? part = note.content.where((el) => el.id == selectedPart!.id).firstOrNull;
        if (part != null) {
          // enusre that the anchstor part has no parallel part (for other note)
          if ((!isChild && selectedPart!.id != note.map.id)) return;

          Part part;
          if (isChild) {
            part = Part(parentId: selectedPart!.id);
            selectedPart?.childrenIDs.add(part.id);
          } else {
            part = Part(parentId: selectedPart!.parentId);
            Part parent = lesson.content.where((el) => el.id == selectedPart!.parentId).first;
            parent.childrenIDs.add(part.id);
          }
          note.content.add(part);
          note.map = LessonMap.getTreeMap(note.content, note.map.id);
          selectedPart = part;
          break;
        }
      }
    }

    update(['all', 'expandBtn']);
  }

  void resetActiveBtn() {
    avtiveBtn = {
      'fontFamily': 'El Messiri',
      'align': '',
      'fontSize': 'medium',
      'bold': false,
      'italic': false,
      'underline': false,
      'strikeThrough': false,
      'rtl': false,
      'imageWidth': 0,
      'imageAlign': 'center',
    };

    update([
      'contentTypeBtn',
      'fontFamilyBtn',
      'fontSizeBtn',
      'rightBtn',
      'centerBtn',
      'leftBtn',
      'boldBtn',
      'italicBtn',
      'underlineBtn',
      'strikeThroughBtn',
      'rtlBtn',
      'ltrBtn',
      'imageWidthBtn',
      'imageAlignBtn',
    ]);
  }

  void deletePart() {
    if (selectedPart == null || selectedPart?.id == lesson.map.id) return;
    resetActiveBtn();

    Part parent = lesson.content.where((el) => el.id == selectedPart!.parentId).first;
    parent.childrenIDs.remove(selectedPart!.id);
    lesson.content.remove(selectedPart);
    lesson.map = LessonMap.getTreeMap(lesson.content, lesson.map.id);
    selectedPart = parent;
    update(['all', 'expandBtn']);
  }

  void copyPart() {
    if (selectedPart == null) return;
    List<Part> copiedParts = [];

    Part copyOnePart({required List<Part> allParts, required String selectedPartId, String parentId = ''}) {
      Part original = allParts.singleWhere((el) => el.id == selectedPartId);
      Part copy = Part(parentId: parentId);
      copy.trColor = original.trColor;
      copy.partColor = original.partColor;
      copy.decor = original.decor;
      copy.content = ContentData.updateFromQuill(original.contentEditor.document.toDelta().toJson());
      copy.contentEditor = original.contentEditor;

      for (var el in original.childrenIDs) {
        var newCopy = copyOnePart(allParts: allParts, selectedPartId: el, parentId: copy.id);
        copy.childrenIDs.add(newCopy.id);
        copiedParts.add(newCopy);
      }

      return copy;
    }

    Part n = copyOnePart(allParts: lesson.content, selectedPartId: selectedPart!.id);
    copiedParts.add(n);
    copiedPart = copiedParts;
    print(copiedPart);
  }

  void pastePart() {
    if (copiedPart == null || selectedPart == null) return;

    Part copy = copiedPart!.firstWhere((el) => el.parentId == '');
    copy.id = selectedPart!.id;
    copy.parentId = selectedPart!.parentId;
    lesson.content.remove(selectedPart);
    lesson.content.addAll(copiedPart!);

    selectedPart = copy;
    lesson.map = LessonMap.getTreeMap(lesson.content, lesson.map.id);
    update(['all']);
  }

  void addQuestion() {
    Part p = Part(parentId: '');
    CheckBoxQues ques = CheckBoxQues(content: p);
    lesson.questions.add(ques);
    update(['all']);
  }

  void setContentType({required ContentDecor type}) {
    if (selectedPart == null) return;
    selectedPart!.decor = type;
    update(['contentTypeBtn', ...selectedPart!.childrenIDs]);
  }

  void setLessonDir({required bool isRTL}) {
    if (lesson.isRTL == isRTL) return;
    lesson.isRTL = isRTL;
    update(['all', 'dirBtn1', 'dirBtn2']);
  }

  void setPropColor({required int value, required String type}) {
    if (selectedPart == null) return;

    if (type == 'trColor') selectedPart!.trColor = value;
    if (type == 'partColor') selectedPart!.partColor = value;

    final Map<String, Part> partsIndex = {
      for (final p in lesson.content) p.id: p,
    };

    lesson.map = LessonMap.getTreeMap(lesson.content, lesson.map.id);

    List<String> collectIds(Part p) {
      final ids = <String>[p.id];
      for (final childId in p.childrenIDs) {
        final child = partsIndex[childId];
        if (child != null) ids.addAll(collectIds(child));
      }
      return ids;
    }

    final affectedIds = collectIds(selectedPart!);
    print(affectedIds);

    update(['all', ...affectedIds]);
  }

  void updateActiveBtn(TextSelection select) {
    var style = editor.getSelectionStyle().attributes;

    // Update fontFamily
    avtiveBtn['fontFamily'] = style.containsKey(Attribute.font.key) ? style[Attribute.font.key]!.value : 'El Messiri';
    // Update fontSize
    avtiveBtn['fontSize'] = style.containsKey(Attribute.size.key) ? style[Attribute.size.key]!.value.toString() : '';
    // Update align
    avtiveBtn['align'] = style.containsKey(Attribute.align.key) ? style[Attribute.align.key]!.value.toString() : '';

    avtiveBtn['bold'] = style.containsKey(Attribute.bold.key); // Update bold
    avtiveBtn['italic'] = style.containsKey(Attribute.italic.key); // Update italic
    avtiveBtn['underline'] = style.containsKey(Attribute.underline.key); // Update underline
    avtiveBtn['strikeThrough'] = style.containsKey(Attribute.strikeThrough.key); // Update strikeThrough

    avtiveBtn['rtl'] = style.containsKey(Attribute.direction.key); // update direction

    // Update image Width and Ratio
    var node = editor.document.querySegmentLeafNode(editor.selection.baseOffset).leaf;
    var item = node?.toDelta().toJson()[0]['insert'];
    if (item == null || item is! Map || !item.containsKey('myImage')) {
      avtiveBtn['imageWidth'] = 0;
      avtiveBtn['imageAlign'] = '';
    } else {
      var res = jsonDecode(item['myImage']);
      avtiveBtn['imageWidth'] = res['width'];
      avtiveBtn['imageAlign'] = res['align'];
    }

    update([
      'fontFamilyBtn',
      'fontSizeBtn',
      'rightBtn',
      'centerBtn',
      'leftBtn',
      'boldBtn',
      'italicBtn',
      'underlineBtn',
      'strikeThroughBtn',
      'rtlBtn',
      'ltrBtn',
      'imageWidthBtn',
      'imageAlignBtn',
    ]);
  }

  void updateImageProp({required String type, required dynamic value}) {
    if (selectedPart == null) return;

    int offset = editor.selection.baseOffset;

    var node = editor.document.querySegmentLeafNode(offset).leaf;
    var img = node?.toDelta().toJson()[0]['insert'];

    if (!(img is Map && img.containsKey('myImage'))) {
      // check image in previos offset
      node = editor.document.querySegmentLeafNode(offset - 1).leaf;
      img = node?.toDelta().toJson()[0]['insert'];
      if (!(img is Map && img.containsKey('myImage'))) return;
      offset--;
    }

    var res = jsonDecode(img['myImage']);
    var base64 = res['base64'];
    var ratio = res['ratio'];
    var width = res['width'];
    var align = res['align'];

    String result = '';
    if (type == 'width') {
      if (value < 100) value = 100;
      if (value > 900) value = 900;
      result = jsonEncode({'base64': base64, 'width': value, 'ratio': ratio, 'align': align});
    }
    if (type == 'align') {
      result = jsonEncode({'base64': base64, 'width': width, 'ratio': ratio, 'align': value});
    }

    var updatedImg = {'myImage': result};

    var delta = Delta()
      ..retain(offset)
      ..delete(1)
      ..insert(updatedImg);

    editor.document.compose(delta, ChangeSource.local);
    editor.updateSelection(TextSelection.collapsed(offset: offset), ChangeSource.local);
    //editor.editorFocusNode?.requestFocus();
  }

  void addEditNote() {
    if (selectedPart == null || (!verify && !check)) return;

    bool isNoteExist = notes.where((el) => el.partId == selectedPart?.id).isNotEmpty;
    if (isNoteExist) return;

    Part newPart = Part(parentId: Uuid().v8());
    newPart.content = selectedPart!.content;
    LessonMap map = LessonMap(id: newPart.id, trColor: newPart.trColor, children: []);
    EditNote note = EditNote(userId: userId, partId: selectedPart!.id, content: [newPart], map: map);
    note.content.first.contentEditor.document = Document.fromJson(selectedPart!.content);
    notes.add(note);
    selectedPart = null;
    update(['all']);
  }

  void deleteNote({required EditNote note}) {
    notes.remove(note);
    update(['all']);
  }
}
