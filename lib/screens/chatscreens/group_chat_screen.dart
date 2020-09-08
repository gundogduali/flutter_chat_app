import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/strings.dart';
import 'package:flutter_chat_app/enum/view_state.dart';
import 'package:flutter_chat_app/models/message.dart';
import 'package:flutter_chat_app/provider/image_upload_provider.dart';
import 'package:flutter_chat_app/resources/firebase_repository.dart';
import 'package:flutter_chat_app/screens/chatscreens/widgets/cached_image.dart';
import 'package:flutter_chat_app/utils/permissions.dart';
import 'package:flutter_chat_app/utils/universal_variables.dart';
import 'package:flutter_chat_app/utils/utilities.dart';
import 'package:flutter_chat_app/widgets/appbar.dart';
import 'package:flutter_chat_app/widgets/custom_tile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;

  GroupChatScreen({this.groupId, this.userName, this.groupName});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  Stream<QuerySnapshot> _chats;
  FirebaseRepository _repository = FirebaseRepository();
  ImageUploadProvider _imageUploadProvider;
  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();
  String _currentUserId;
  ScrollController _listScrollController = ScrollController();

  bool isWriting = false;

  bool showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      _currentUserId = user.uid;
    });
    _repository.getChats(widget.groupId).then((val) {
      setState(() {
        _chats = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    showKeyboard() => textFieldFocus.requestFocus();
    hideKeyboard() => textFieldFocus.unfocus();

    hideEmojiContainer() {
      setState(() {
        showEmojiPicker = false;
      });
    }

    showEmojiContainer() {
      setState(() {
        showEmojiPicker = true;
      });
    }

    getMessage(Message message) {
      return message.type != MESSAGE_TYPE_IMAGE
          ? Text(
              "${message.senderId}\n${message.message}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            )
          : message.photoUrl != null
              ? CachedImage(
                  message.photoUrl,
                  height: 250,
                  width: 250,
                  radius: 10,
                )
              : Text("url was null");
    }

    Widget senderLayout(Message message) {
      Radius messageRadius = Radius.circular(10);

      return Container(
        margin: EdgeInsets.only(top: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        decoration: BoxDecoration(
          color: UniversalVariables.senderColor,
          borderRadius: BorderRadius.only(
            topLeft: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: getMessage(message),
        ),
      );
    }

    Widget receiverLayout(Message message) {
      Radius messageRadius = Radius.circular(10);

      return Container(
        margin: EdgeInsets.only(top: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        decoration: BoxDecoration(
          color: UniversalVariables.receiverColor,
          borderRadius: BorderRadius.only(
            bottomRight: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: getMessage(message),
        ),
      );
    }

    Widget chatMessageItem(DocumentSnapshot snapshot) {
      Message _message = Message.fromMap(snapshot.data);

      return Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Container(
          alignment: _message.senderId == _currentUserId
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: _message.senderId == _currentUserId
              ? senderLayout(_message)
              : receiverLayout(_message),
        ),
      );
    }

    Widget chatMessages() {
      return StreamBuilder(
        stream: _chats,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data.length,
            reverse: true,
            controller: _listScrollController,
            itemBuilder: (context, index) {
              return chatMessageItem(snapshot.data[index]);
            },
          );
        },
      );
    }

    emojiContainer() {
      return EmojiPicker(
        bgColor: UniversalVariables.separatorColor,
        indicatorColor: UniversalVariables.blueColor,
        rows: 5,
        columns: 8,
        onEmojiSelected: (emoji, category) {
          setState(() {
            isWriting = true;
          });

          textFieldController.text = textFieldController.text + emoji.emoji;
        },
        recommendKeywords: ["face", "happy", "party", "sad"],
        numRecommended: 40,
      );
    }

    sendMessage() {
      var text = textFieldController.text;
      Message _message = Message(
        receiverId: "",
        senderId: widget.userName,
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      _repository.sendGroupMessage(widget.groupId, _message);
    }

    Widget chatControls() {
      setWritingTo(bool val) {
        setState(() {
          isWriting = val;
        });
      }

      void pickImage({@required ImageSource source}) async {
        File selectedImage = await Utils.pickImage(source: source);
        _repository.uploadImageGroup(
          selectedImage,
          _currentUserId,
          _imageUploadProvider,
        );
      }

      addMediaModal(context) {
        showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: UniversalVariables.blackColor,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.maybePop(context),
                        child: Icon(
                          Icons.close,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Araçlar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Fotoğraf veya video paylaş.",
                        icon: Icons.image,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                      ModalTile(
                        title: "Dosya",
                        subtitle: "Dosya paylaş.",
                        icon: Icons.insert_drive_file,
                      ),
                      ModalTile(
                        title: "Kişi",
                        subtitle: "Kişi yolla.",
                        icon: Icons.contact_phone,
                      ),
                      ModalTile(
                        title: "Konum",
                        subtitle: "Konum paylaş.",
                        icon: Icons.add_location,
                      ),
                      ModalTile(
                        title: "Plan",
                        subtitle: "Plan yap.",
                        icon: Icons.schedule,
                      ),
                      ModalTile(
                        title: "Anket oluştur",
                        subtitle: "Anket paylaş.",
                        icon: Icons.poll,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }

      return Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => addMediaModal(context),
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  TextField(
                    controller: textFieldController,
                    focusNode: textFieldFocus,
                    onTap: () => hideEmojiContainer(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    onChanged: (val) {
                      (val.length > 0 && val.trim() != "")
                          ? setWritingTo(true)
                          : setWritingTo(false);
                    },
                    decoration: InputDecoration(
                      hintText: "Mesaj yazınız.",
                      hintStyle: TextStyle(
                        color: UniversalVariables.greyColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(50.0)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      filled: true,
                      fillColor: UniversalVariables.separatorColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (!showEmojiPicker) {
                        hideKeyboard();
                        showEmojiContainer();
                      } else {
                        showKeyboard();
                        hideEmojiContainer();
                      }
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.face),
                  ),
                ],
              ),
            ),
            isWriting
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.record_voice_over),
                  ),
            isWriting
                ? Container()
                : GestureDetector(
                    child: Icon(Icons.camera_alt),
                    onTap: () => pickImage(source: ImageSource.camera),
                  ),
            isWriting
                ? Container(
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        size: 15,
                      ),
                      onPressed: () => sendMessage(),
                    ),
                  )
                : Container()
          ],
        ),
      );
    }

    CustomAppBar customAppBar(context) {
      return CustomAppBar(
        title: Text(
          widget.groupName,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.phone,
            ),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
      );
    }

    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      body: Column(
        children: <Widget>[
          Flexible(
            child: chatMessages(),
          ),
          _imageUploadProvider.getViewState == ViewState.LOADING
              ? Container(
                  child: CircularProgressIndicator(),
                  margin: EdgeInsets.only(right: 15),
                  alignment: Alignment.centerRight,
                )
              : Container(),
          chatControls(),
          showEmojiPicker ? Container(child: emojiContainer()) : Container(),
        ],
      ),
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalVariables.receiverColor,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: UniversalVariables.greyColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
