import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/contact.dart';
import 'package:flutter_chat_app/provider/user_provider.dart';
import 'package:flutter_chat_app/resources/firebase_repository.dart';
import 'package:flutter_chat_app/screens/callscreens/pickup/pickup_layout.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/contact_view.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/group_view.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/new_chat_button.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/quiet_box.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/user_circle.dart';
import 'package:flutter_chat_app/utils/universal_variables.dart';
import 'package:flutter_chat_app/widgets/appbar.dart';
import 'package:provider/provider.dart';

class GroupChatListScreen extends StatefulWidget {
  @override
  _GroupChatListScreenState createState() => _GroupChatListScreenState();
}

class _GroupChatListScreenState extends State<GroupChatListScreen> {
  final FirebaseRepository _repository = FirebaseRepository();
  FirebaseUser _user;
  String _groupName;
  String _userName = '';
  String _email = '';
  Stream _groups;

  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }

  _getUserAuthAndJoinedGroups() async {
    _user = await _repository.getCurrentUser();
    _userName = _user.displayName;
    _email = _user.email;

    _repository.getUserGroups(_user.uid).then((snapshot) {
      setState(() {
        _groups = snapshot;
      });
    });
  }

  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.notifications,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      title: UserCircle(),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, "/search_screen");
          },
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: customAppBar(context),
        floatingActionButton: NewChatButton(),
        body: ChatListContainer(_groups),
      ),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  Stream _groups;

  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('_'));
  }

  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('_') + 1);
  }

  ChatListContainer(this._groups);
  
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
          stream: _groups,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data['groups'] != null) {
                if (snapshot.data['groups'].length != 0) {
                  return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: snapshot.data['groups'].length,
                    itemBuilder: (context, index) {
                      int reqIndex = snapshot.data['groups'].length - index - 1;
                      return GroupView(userName: snapshot.data['name'], groupId: _destructureId(snapshot.data['groups'][reqIndex]), groupName: _destructureName(snapshot.data['groups'][reqIndex]));
                    },
                  );
                }
              }

            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
