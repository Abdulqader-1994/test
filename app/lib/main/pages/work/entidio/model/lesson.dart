import 'dart:convert';

import 'map.dart';
import 'part.dart';
import 'question.dart';

class Lesson {
  List<Part> content = [];
  List<Question> questions = [];
  LessonMap map;
  String country;
  String eduType; // school - univercirty
  String year;
  String term; // term 1 or 2
  String subject;
  bool isRTL;

  Lesson({
    required this.content,
    required this.map,
    this.country = '',
    this.eduType = '',
    this.year = '',
    this.term = '',
    this.subject = '',
    this.isRTL = true,
  });

  @override
  String toString() => "Lesson(content: $content, country: $country, eduType: $eduType, term: $term, subject: $subject, isRTL: $isRTL)";

  Map toJson() {
    map.setTitle(map, content);

    Map data = {
      'content': content.map((el) => el.toJson()).toList(),
      'map': jsonEncode(map.toJson()),
      'country': country,
      'eduType': eduType,
      'year': year,
      'term': term,
      'subject': subject,
      'isRTL': isRTL,
    };

    print(content);

    return data;
  }

  static Lesson restore({required Map data}) {
    List<Part> contents = [];
    for (var el in data['content']) {
      contents.add(Part.restore(data: el));
    }
    Lesson les = Lesson(
      content: contents,
      map: LessonMap.restore(data: data['map']),
      country: data['country'],
      eduType: data['eduType'],
      year: data['year'],
      term: data['term'],
      subject: data['subject'],
      isRTL: data['isRTL'],
    );
    return les;
  }

  init({required String curriculum, required String level, required int termType}) {
    subject = curriculum;
    year = level;
    if (termType == 0) term = 'الفصل الأول والثاني';
    if (termType == 1) term = 'الفصل الأول';
    if (termType == 2) term = 'الفصل الثاني';
  }
}
