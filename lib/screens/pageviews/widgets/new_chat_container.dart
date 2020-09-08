import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/globals/globals.dart';
import 'package:flutter_chat_app/models/contact.dart';
import 'package:flutter_chat_app/models/user.dart';
import 'package:flutter_chat_app/provider/user_provider.dart';
import 'package:flutter_chat_app/resources/firebase_repository.dart';
import 'package:flutter_chat_app/screens/chatscreens/widgets/cached_image.dart';
import 'package:flutter_chat_app/screens/pageviews/chat_list_screen.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/contact_view.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/quiet_box.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/shimmering_logo.dart';
import 'package:flutter_chat_app/widgets/appbar.dart';
import 'package:flutter_chat_app/widgets/custom_tile.dart';
import 'package:provider/provider.dart';

class NewChatContainer extends StatefulWidget {
  @override
  _NewChatContainerState createState() => _NewChatContainerState();
}

final FirebaseRepository _repository = FirebaseRepository();
Globals globals = Globals();

class _NewChatContainerState extends State<NewChatContainer> {
  String _groupName = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: Column(
        children: <Widget>[
          CustomAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            title: ShimmeringLogo(),
            actions: <Widget>[],
          ),
          _popupDialog(),
          Divider(),
          Expanded(child: ContactsList()),
        ],
      ),
    );
  }

  _popupDialog() {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Text(
            "Grup oluştur.",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            onChanged: (value) {
              _groupName = value;
            },
            style: TextStyle(
              fontSize: 15,
              height: 2.0,
              color: Colors.black,
            ),
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("İptal"),
              ),
              FlatButton(
                onPressed: () {
                  if(_groupName!= "")
                  _repository.addGroupToDb(_groupName, globals.members);
                  Navigator.of(context).pop();
                },
                child: Text("Oluştur."),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContactsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _repository.fetchContacts(
            userId: userProvider.getUser.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.documents;

              if (docList.isEmpty) {
                return QuietBox();
              }
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  Contact contact = Contact.fromMap(docList[index].data);
                  return ContactGroupView(contact);
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

class ContactGroupView extends StatelessWidget {
  final Contact contact;

  ContactGroupView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _repository.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;
          return GroupViewLayout(contact: user);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class GroupViewLayout extends StatefulWidget {
  final User contact;

  GroupViewLayout({
    @required this.contact,
  });

  @override
  _GroupViewLayoutState createState() => _GroupViewLayoutState();
}

class _GroupViewLayoutState extends State<GroupViewLayout> {
  @override
  Widget build(BuildContext context) {
    return CustomTile(
      mini: false,
      subtitle: Text(""),
      onTap: () {
        setState(() {
          widget.contact.checked
              ? {
                  widget.contact.checked = false,
                  globals.members.remove(widget.contact),
                }
              : {
                  widget.contact.checked = true,
                  globals.members.add(widget.contact)
                };
        });
      },
      title: Text(
        (widget.contact != null ? widget.contact.name : null) != null
            ? widget.contact.name
            : "..",
        style:
            TextStyle(color: Colors.white, fontFamily: "Arial", fontSize: 19),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              widget.contact.profilePhoto,
              radius: 80,
              isRound: true,
            ),
          ],
        ),
      ),
      trailing: widget.contact.checked ? Icon(Icons.check) : Container(),
    );
  }
}
