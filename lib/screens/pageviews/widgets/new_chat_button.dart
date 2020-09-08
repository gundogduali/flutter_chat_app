import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/new_chat_container.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/shimmering_logo.dart';
import 'package:flutter_chat_app/utils/universal_variables.dart';

class NewChatButton extends StatelessWidget {
  String _groupName = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: UniversalVariables.fabGradient,
          borderRadius: BorderRadius.circular(50)),
      child: SizedBox(
        height: 25,
        width: 25,
        child: IconButton(
          padding: EdgeInsets.all(0.0),
          icon: Icon(
            Icons.edit,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () => showModalBottomSheet(
            context: context,
            backgroundColor: UniversalVariables.blackColor,
            builder: (context) => NewChatContainer(),
            isScrollControlled: true,
          ),
        ),
      ),
      padding: EdgeInsets.all(15),
    );
  }
}
