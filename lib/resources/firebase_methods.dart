import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/strings.dart';
import 'package:flutter_chat_app/enum/user_state.dart';
import 'package:flutter_chat_app/models/contact.dart';
import 'package:flutter_chat_app/models/group.dart';
import 'package:flutter_chat_app/models/message.dart';
import 'package:flutter_chat_app/models/user.dart';
import 'package:flutter_chat_app/provider/image_upload_provider.dart';
import 'package:flutter_chat_app/utils/utilities.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final Firestore firestore = Firestore.instance;
  StorageReference _storageReference;
  static final CollectionReference _userCollection =
      firestore.collection(USERS_COLLECTION);

  final CollectionReference groupCollection =
      Firestore.instance.collection('groups');
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  //user class
  User user = User();

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }

  Future<User> getUserDetails() async {
    FirebaseUser currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();
    return User.fromMap(documentSnapshot.data);
  }

  Future<FirebaseUser> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: _signInAuthentication.idToken,
        accessToken: _signInAuthentication.accessToken);

    AuthResult result = await _auth.signInWithCredential(credential);
    FirebaseUser user = result.user;
    return user;
  }

  Future<bool> authenticateUser(FirebaseUser user) async {
    QuerySnapshot result = await firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;

    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(FirebaseUser currentUser) async {
    String username = Utils.getUsername(currentUser.email);
    user = User(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoUrl,
        username: username);

    firestore
        .collection(USERS_COLLECTION)
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }

  Future<void> addGroupToDb(String name, List<User> members) async {
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': name,
      'groupIcon': '',
      'members': [],
      //'messages': ,
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': ''
    });

    List<Map> list = new List();
    if (members != null && members.isNotEmpty) {
      members.forEach((element) {
        list.add(element.toMap(element));
      });
    }

    await groupDocRef.updateData({
      'members': FieldValue.arrayUnion(list),
      'groupId': groupDocRef.documentID
    });

    members.forEach((element) {
      return userCollection.document(element.uid).updateData({
        'groups': FieldValue.arrayUnion([groupDocRef.documentID + '_' + name])
      });
    });
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<User>> fetchAllUsers(FirebaseUser currentUser) async {
    List<User> usersList = List<User>();

    QuerySnapshot querySnapshot =
        await firestore.collection(USERS_COLLECTION).getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != currentUser.uid) {
        usersList.add(User.fromMap(querySnapshot.documents[i].data));
      }
    }
    return usersList;
  }

  Future<void> addMessageToDb(
      Message message, User sender, User receiver) async {
    var map = message.toMap();

    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(message.senderId)
        .collection(message.receiverId)
        .add(map);

    addToContacts(senderId: message.senderId, receiverId: message.receiverId);

    return await firestore
        .collection(MESSAGES_COLLECTION)
        .document(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  Future<String> uploadImageToStorage(File image) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');

      StorageUploadTask _storageUploadTask = _storageReference.putFile(image);
      var url =
          await (await _storageUploadTask.onComplete).ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void setImageMsg(String url, String receiverId, String senderId) async {
    Message _message;
    _message = Message.imageMessage(
      message: "IMAGE",
      receiverId: receiverId,
      senderId: senderId,
      photoUrl: url,
      timestamp: Timestamp.now(),
      type: "image",
    );
    var map = _message.toImageMap();

    //Set the data to database

    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(_message.senderId)
        .collection(_message.receiverId)
        .add(map);

    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(_message.receiverId)
        .collection(_message.senderId)
        .add(map);
  }

  void uploadImage(File image, String receiverId, String senderId,
      ImageUploadProvider imageUploadProvider) async {
    imageUploadProvider.setToLoading();

    String url = await uploadImageToStorage(image);

    imageUploadProvider.setToIdle();

    setImageMsg(url, receiverId, senderId);
  }

  void uploadImageGroup(File image, String senderId,
      ImageUploadProvider imageUploadProvider) async {
    imageUploadProvider.setToLoading();

    String url = await uploadImageToStorage(image);

    imageUploadProvider.setToIdle();

    setGroupImageMsg(url, senderId);
  }

  void setGroupImageMsg(String url, String senderId) async {
    Message _message;
    _message = Message.imageMessage(
      message: "IMAGE",
      receiverId: "",
      senderId: senderId,
      photoUrl: url,
      timestamp: Timestamp.now(),
      type: "image",
    );
    var map = _message.toImageMap();

    //Set the data to database

    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(_message.senderId)
        .collection(_message.receiverId)
        .add(map);

    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(_message.receiverId)
        .collection(_message.senderId)
        .add(map);
  }

  void addToContacts({String senderId, String receiverId}) async {
    Timestamp currentTime = Timestamp.now();
    await addToSendersContact(senderId, receiverId, currentTime);
    await addToReceiversContact(senderId, receiverId, currentTime);
  }

  DocumentReference getContactsDocument({String of, String forContact}) =>
      firestore
          .collection(USERS_COLLECTION)
          .document(of)
          .collection(CONTACT_COLLECTION)
          .document(forContact);

  Future<void> addToSendersContact(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();
    if (!senderSnapshot.exists) {
      Contact receiverContact = Contact(uid: receiverId, addedOn: currentTime);

      var receiverMap = receiverContact.toMap(receiverContact);
      await getContactsDocument(of: senderId, forContact: receiverId)
          .setData(receiverMap);
    }
  }

  Future<void> addToReceiversContact(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();
    if (!receiverSnapshot.exists) {
      Contact senderContact = Contact(uid: senderId, addedOn: currentTime);

      var senderMap = senderContact.toMap(senderContact);
      await getContactsDocument(of: receiverId, forContact: receiverId)
          .setData(senderMap);
    }
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) => firestore
      .collection(USERS_COLLECTION)
      .document(userId)
      .collection(CONTACT_COLLECTION)
      .snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween(
          {@required String senderId, @required String receiverId}) =>
      firestore
          .collection(MESSAGES_COLLECTION)
          .document(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();

  Future<User> getUserDetailsById(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await firestore.collection(USERS_COLLECTION).document(id).get();
      return User.fromMap(documentSnapshot.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.document(userId).updateData({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.document(uid).snapshots();

  getChats(String groupId) async {
    return Firestore.instance
        .collection('groups')
        .document(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  sendGroupMessage(String groupId, chatMessageData) {
    Firestore.instance
        .collection('groups')
        .document(groupId)
        .collection('messages')
        .add(chatMessageData);
    Firestore.instance.collection('groups').document(groupId).updateData({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  getUserGroups(String uid) async {
    // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return Firestore.instance.collection("users").document(uid).snapshots();
  }
}
