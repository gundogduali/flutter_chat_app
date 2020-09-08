import 'package:flutter_chat_app/models/user.dart';

class Group {
  String uid;
  String name;
  List<User> members;

  Group({this.uid, this.name, this.members});

  factory Group.fromMap(Map<dynamic, dynamic> map) {
    var members = map['members'] as List;

    List memberList = members.map((user) => User.fromMap(user)).toList();

    return Group(uid: map['uid'], name: map['name'], members: memberList);
  }

  Map toMap(Group group) {
    var data = Map<String, dynamic>();


    data['uid'] = group.uid;
    data['name'] = group.name;
    data['members'] = group.members;
    return data;
  }
}
