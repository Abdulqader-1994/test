import 'map.dart';
import 'part.dart';

class EditNote {
  int userId;
  String partId;
  List<Part> content;
  LessonMap map;

  EditNote({required this.userId, required this.partId, required this.map, required this.content});

  @override
  String toString() => "EditNote(userId:$userId, partId: $partId, content: $content)";

  Map toJson() => {'userId': userId, 'partId': partId, 'map': map.toJson(), 'content': content.map((el) => el.toJson()).toList()};

  static EditNote restore({required Map data}) {
    List<Part> content = [];
    for (var el in data['content']) {
      content.add(Part.restore(data: el));
    }
    return EditNote(userId: data['userId'], partId: data['partId'], content: content, map: LessonMap.restore(data: data['map']));
  }
}
