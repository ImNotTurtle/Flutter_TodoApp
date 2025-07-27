import 'package:uuid/uuid.dart';

final uuid = Uuid();

class TodoGroup {
  final String id;
  String title;

  TodoGroup({required this.title, String? id}) : id = id ?? uuid.v4();
  TodoGroup.createEmpty() : this(title: '');

  TodoGroup copyWith({String? id, String? title}) {
    return TodoGroup(id: id ?? this.id, title: title ?? this.title);
  }

  factory TodoGroup.fromJson(Map<String, dynamic> json) {
    return TodoGroup(id: json['id'], title: json['title']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}
