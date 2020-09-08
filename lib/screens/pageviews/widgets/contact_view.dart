import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/contact.dart';
import 'package:flutter_chat_app/models/user.dart';
import 'package:flutter_chat_app/provider/user_provider.dart';
import 'package:flutter_chat_app/resources/firebase_repository.dart';
import 'package:flutter_chat_app/screens/chatscreens/chat_screen.dart';
import 'package:flutter_chat_app/screens/chatscreens/widgets/cached_image.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/last_message_container.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/online_dot_indicator.dart';
import 'package:flutter_chat_app/utils/universal_variables.dart';
import 'package:flutter_chat_app/widgets/custom_tile.dart';
import 'package:provider/provider.dart';

final FirebaseRepository _repository = FirebaseRepository();

class ContactView extends StatelessWidget {
  final Contact contact;

  ContactView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _repository.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;
          return ViewLayout(contact: user);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final User contact;

  ViewLayout({
    @required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            receiver: contact,
          ),
        ),
      ),
      title: Text(
        (contact != null ? contact.name : null) != null ? contact.name : "..",
        style:
            TextStyle(color: Colors.white, fontFamily: "Arial", fontSize: 19),
      ),
      subtitle: LastMessageContainer(
        stream: _repository.fetchLastMessageBetween(
          senderId: userProvider.getUser.uid,
          receiverId: contact.uid,
        ),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              contact.profilePhoto,
              radius: 80,
              isRound: true,
            ),
            Container(
              alignment: Alignment.bottomRight,
                          child: OnlineDotIndicator(
                uid: contact.uid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
