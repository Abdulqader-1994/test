import 'part.dart';

class LessonMap {
  String id;
  String title;
  int trColor;
  List<LessonMap> children;

  LessonMap({required this.id, this.title = '', required this.trColor, required this.children});

  @override
  String toString() => 'LessonMap(id: $id, title: $title, trColor: $trColor, children; $children)';

  Map toJson() {
    return {'id': id, 'title': title, 'trColor': trColor, 'children': children.map((el) => el.toJson()).toList()};
  }

  void setTitle(LessonMap map, List<Part> content) {
    Part part = content.where((el) => el.id == id).first;
    map.title = part.contentEditor.document.toPlainText();

    for (LessonMap m in map.children) {
      setTitle(m, content);
    }
  }

  static LessonMap restore({required Map data}) {
    List<LessonMap> children = [];
    for (var el in data['children']) {
      children.add(LessonMap.restore(data: el));
    }
    return LessonMap(id: data['id'], title: data['title'], trColor: data['trColor'], children: children);
  }

  static LessonMap getTreeMap(List<Part> content, String anchestorId) {
    LessonMap buildMap(Part part) {
      LessonMap map = LessonMap(
        id: part.id,
        trColor: part.trColor,
        children: part.childrenIDs.map((id) {
          Part part = content.where((el) => el.id == id).first;
          return buildMap(part);
        }).toList(),
      );
      return map;
    }

    Part anchestor = content.where((el) => el.id == anchestorId).first;
    return buildMap(anchestor);
  }
}
