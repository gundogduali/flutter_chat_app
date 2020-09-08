import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/custom_tile.dart';

class GroupView extends StatelessWidget {
  final String userName;
  final String groupId;
  final String groupName;

  GroupView({this.userName, this.groupId, this.groupName});

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      mini: false,
      onTap: () {},
      title: Text(
        groupName,
        style:
            TextStyle(color: Colors.white, fontFamily: "Arial", fontSize: 19),
      ),
      subtitle: Text("Join the conversation as $userName", style: TextStyle(fontSize: 13.0)),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              radius: 80,
              child: Text(groupName.substring(0, 1).toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
