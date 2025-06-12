import 'dart:convert';
import 'part.dart';

class Question {
  Part content;
  QuesType type = QuesType.checkBox;

  Question({required this.type, required this.content});

  Map toJson() {
    Map data = (this as CheckBoxQues).checkBoxJson();
    return data;
  }

  static Question restore({required Map data}) {
    return CheckBoxQues.restore(data: data);
  }
}

enum QuesType { checkBox }

class CheckBoxQues extends Question {
  List<CheckBoxOption> options = [];
  int answer = 0;

  CheckBoxQues({super.type = QuesType.checkBox, required super.content}) {
    var optiion1 = CheckBoxOption(p: Part(parentId: super.content.id));
    var optiion2 = CheckBoxOption(p: Part(parentId: super.content.id));

    options.addAll([optiion1, optiion2]);
  }

  Map checkBoxJson() {
    return {'ques': content.toJson(), 'options': options.map((option) => option.toJson()).toList(), 'answer': answer};
  }

  static CheckBoxQues restore({required Map data}) {
    Part p = Part(parentId: data['partId']);
    p.content = jsonDecode(data['ques']);
    CheckBoxQues check = CheckBoxQues(content: p);
    check.answer = data['answer'];
    check.options.clear();
    for (var el in data['options']) {
      check.options.add(CheckBoxOption.restore(data: el));
    }
    return check;
  }
}

class CheckBoxOption {
  Part p;

  CheckBoxOption({required this.p});

  Map toJson() => {'p': p.toJson()};

  static CheckBoxOption restore({required Map data}) {
    Part part = Part.restore(data: data);
    CheckBoxOption option = CheckBoxOption(p: part);
    return option;
  }
}
