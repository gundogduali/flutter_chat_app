import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/enum/user_state.dart';
import 'package:flutter_chat_app/models/user.dart';
import 'package:flutter_chat_app/resources/firebase_repository.dart';
import 'package:flutter_chat_app/utils/utilities.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final FirebaseRepository _repository = FirebaseRepository();

  OnlineDotIndicator({
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Colors.red;
        case UserState.Online:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _repository.getUserStream(uid: uid),
      builder: (context, snapshot) {
        User user;

        if (snapshot.hasData && snapshot.data.data != null) {
          user = User.fromMap(snapshot.data.data);
        }

        return Container(
          height: 10,
          width: 10,
          margin: EdgeInsets.only(right: 2, bottom: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: getColor(user?.state),
          ),
        );
      },
    );
  }
}
